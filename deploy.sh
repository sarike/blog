#!/bin/bash

hexo generate
scp -r public root@188.166.250.2:/root/local/repos/timeflu.cn
