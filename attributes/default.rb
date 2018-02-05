
default['kaldi_asr']['kaldi_version'] = '0.3.1'
default['kaldi_asr']['kaldi_checksum'] = 'b78305c29c04ef3c8e2bf3072ad7b357a6bf6752ed225ec193d87ddb87967e6f'
default['kaldi_asr']['kaldi_root'] = '/opt/kaldi'
default['kaldi_asr']['model_dir'] = '/opt/model'
default['kaldi_asr']['output_dir'] = '/var/spool/asr'

default['kaldi_asr']['gstreamer_server_root'] = '/opt/kaldi-gstreamer-server'
default['kaldi_asr']['gstreamer_server_ip'] = 'localhost'
default['kaldi_asr']['gstreamer_server_port'] = '8888'
default['kaldi_asr']['gstreamer_server_disabled'] = false

default['kaldi_asr']['gstreamer_worker_version'] = '0.2.5'
default['kaldi_asr']['gstreamer_worker_checksum'] = '88e3e8e7b75cd7edaa83f97d72dbf740de6cdd986ca5467ccb3a3fc0103214cd'
default['kaldi_asr']['gstreamer_worker_root'] = '/opt/kaldi-gstreamer-worker'
default['kaldi_asr']['gstreamer_worker_nthread'] = 1
default['kaldi_asr']['gstreamer_worker_lang'] = 'none'

default['kaldi_asr']['model_name'] = 'arabic'
default['kaldi_asr']['model_url'] = 'https://qcristore.blob.core.windows.net/public/asr/models/arabic.tar.gz'

default['kaldi_asr']['with_gstreamer'] = true

# a user account to run jobs and own files
default['kaldi_asr']['user'] = 'asruser'
default['kaldi_asr']['group'] = 'asruser'

default['kaldi_asr']['dnsname'] = 'asr.qcri.org'
