@echo off

::https://docs.openshift.com/container-platform/4.10/post_installation_configuration/machine-configuration-tasks.html

::For check pids limit on node
:: oc debug node/$NODE_NAME
:: chroot /host
:: cgroup=$(awk -F: '/:pids:/{print $3}' /proc/self/cgroup)
:: cat /sys/fs/cgroup/pids/"${cgroup}"/pids.max


::oc get ctrcfg
::oc get mc | grep container

oc create -f machineconfiguration.yaml
::Need wait, while nodes will restart

:: Verify that the CR (ContainerRuntimeConfig) is created:
:: oc get ContainerRuntimeConfig
::
:: Check that a new containerruntime machine config is created:
:: oc get machineconfigs | grep containerrun
::
:: Monitor the machine config pool until all are shown as ready:
:: oc get mcp worker
::
::
:: Wait while nodes will be ready
::
::
:: Verify that the settings were applied in CRI-O:
:: oc debug node/<node_name>
::   chroot /host
::   crio config | grep 'pids_limit'
::
::
:: Check in pod terminal pids count
::  cat /sys/fs/cgroup/pids/pids.current