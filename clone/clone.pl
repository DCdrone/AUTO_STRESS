#!/usr/bin/perl
################################################################
#       This script is for clonning disk temporary             #
#	We should be very careful when we use this script to do    #
#some clonning to prevent from cranshing of NAS. Especially, we#
#only support at most 1 threads at the same time and we        #
#strongly suggest that you do it step by step.                 #
#version = 0.1                                                 #
#author = DC                                                   #
#owned by UnionPay                                             #
################################################################

use strict;
use warnings;

#my $sys_disk = $ARGV[0];
#my $data_disk = $ARGV[1];
#my $des_file= $ARGV[2];

my $sys_disk = "/dsx01/instances/instance-000006a4/disk";
my $data_disk = "/dsx01/instances_data/instance-000006a4/disk.local";
my $des_file= "lists";

if(@ARGV>0){
    if(@ARGV != 3){ die("If you want to use this method to give use parameters, you need to be responsible! Example: ./clone.pl \$sys_disk \$data_disk \$destination_file\n"); }
    $sys_disk = $ARGV[0];
    $data_disk = $ARGV[1];
    $des_file= $ARGV[2];
}

open(FILE,"<",$des_file) or die("We cannot read the destination file!\n");
my @des = <FILE>;
foreach(@des){
	chomp;
	if($_ eq ""){ next; }
	my @tmp =  split;
	my $disk = $tmp[0];
	my $disk2 = $tmp[1];
	my $hostname = $tmp[2];
	my $biz_ip = $tmp[3];
	my $mng_ip = $tmp[4];
	my $gateway = $tmp[5];
	#print "Disk:$disk\tDisk2:$disk2\tHostname:$hostname\tBiz_IP:$biz_ip\tGateway:$gateway\tMng_IP:$mng_ip\n";
	my $time = localtime;
	print "........\n******************************************************************************\n";
	print "[$time][INFO] We are now begining the clonning of $hostname whos localtion is $disk and $disk2\n";
	#sleep 1;

	#Step 1: Backup the disk file and overwrite it!
	if(-e "$disk"){
		print "When we backup the original system disk, you just wait ....................\n";
		my $tmp = `mv $disk "$disk\.bak"`;
		if($tmp){print "[$time][ERROR] We failed to backup $disk\n";}
		print "When we are cloning the system disk, you just wait again ....................\n";
		$tmp = `cp $sys_disk $disk`;	
		chomp($tmp);
		if($tmp){$time=localtime;print "[$time][ERROR] We faild to overwrite $disk\n";last;}
		$time = localtime;
		print "[$time][INFO] We clonned the system disk successfully!\n";
	}
	else {
		$time = localtime;
		print "[$time][ERROR] We cannot find the disk of $hostname whos location should be $disk\n";
		last;
	}

	#Step 2: Backup the data disk and overwrite it!
	if($data_disk){
		if($disk2 eq "0"){last;}
		if(-e "$disk2"){
			print "When we backup the original data disk.local, you just wait ....................\n";
			my $tmp = `mv $disk2 "$disk2\.bak"`;
        	if($tmp){print "[$time][ERROR] We failed to backup $disk2\n";}
		print "When we are cloning the data disk.local, you just wait again ....................\n";
        	$tmp = `cp $data_disk $disk2`;
        	chomp($tmp);
        	if($tmp){$time=localtime;print "[$time][ERROR] We faild to overwrite $disk2\n";last;}
			$time = localtime;
			print "[$time][INFO] We clonned the data disk successfully!\n";
		}
		else {
			$time = localtime;
        	print "[$time][ERROR] We cannot find the disk of $hostname whos data disk location should be $disk2\n";
        	last;
		}
	}

	
	#Step 3: Qemu-nbd the system disk and set hostname and ip
	my $tmp = `qemu-nbd -c /dev/nbd15 $disk 2>&1`;
	chomp($tmp);
	if($tmp eq ""){ $tmp = "OK"; }
	print "When qemu-nbd -c /dev/nbd15 $disk: ----> $tmp\n";
	$tmp = `kpartx -a /dev/nbd15 2>&1`;
	chomp($tmp);
	if($tmp eq ""){ $tmp = "OK"; }
	print "When kpartx -a /dev/nbd15: ----> $tmp\n";
	$tmp = `mkdir -p /tmp/tmpClone 2>&1`;
	chomp($tmp);
	if($tmp eq ""){ $tmp = "OK"; }
	print "When mkdir -p /tmp/tmpClone: ----> $tmp\n";
    	$tmp = `mount /dev/mapper/nbd15p1 /tmp/tmpClone/ 2>&1`;
	chomp($tmp);
	if($tmp eq ""){ $tmp = "OK"; }
	print "When mount /dev/mapper/nbd15p1: ----> $tmp\n";
	
	$tmp = `echo $hostname > /tmp/tmpClone/etc/HOSTNAME 2>&1`;
	chomp($tmp);
	if($tmp eq ""){ $tmp = "OK"; }
	print "When we set HOSTNAME $hostname: ----> $tmp\n";
	$tmp = `sed -i '/IPADDR/Is/.*/IPADDR=$biz_ip/' /tmp/tmpClone/etc/sysconfig/network/ifcfg-eth0`;
	chomp($tmp);
	if($tmp eq ""){ $tmp = "OK"; }
	print "When we set IP1 $biz_ip: ----> $tmp\n";
	if($mng_ip ne "0"){
		$tmp = `sed -i '/IPADDR/Is/.*/IPADDR=$mng_ip/' /tmp/tmpClone/etc/sysconfig/network/ifcfg-eth1`;
		chomp($tmp);
		if($tmp eq ""){ $tmp = "OK"; }
		print "When we set IP2 $mng_ip: ----> $tmp\n";
	}
	$tmp = `sed -i '/default/Is/.*/default $gateway - -/' /tmp/tmpClone/etc/sysconfig/network/routes`;
	chomp($tmp);
	if($tmp eq ""){ $tmp = "OK"; }
	print "When we set routes $gateway: ----> $tmp\n";
	$tmp = `umount /dev/mapper/nbd15p1 2>&1`;
	chomp($tmp);
	if($tmp eq ""){ $tmp = "OK"; }
	print "When we umount /dev/mapper/nbd15p1: ----> $tmp\n";
	sleep 1;
	$tmp = `kpartx -d /dev/nbd15 2>&1`;
	chomp($tmp);
	if($tmp eq ""){ $tmp = "OK"; }
	print "When we kpartx -d /dev/nbd15: ----> $tmp\n";
	sleep 1;
	$tmp = `qemu-nbd -d /dev/nbd15 2>&1`;
	chomp($tmp);
	if($tmp =~ /disconnected/){ $tmp = "OK"; }
	print "When we qemu-nbd -d /dev/nbd15: ----> $tmp\n";


	#Step 4: We finished the job. Print successful info to clone.log and move on to next target
	$time = localtime;
	print "[$time][INFO] All things done! You could check it yourself!\n";
	open(FILE,">>clone.log");
	print FILE "[$time][INFO] HOSTNAME:$hostname DISK:$disk IP:$biz_ip was successfully been deployed!\n";
	close FILE;
	
}


