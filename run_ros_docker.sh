#!/bin/bash

# Copyright (c) 2017, NVIDIA CORPORATION. All rights reserved.
# Full license terms provided in LICENSE.md file.

NCSDK_NAME=$1
  if [[ -z "${ROS_NAME}" ]]; then
    ROS_NAME=ROS_KINETIC
fi

HOST_DATA_DIR=$2
if [[ -z "${HOST_DATA_DIR}" ]]; then
    HOST_DATA_DIR=/data/
fi

CONTAINER_DATA_DIR=$3
if [[ -z "${CONTAINER_DATA_DIR}" ]]; then
    CONTAINER_DATA_DIR=/data/
fi

echo "Container name    : ${ROS_NAME}"
echo "Host data dir     : ${HOST_DATA_DIR}"
echo "Container data dir: ${CONTAINER_DATA_DIR}"
NCSDK_ID=`docker ps -aqf "name=^/${ROS_NAME}$"`
if [ -z "${ROS_ID}" ]; then
    echo "Creating new redtail container."
    xhost +
    nvidia-docker run -it --privileged --network=host -v /dev:/dev -v ${HOST_DATA_DIR}:${CONTAINER_DATA_DIR}:rw -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix${DISPLAY} -p 14556:14556/udp --name=${ROS_NAME} px4-ros:kinetic-v1 bash
else
    echo "Found redtail container: ${ROS_ID}."
    # Check if the container is already running and start if necessary.
    if [ -z `docker ps -qf "name=^/${ROS_NAME}$"` ]; then
        xhost +local:${ROS_ID}
        echo "Starting and attaching to ${ROS_NAME} container..."
        docker start ${ROS_ID}
        docker attach ${ROS_ID}
    else
        echo "Found running ${ROS_NAME} container, attaching bash..."
        docker exec -it ${ROS_ID} bash
    fi
fi
