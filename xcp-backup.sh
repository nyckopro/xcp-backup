#!/bin/bash
# Copy virtual machine on state: running or not in SR Backup
# by nycko (nyckopro [at] gmail.com)
# version 1.0 (23/05/2012)

SRBACKUP_UUID="282669b5-77d4-ceea-4d1a-024ed9ad6a2b";
VM_UUID=$1;

case $1 in
	"-all")
		VM_UUIDs=$(xe vm-list power-state=running params=uuid --minimal);
		;;
	"")	echo "Uso: $0 [VM-UUID1,VM-UUID2... | -all]";
		echo "   -all: backup all virtual machines on state: running";
		exit;
		;;
	*)	VM_UUIDs=$1;
esac

VM_UUIDs=$(echo "$VM_UUIDs" | tr ',' ' ');
DATE=$(date +%Y%m%d_%H%M);

PATH_BACKUP="/var/run/sr-mount/$SRBACKUP_UUID";

for VM_UUID in "$VM_UUIDs";do
	echo "Backupeanding $VM_NAME [$VM_UUID]...";
	VM_NAME=$(xe vm-list uuid=$VM_UUID params=name-label --minimal);

	#Create temporary snapshot
	SNAPSHOT_UUID=$(xe vm-snapshot uuid=$VM_UUID new-name-label="snapshot_tmp_$VM_NAME");

	#Set not template
	xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAPSHOT_UUID;

	#Export snapshot to virtual machine
	xe vm-export uuid=$SNAPSHOT_UUID filename="$PATH_BACKUP/backup_$VM_NAME-$DATE.xva";

	#Delete tmp template
	xe vm-uninstall uuid=$SNAPSHOT_UUID force=true
done
