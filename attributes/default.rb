
default['kaldi_asr']['kaldi_version'] = '0.3.0'
default['kaldi_asr']['kaldi_checksum'] = '74450f7656247c14e92a767f18ed1615ef96dd7ba3573e59d0c071516325203c'
default['kaldi_asr']['kaldi_root'] = '/opt/kaldi'
default['kaldi_asr']['model_dir'] = '/opt/model'
default['kaldi_asr']['output_dir'] = '/var/spool/asr'

default['kaldi_asr']['gstreamer_server_version'] = '0.1.9'
default['kaldi_asr']['gstreamer_server_package_url'] =   "https://github.com/yifan/kaldi-gstreamer-server/archive/v#{default[:kaldi_asr][:gstreamer_server_version]}.tar.gz"
#default['kaldi_asr']['gstreamer_server_checksum'] = '6d740268f5be519ee0c3603e52c8ead4313a07d0ece561009c472e57acbf8666'
default['kaldi_asr']['gstreamer_server_checksum'] = '42dd1ead6d0aa9bed200c50ca80123876a870a5be91ed91ab00e198b52d3cec4'
default['kaldi_asr']['gstreamer_server_root'] = '/opt/kaldi-gstreamer-server'
default['kaldi_asr']['gstreamer_server_port'] = '8888'

default['kaldi_asr']['gstreamer_worker_version'] = '0.1.91'
default['kaldi_asr']['gstreamer_worker_checksum'] = '69ad9a150444f00717e4f601416df9b372bdcbf947286d1700caf0c4a7f94d2b'
default['kaldi_asr']['gstreamer_worker_root'] = '/opt/kaldi-gstreamer-worker'
default['kaldi_asr']['gstreamer_worker_nthread'] = 2

default['kaldi_asr']['model_name'] = 'arabic'
default['kaldi_asr']['model_url'] = 'https://qcristore.blob.core.windows.net/public/asr/models/arabic.tar.gz'

default['kaldi_asr']['with_gstreamer'] = true

# a user account to run jobs and own files
default['kaldi_asr']['user'] = 'asruser'
default['kaldi_asr']['group'] = 'asruser'
