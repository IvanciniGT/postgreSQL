#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. $SCRIPT_DIR/../etc/configuracion.properties

ssh -i $SCRIPT_DIR/../$KEY $USER@$HOST