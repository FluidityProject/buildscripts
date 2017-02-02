#!/bin/sh

apt-add-repository ppa:fluidity-core/ppa
apt-get update
apt-get -y install fluidity-dev libsupermesh-dev fluidity
