#!/bin/bash

pkill -9 service

./service 127.0.0.1 9999 >> /home/ubuntu/service.log 2>&1 &