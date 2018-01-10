#
# Cookbook Name:: kaldi-asr
# Recipe:: gstreamer_worker
# Author:: Yifan Zhang (<yzhang@qf.org.qa>)
#
# Copyright (C) 2015 Qatar Computing Research Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'kaldi-asr::kaldi'
include_recipe 'poise-python'
include_recipe 'poise-python::pip'
include_recipe 'poise-python::virtualenv'
include_recipe 'supervisor'
include_recipe 'tar'

['gstreamer1.0-plugins-bad', 'gstreamer1.0-plugins-base',
 'gstreamer1.0-plugins-good', 'gstreamer1.0-pulseaudio',
 'gstreamer1.0-plugins-ugly', 'gstreamer1.0-tools',
 'libgstreamer1.0-dev', 'libjansson-dev'].each do |package_name|
  package package_name do
    retries 3
  end
end

gw_version = node[:kaldi_asr][:gstreamer_worker_version]
ark 'gstreamer-worker' do
  owner node[:kaldi_asr][:user]
  url "https://github.com/yifan/gst-kaldi-nnet2-online/archive/v#{gw_version}.tar.gz"
  version gw_version
  checksum node[:kaldi_asr][:gstreamer_worker_checksum]
  path '/opt'
  home_dir node[:kaldi_asr][:gstreamer_worker_root]
end

bash 'build-gstreamer-worker' do
  user node[:kaldi_asr][:user]
  cwd node[:kaldi_asr][:gstreamer_worker_root]
  code <<-EOH
    cd src
    KALDI_ROOT=#{node[:kaldi_asr][:kaldi_root]} make depend
    KALDI_ROOT=#{node[:kaldi_asr][:kaldi_root]} make
  EOH
  not_if "test -e #{node[:kaldi_asr][:gstreamer_worker_root]}/src/libgstkaldionline2.so"
end

model_name = "#{node[:kaldi_asr][:model_name]}"
model_url = "#{node[:kaldi_asr][:model_url]}"
model_dir = "#{node[:kaldi_asr][:model_dir]}/#{model_name}"
directory "#{model_dir}" do
  owner node[:kaldi_asr][:user]
  recursive true
  action :create
end

output_dir = "#{node[:kaldi_asr][:output_dir]}/#{model_name}"
directory "#{output_dir}" do
  owner node[:kaldi_asr][:user]
  recursive true
  action :create
end

tar_extract model_url do
  user node[:kaldi_asr][:user]
  download_dir model_dir
  target_dir model_dir
  creates "#{model_dir}/conf"
  not_if "test -e #{model_dir}/model.yaml"
end

template "#{model_dir}/model.yaml" do
  source "#{model_dir}/model.yaml.template"
  owner node[:kaldi_asr][:user]
  local true
  variables ({
    :model_path => model_dir,
    :output_path => output_dir,
  })
  not_if "test -e #{model_dir}/model.yaml"
end

template "#{model_dir}/conf/ivector_extractor.conf" do
  source "#{model_dir}/conf/ivector_extractor.conf.template"
  owner node[:kaldi_asr][:user]
  local true
  variables ({
    :model_path => model_dir,
    :output_path => output_dir,
  })
  only_if "test -e #{model_dir}/conf/ivector_extractor.conf.template"
  not_if "test -e #{model_dir}/conf/ivector_extractor.conf"
end

virtualenv = node[:kaldi_asr][:gstreamer_server_root]
gs_root = node[:kaldi_asr][:gstreamer_server_root]
gs_port = node[:kaldi_asr][:gstreamer_server_port]

supervisor_service "kaldi-gstreamer-worker-supervisor" do
  user node[:kaldi_asr][:user]
  action [:enable, :start]
  autostart true

  environment 'LD_LIBRARY_PATH' => "#{node[:kaldi_asr][:kaldi_root]}/tools/openfst/lib",
              'GST_PLUGIN_PATH' => "#{node[:kaldi_asr][:gstreamer_worker_root]}/src",
              'GST_DEBUG' => "kaldinnet2onlinedecoder:3"

  command <<-EOH
    #{virtualenv}/bin/python \
    #{gs_root}/kaldigstserver/worker.py \
    -u ws://#{node[:kaldi_asr][:gstreamer_server_ip]}:#{gs_port}/worker/ws/speech \
    -f #{node[:kaldi_asr][:gstreamer_worker_nthread]} \
    -c #{model_dir}/model.yaml
  EOH
end
