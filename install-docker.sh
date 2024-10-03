#!/bin/bash
sudo apt install docker.io -y
sudo chmod 777 /var/run/docker.sock
sudo usermod -aG docker $USER

