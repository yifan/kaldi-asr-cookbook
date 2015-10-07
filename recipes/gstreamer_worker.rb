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

include_recipe 'kaldi-asr::source'
include_recipe 'python'
include_recipe 'python::pip'
include_recipe 'python::virtualenv'
include_recipe 'supervisor'
include_recipe 'tar'

['gstreamer1.0-plugins-bad', 'gstreamer1.0-plugins-base',
 'gstreamer1.0-plugins-good', 'gstreamer1.0-pulseaudio',
 'gstreamer1.0-plugins-ugly', 'gstreamer1.0-tools',
 'libgstreamer1.0-dev'].each do |package_name|
  package package_name do
    retries 3
  end
end

gw_version = node[:kaldi_asr][:gstreamer_worker_version]
ark 'gstreamer-worker' do
  url "https://github.com/yifan/gst-kaldi-nnet2-online/archive/v#{gw_version}.tar.gz"
  version gw_version
  checksum node[:kaldi_asr][:gstreamer_worker_checksum]
  path '/opt'
  home_dir node[:kaldi_asr][:gstreamer_worker_root]
end

python_virtualenv "#{node[:kaldi_asr][:gstreamer_worker_root]}" do
  options '--system-site-packages'
  action :create
end

bash 'build-gstreamer-worker' do
  cwd node[:kaldi_asr][:gstreamer_worker_root]
  code <<-EOH
    cd src
    KALDI_ROOT=#{node[:kaldi_asr][:kaldi_root]} make depend
    KALDI_ROOT=#{node[:kaldi_asr][:kaldi_root]} make
  EOH
end


model_name = "#{node[:kaldi_asr][:model_name]}"
model_url = "#{node[:kaldi_asr][:model_url]}"
model_dir = "#{node[:kaldi_asr][:model_dir]}/#{model_name}"
directory "#{model_dir}" do
  recursive true
  action :create
end

output_dir = "#{node[:kaldi_asr][:output_dir]}/#{model_name}"
directory "#{output_dir}" do
  recursive true
  action :create
end

tar_extract model_url do
  target_dir model_dir
  creates "#{model_dir}/conf"
end

template "#{model_dir}/model.yaml" do
  source "#{model_dir}/model.yaml.template"
  local true
  variables ({
    :model_path => model_dir,
    :output_path => output_dir,
  })
end

template "#{model_dir}/conf/ivector_extractor.conf" do
  source "#{model_dir}/conf/ivector_extractor.conf.template"
  local true
  variables ({
    :model_path => model_dir,
    :output_path => output_dir,
  })
  only_if 
end

virtualenv = node[:kaldi_asr][:gstreamer_server_root]
gs_root = node[:kaldi_asr][:gstreamer_server_root]
gs_port = node[:kaldi_asr][:gstreamer_server_port]

supervisor_service "kaldi-gstreamer-worker-#{model_name}-supervisor" do
  action [:enable, :start]
  autostart true

  environment 'LD_LIBRARY_PATH' => "#{node[:kaldi_asr][:kaldi_root]}/tools/openfst/lib",
              'GST_PLUGIN_PATH' => "#{node[:kaldi_asr][:gstreamer_worker_root]}/src"

  command <<-EOH
    #{virtualenv}/bin/python \
    #{gs_root}/kaldigstserver/worker.py \
    -u ws://localhost:#{gs_port}/worker/ws/speech \
    -f #{node[:kaldi_asr][:gstreamer_worker_nthread]} \
    -c #{model_dir}/model.yaml
  EOH
end
