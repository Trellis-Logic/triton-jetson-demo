# Overview

This repo demonstrates the use of triton inference server with deepstream
for the purpose of dynamic model reload.

It uses the [peoplenet](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/tao/models/peoplenet) model
with a deepstream pipeline, and demonstrates the ability to load one of two different
[versions](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/tao/models/peoplenet/version) available
without stopping the deepstream pipeline.

# Usage

These steps are tested on a Nvidia Jetson target running Jetpack 6.2 and Deepstream 7.1

1. Connect a camera to the Jetson (or, optionally change the deepstream source file to
use the file input instead)
2. Run `tao_download_and_convert_to_plan.sh`, following instructions to install necessary
dependencies.  This will download the tao files from NVIDIA and prepare a local directory
with extracted and converted contents suitable for use with this demo.
3. Run `setup_model_repo_with_version.sh $version` to setup the model repo with the
desired peoplenet version based on the versions listed in the [environment.sh](environment.sh) file.
Running with no arguments will provide a list of supported versions.
4. Open a dedicated command window (or screen/tmux session) and run `start_triton_server.sh`
to start the triton server with configuration for the model location setup in the
previous step.  You can leave this window open to monitor the triton server.
5. Open a command window on a session attached to a UI screen and run `start_deepstream_pipeline.sh`
to start the deepstream pipeline.
6. Open a command window and run `get_model_stats.sh`.  Note that the version printed here should
match the version of the model loaded in the `setup_model_repo_with_version.sh` step.
7. With the pipeline still running, setup the model repo with a new model version using the
`setup_model_repo_with_version.sh` script.
8. With the pipeline still running, reload the model on the inference server using the
`reload_model_on_server.sh` script.  You should notice:
  * The triton server should note a changed version.
  * The pipeline should continue running, now with the updated model.
  * The version reported by `get_model_stats.sh` will match the version of the newly loaded model.

# Artificially corrupting a model

In order to more obviosly show the difference in model reload, you can use the `clobber_model.py`
script to corrupt one of the input models.

* Run the clobber_model.py script to corrupt the model weights, passing a path to the ngc_models
download .onnx file.
* Re-generate the model.plan file using the trtexec function in the download_and_convert_to_plan script.
