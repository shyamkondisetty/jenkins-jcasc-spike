#!/bin/bash

helm upgrade --install jenkinsdemo jenkinsci/jenkins -n ci --values values.yaml
