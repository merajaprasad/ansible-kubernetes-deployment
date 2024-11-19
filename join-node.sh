#!/bin/bash
kubeadm join 172.31.21.81:6443 --token htt29u.7m6naizur6k964kr \ --discovery-token-ca-cert-hash sha256:40b6576ae34d7c0d661b62676d541c22d8812bf3b6ed99a49c3a534ba62c68d5 --v=5
