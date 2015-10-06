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
