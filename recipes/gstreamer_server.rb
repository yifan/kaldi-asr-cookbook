#
# Cookbook Name:: kaldi-asr
# Recipe:: gstreamer_server
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
include_recipe 'python'
include_recipe 'python::pip'
include_recipe 'python::virtualenv'
include_recipe 'supervisor'
include_recipe 'ark'

package 'python-gobject'

gs_version = node[:kaldi_asr][:gstreamer_server_version]
ark 'kaldi-gstreamer-server' do
  owner node[:kaldi_asr][:user]
  url node[:kaldi_asr][:gstreamer_server_package_url]
  version gs_version
  checksum node[:kaldi_asr][:gstreamer_server_checksum]
  home_dir node[:kaldi_asr][:gstreamer_server_root]
end

python_virtualenv "#{node[:kaldi_asr][:gstreamer_server_root]}" do
  owner node[:kaldi_asr][:user]
  options '--system-site-packages'
  action :create
end

python_pip 'ws4py' do
  user node[:kaldi_asr][:user]
  version '0.3.2'
  virtualenv node[:kaldi_asr][:gstreamer_server_root]
end

['pyyaml', 'tornado'].each do |python_module|
  python_pip python_module do
    user node[:kaldi_asr][:user]
    virtualenv node[:kaldi_asr][:gstreamer_server_root]
  end
end

virtualenv = node[:kaldi_asr][:gstreamer_server_root]
gs_root = node[:kaldi_asr][:gstreamer_server_root]
gs_params = node[:kaldi_asr][:gstreamer_server_params]
supervisor_service 'kaldi-gstreamer-server-supervisor' do
  user node[:kaldi_asr][:user]
  action [:enable]
  autostart true
  autorestart true
  command <<-EOH
    #{virtualenv}/bin/python \
    #{gs_root}/kaldigstserver/master_server.py \
    #{gs_params} \
    --port=#{node[:kaldi_asr][:gstreamer_server_port]}
  EOH
  not_if "#{node[:kaldi_asr][:gstreamer_server_disabled]}"
end
