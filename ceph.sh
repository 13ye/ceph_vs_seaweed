#!/bin/bash

# 1. start monitor
:<<EOF
docker run -d \
    --net=host \
    -v /etc/ceph:/etc/ceph \
    -v /var/lib/ceph/:/var/lib/ceph/ \
    -e MON_IP=192.168.103.119 \
    -e CEPH_PUBLIC_NETWORK=192.168.103.0/24 \
    ceph/daemon mon
EOF

# 2. start osd
docker run  \
    --net=host \
    -v /etc/ceph:/etc/ceph \
    -v /var/lib/ceph/:/var/lib/ceph/ \
    -v /dev/:/dev/ \
    --privileged=true \
    -e OSD_FORCE_ZAP=1 \
    -e OSD_DEVICE=/dev/vdd \
    ceph/daemon osd_directory

# 3. start server (mds)
:<<EOF
docker run -d --net=host \
    -v /var/lib/ceph/:/var/lib/ceph \
    -v /etc/ceph:/etc/ceph \
    -e CEPHFS_CREATE=1 \
    ceph-daemon mds
EOF


### Using ceph-deploy
debian10.10
apt install lvm2
python3 -m pip install ceph-deploy
mkdir ceph_cluster && cd ceph_cluster 
ceph-deploy new {hostname}
echo "osd crush chooseleaf type = 0" >> ceph.conf
echo "osd pool default size = 1" >> ceph.conf
echo "osd journal size = 100" >> ceph.conf
ceph-deploy install {hostname}
ceph-deploy mon create {hostname}
ceph-deploy gatherkeys {hostname}
ceph-deploy admin {hostname}
# prepare disk
ceph-deploy osd create --data /dev/vdd {hostname}
ceph-deploy osd list {hostname}
# mds
ceph-deploy mds create {hostname}


ceph health
ceph -s
ceph osd tree

# benchmark
ceph osd pool create rbdbench 128 128
rados bench -p scbench -t 4 -b 1024 10 write --no-cleanup


