#!/bin/bash
set -e

source {{devstack_location}}/functions
source {{devstack_location}}/functions-common

nova flavor-delete 42
nova flavor-create m1.nano 42 96 1 1

nova flavor-delete 84
nova flavor-create m1.micro 84 128 2 1

nova flavor-delete 451
nova flavor-create m1.heat 451 512 5 1

# Add DNS config to the private network
subnet_id=`neutron net-show private | grep subnets | awk '{print $4}'`
neutron subnet-update $subnet_id --dns_nameservers list=true 8.8.8.8 8.8.4.4

TEMPEST_CONFIG=/opt/stack/tempest/etc/tempest.conf

iniset $TEMPEST_CONFIG compute volume_device_name "sdb"
iniset $TEMPEST_CONFIG compute-feature-enabled rdp_console true
iniset $TEMPEST_CONFIG compute-feature-enabled block_migrate_cinder_iscsi False

iniset $TEMPEST_CONFIG scenario img_dir "{{devstack_location}}/files/images/"
iniset $TEMPEST_CONFIG scenario img_file "cirros.vhdx"
iniset $TEMPEST_CONFIG scenario img_disk_format vhd

IMAGE_REF=`iniget $TEMPEST_CONFIG compute image_ref`
iniset $TEMPEST_CONFIG compute image_ref_alt $IMAGE_REF

iniset $TEMPEST_CONFIG compute build_timeout 300
iniset $TEMPEST_CONFIG orchestration build_timeout 600
iniset $TEMPEST_CONFIG volume build_timeout 300
iniset $TEMPEST_CONFIG boto build_timeout 300

iniset $TEMPEST_CONFIG compute ssh_timeout 600
iniset $TEMPEST_CONFIG compute allow_tenant_isolation True
