#!/usr/bin/perl -w
use strict;
use warnings;


BEGIN {
        push (@INC,'modules/library');
}
my $menu = "******************************************************************************
*                            China UnionPay                                  *
*                            Fault Simulator                                 *
* This utility will guid you to either stress your servers or create some    *
* failure in your facilities. You are supposed to be very careful when you do*
* anthing on the list.                                                       *
******************************************************************************
        1----CPU\t2----MEMORY\t3----FS_FULL\t4----DISK_IO
        5----SHUTT DOWN\t6----FS_LOST\t7----NETCARD\t8----ROUTE LOST
        9----NETIO\t10---TIME\t11---IPC\t12---FILE LOST
        13---PORT\t14---PROCESS\t15---TABLE LOCK\t16---DB STOPPED
        17---CONNECT FULL
                             Q----QUIT('q')
";

my $os = `uname 2>&1`;
my $os_n;
if ($os =~ "AIX") { $os_n = 1;}
elsif($os =~ "Linux") {$os_n = 2;}
else {$os_n =0 };
sub clear() {
		if ($os_n == 0) {system("cls");}
    elsif ($os_n == 1) {system("clear");}
    elsif ($os_n == 2) {system("clear");}
}

clear;

print "$menu";
print "Enter the type please: "; 

###########################################################################################################################                                        
while(<>){
    chomp;
    $_ = uc($_);
###########################################################################################################################
###          each line jumps in to another perl program which will simulate the related problem                ############
###########################################################################################################################
    if ($_ eq 1) { system("perl ./each/cpu.pl");}
    elsif ($_ eq 2) { system("perl ./each/memory.pl");}
    elsif ($_ eq 3) { system("perl ./each/fs_full.pl");}
    elsif ($_ eq 4) { system("perl ./each/disk_io.pl");}
    elsif ($_ eq 5) { system("perl ./each/shutt_down.pl");}
    elsif ($_ eq 6) { system("perl ./each/fs_lost.pl");}
    elsif ($_ eq 7) { system("perl ./each/netcard.pl");}
    elsif ($_ eq 8) { system("perl ./each/route.pl");}
    elsif ($_ eq 9) { system("perl ./each/netio.pl");}
    elsif ($_ eq 10) { system("perl ./each/time.pl");}
    elsif ($_ eq 11) { system("perl ./each/ipc.pl");}
    elsif ($_ eq 12) { system("perl ./each/file_lost.pl");}
    elsif ($_ eq 13) { system("perl ./each/port.pl");}
    elsif ($_ eq 14) { system("perl ./each/process.pl");}
    elsif ($_ eq 15) { system("perl ./each/db_lock.pl");}
    elsif ($_ eq 16) { system("perl ./each/db_stop.pl");}
    elsif ($_ eq 17) { system("perl ./each/db_connect.pl");}

##############################################Exit this process############################################################
    elsif($_ eq "Q") {
        print "This simulator will be closed right now ................\n";
        sleep 1;
        last;
    }
##############################################Warn if wrong number is typed################################################
    else {print "Wrong Parameters!\n";sleep 1;}
    clear;
    print "$menu";
    print "Enter the type please: ";  
}
