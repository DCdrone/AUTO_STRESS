#!/usr/bin/perl

##################################################################################################
#    This script is to generate the neccessary information for clone.py. It will read the file   #
#of vservers and generate system disk path, data disk path, name, ips and gateway according to   #
#to the name of the server. You should list server names in file vservers and let this script    #
#do the left ugly things.                                                                        #
#version = 0.1                                                                                   #
#author = DC                                                                                     #
#owned = UnionPay                                                                                #
##################################################################################################

use strict;
use warnings;

my @dbip = ("146.240.104.7");
my @user = ("nova");
my @passwd = ("nova");
my @db = ("nova");

open(FILE,"<vservers");
my @servers = <FILE>;
close FILE;
system("rm lists");

my $found = "0";
for(my $i=0;$i<@dbip;$i++){
    my $dbip = $dbip[$i];
    my $user = $user[$i];
    my $passwd = $passwd[$i];
    my $db = $db[$i];
    if($found == 1){ last; }

foreach(@servers){
    chomp;
    if($_ eq ""){ next; }
    my $vname;
    my $state;
    my $id;
    my $suffix;
    my $data;
    my $instance;
    my $sys_disk;
    my $data_disk = "0";
    my $biz_ip;
    my $mng_ip = "0";
    my $gateway;
    my $network_id;

#Step 1: Let's get the state and other things that needed for vserver. If the server is active, the script will stop!

    my @content = qx(mysql -h "$dbip" -u"$user" -p"$passwd" -e "use $db;select hostname,vm_state,id,instance_name_suffix,ephemeral_gb from instances where deleted='0' and hostname='$_';");
    if(@content>1){ $found = 1; }
    for(my $i=1;$i<@content;$i++){
        my @tmp = split(/\s/,$content[$i]);
	$vname = $tmp[0];
	$state = $tmp[1];
	if($state eq "active"){ die("[ERROR] $vname is now active. This $vname will not continue!\n");}
	$id = $tmp[2];
	$suffix = $tmp[3];
	$data = $tmp[4];
	$instance = sprintf("%x",$id);
        my $n = length("$instance");
        if($n>8) {die("The instance id error!");}
        for(my $i=0;$i<8-$n;$i++){
            $instance = "0"."$instance";
        }
        $instance = "instance-"."$instance";
        if(uc($suffix) eq "NULL") {$suffix="";}
	else {$suffix = "_$suffix";}
        $instance .= "$suffix";
        chomp($instance);
	$sys_disk = "/dsx01/instances/$instance/disk";
	if($data){ $data_disk = "/dsx01/instances_data/$instance/disk.local";}
	else { $data_disk = "0"; }
    }

#Step 2: Let's get the biz_ip and mng_ip of the server

    @content = qx(mysql -h "$dbip" -u"$user" -p"$passwd" -e "use $db;select address,network_id from fixed_ips where instance_id=$id order by virtual_interface_id;");
    if(@content>3){ die("[ERROR] $vname has more than 2 ip!\n"); }
    for(my $i=1;$i<@content;$i++){
        my @tmp = split(/\s/,$content[$i]);
	$network_id = $tmp[1];
	chomp($network_id);

#Step 3: Let's get the gateway of the server

	my @tmp2 = qx(mysql -h "$dbip" -u"$user" -p"$passwd" -e "use $db;select hd_gateway from networks where id='$network_id';");
	if($i == 1){ $biz_ip = $tmp[0];$gateway = $tmp2[1];chomp($gateway);}
	if($i == 2){ $mng_ip = $tmp[0];}
    }
    print "$sys_disk $data_disk $vname $biz_ip $mng_ip $gateway\n";

#Step 4: Let's put these information to lists which is needed by clone.py to do its job!

    open(FILE,">>lists");
    print FILE "$sys_disk $data_disk $vname $biz_ip $mng_ip $gateway\n";
    close FILE;
}

}
