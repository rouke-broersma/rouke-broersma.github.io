#!/bin/bash

source common.sh

hugo --environment development --source "src" --noTimes --baseURL ${DEPLOY_URL}