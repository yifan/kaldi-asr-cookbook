# kaldi-asr-cookbook

Install KALDI speech recognition toolkit from github and gstream server and
worker

## Platforms

Ubuntu 14.04

## Dependent Cookbooks

* python
* supervisor
* ark
* apt

## Attributes

* `node['kaldi_asr']['kaldi_root']` - KALDI installation directory, default: /opt/kaldi
* `node['kaldi_asr']['gstreamer_server_root']` - GStreamer server installation directory, default: /opt/kaldi-gstreamer-server
* `node['kaldi_asr']['gstreamer_server_port']` - GStreamer server port, default: 8888
* `node['kaldi_asr']['gstreamer_worker_root']` - GStreamer worker installation directory, default: /opt/kaldi-gstreamer-worker
* `node['kaldi_asr']['with_gstreamer']` - set `false` to compile KALDI without GStreamer, set `true` for gstreamer recipes

## Recipes

This section describes the recipes in the bookbook and how to use them in your environment. These recipes will not use official repositories for KALDI and other components. It will use my own fork so that it will only need to download a faction of the data comparing to checking out full repository.

### source

Checkout KALDI from my fork on github and compile everything.

### gstreamer_server

Install my fork of kaldi-gstream-server and start it without `supervisor`

### gstreamer_worker

Install and start gstream worker

### default

Includes the `kaldi-asr::source` recipe by default.

## Usage

### kaldi_asr::default

Include `kaldi-asr` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[kaldi-asr::default]"
  ]
}
```

## License and Authors

Author:: Yifan Zhang (<yzhang@qf.org.qa>)

Please see licensing information in: [LICENSE](LICENSE)
