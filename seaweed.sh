#!/bin/bash

docker run -d -it chrislusf/seaweedfs server
docker exec xxxxx /bin/sh
$ /usr/bin/weed benchmark -c 4 -size 1024 -n 262144 -fsync
