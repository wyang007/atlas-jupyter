#!/bin/bash
PYTHON_VER=$1
CONFIG_FILE=$2
if [ -e ${HOME}/notebooks/.user_setups ]; then
    source ${HOME}/notebooks/.user_setups
fi

export PYTHONPATH=$PYTHONPATH:/usr/lib/python2.7/site-packages:/usr/lib64/python2.7/site-packages

exec python${PYTHON_VER} -m ipykernel -f ${CONFIG_FILE}
