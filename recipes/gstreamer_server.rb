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

include_recipe 'poise-python'
include_recipe 'supervisor'
include_recipe 'git'
include_recipe 'ark'

package 'python-gobject'

git "#{node[:kaldi_asr][:gstreamer_server_root]}" do
  repository 'https://github.com/yifan/kaldi-gstreamer-server.git'
  revision 'bf0b35fb857799fb4aebe99a905458f1e53a9f98'
  depth 1
end

python_virtualenv '/opt/env'
pip_requirements "#{node[:kaldi_asr][:gstreamer_server_root]}"

virtualenv = '/opt/env'
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

