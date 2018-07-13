#!/bin/env bash
#intended on being interpolated by terraform

sleep 15

stop ecs

yum -y install nfs-utils awslogs amazon-efs-utils
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
easy_install pip
rm -rf /var/lib/ecs/data/ecs_agent_data.json || true
echo "ECS_CLUSTER=${ecs_cluster_name}" >> /etc/ecs/ecs.config
echo 'ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]' >> /etc/ecs/ecs.config

echo "##### /etc/ecs/ecs.config #################"
cat /etc/ecs/ecs.config

## echo 'OPTIONS="$${OPTIONS} --storage-opt dm.basesize=70GB"' >> /etc/sysconfig/docker
## vgextend docker $${ebs_vol_device_name} #remove double dollar signs if uncommenting
## lvextend -L+$${ebs_vol_size}G /dev/docker/docker-pool #remove double dollar signs if uncommenting
## /etc/init.d/docker restart

cat << EOF >> /etc/awslogs/awslogs.conf
[/var/log/cloud-init-output.log]
file = /var/log/cloud-init-output.log
log_group_name = myenv-myproj-myorg
log_stream_name = myorg-myproj-myenv
datetime_format = %Y-%m-%dT%H:%M:%SZ

EOF

start awslogs

[ -n "${efs_volume_id}" ] && {
    echo "efs volume id ${efs_volume_id}"
    [ -n "${efs_local_path}" ] && {
        echo "${efs_local_path}"
        [ -d ${efs_local_path} ] || {
            echo "Making ${efs_local_path}"
            mkdir -p ${efs_local_path}
        }
        echo "${efs_volume_id}:/ /mnt/efs efs tls,_netdev 0 0" >> /etc/fstab
        mount -a -t efs defaults
        [ -d ${efs_local_path}/jenkins ]  || {
            echo "making dir ${efs_local_path}/jenkins"
            mkdir ${efs_local_path}/jenkins
            chown 1000:1000 ${efs_local_path}/jenkins
        }
    }
}

mount
df -kh

start ecs
