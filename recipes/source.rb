#
# Cookbook Name:: kaldi-asr
# Recipe:: source
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

include_recipe 'apt'

['automake', 'libtool', 'subversion', 'gcc', 'g++', 'git',
 'libatlas-dev', 'libatlas-base-dev', 'zlib1g-dev'].each do |package_name|
  package package_name do
    action :install
    retries 3
  end
end

# gcc 4.8.2 has a bug. for kaldi to work, we need to upgrade it
if "test $(gcc --version | head -1 | awk '{print $NF;}') = '4.8.2'"
  apt_repository 'ubuntu-toolchain' do
    uri 'ppa:ubuntu-toolchain-r/test'
    components ['main']
    distribution 'trusty'
  end
  ['gcc-4.9', 'g++-4.9'].each do |gcc_package|
    package gcc_package do
      action :install
    end
  end
  execute 'update-alternatives-gcc' do
    command 'update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60'
  end
  execute 'update-alternatives-g++' do
    command 'update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 60'
  end
end

if node[:kaldi_asr][:with_gstreamer]
  ['libgstreamer1.0-dev', 'gstreamer1.0-plugins-good',
   'gstreamer1.0-tools'].each do |package_name|
    package package_name do
      action :install
      retries 3
    end
  end
end

kaldi_version = node[:kaldi_asr][:kaldi_version]
ark 'kaldi' do
  url "https://github.com/yifan/kaldi/archive/v#{kaldi_version}.tar.gz"
  version kaldi_version
  checksum node[:kaldi_asr][:kaldi_checksum]
  path '/opt'
  home_dir node[:kaldi_asr][:kaldi_root]
end

# fix gfortran library problem with ubuntu 14.04
link '/usr/lib/libgfortran.so' do
  owner 'root'
  to '/usr/lib/x86_64-linux-gnu/libgfortran.so.3'
  not_if 'test -L /usr/lib/libgfortran.so'
end

bash 'build-kaldi' do
  cwd node[:kaldi_asr][:kaldi_root]
  code <<-EOH
    cd tools
    make
    cd ../src
    ./configure --shared
    make depend
    make
    EOH
  action :run
  not_if "test -d #{node[:kaldi_asr][:kaldi_root]}/src/lib"
end

bash 'build-kaldi-gstreamer' do
  only_if { node[:kaldi_asr][:with_gstreamer] == true }
  cwd node[:kaldi_asr][:kaldi_root]
  code 'cd src; make ext'
  action :run
end
