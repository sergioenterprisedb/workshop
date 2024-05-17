#!/bin/bash

export MINIO_ROOT_USER=admin
export MINIO_ROOT_PASSWORD=password
../minio server /home/ec2-user/minio_data/ --console-address ":9001"

