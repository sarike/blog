#!/bin/bash

hexo generate
scp -r public/* root@timefly.cn:/var/www/timefly.cn/
