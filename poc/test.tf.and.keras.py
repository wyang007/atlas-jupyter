# use CUDA_VISIBLE_DEVICES to limit the script to run on the available GPUs

import tensorflow as tf
#tf.test.is_gpu_available() # True/False
tf.config.list_physical_devices()

# Or only check for gpu's with cuda support
#tf.test.is_gpu_available(cuda_only=True) 
tf.config.list_physical_devices('GPU')

import keras.backend.tensorflow_backend as tfback
print("tf.__version__ is", tf.__version__)
print("tf.keras.__version__ is:", tf.keras.__version__)

# because experimental_list_devices is removed from tensorflow is removed from tensorflow
# https://github.com/keras-team/keras/issues/13684
def _get_available_gpus():
    """Get a list of available gpu devices (formatted as strings).

    # Returns
        A list of available GPU devices.
    """
    #global _LOCAL_DEVICES
    if tfback._LOCAL_DEVICES is None:
        devices = tf.config.list_logical_devices()
        tfback._LOCAL_DEVICES = [x.name for x in devices]
    return [x for x in tfback._LOCAL_DEVICES if 'device:gpu' in x.lower()]

tfback._get_available_gpus = _get_available_gpus

assert len(tfback._get_available_gpus()) > 0
