#
# Cookbook Name:: kaldi-asr
# Recipe:: gstreamer_arabic
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
include_recipe 'kaldi-asr::gstreamer_worker'
include_recipe 'python'
include_recipe 'python::pip'
include_recipe 'python::virtualenv'
include_recipe 'supervisor'
include_recipe 'tar'

model_dir = "#{node[:kaldi_asr][:model_dir]}/arabic"
directory "#{model_dir}" do
  recursive true
  action :create
end

output_dir = "#{node[:kaldi_asr][:output_dir]}/arabic"
directory "#{output_dir}" do
  recursive true
  action :create
end

tar_extract 'https://qcristore.blob.core.windows.net/public/asr/models/arabic.tar.gz' do
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

supervisor_service 'kaldi-gstreamer-worker-arabic-supervisor' do
  action [:enable, :start]
  autostart true

  environment 'LD_LIBRARY_PATH' => "#{node[:kaldi_asr][:kaldi_root]}/tools/openfst/lib",
              'GST_PLUGIN_PATH' => "#{node[:kaldi_asr][:gstreamer_worker_root]}/src"

  command <<-EOH
    #{virtualenv}/bin/python \
    #{gs_root}/kaldigstserver/worker.py \
    -u ws://localhost:#{gs_port}/worker/ws/speech \
    -c #{model_dir}/model.yaml
  EOH
end
