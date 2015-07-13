# UP_KER.pm
#
# Copyright (c) 2000 - 2014 China UnionPay. All rights reserved.
# This program is used to manipulate AIX server.
#
# mod::name= UP_FILE.pm
# mod::desc= Perl package for all OS to complete tasks that are
#            useful for servers' wide configurations.
# mod::author= Chen Chen
# mod::cvs= $Id: /
# mod::changed= $Date: 2014/09/25 $
# mod::modusr= $Author: Chen $
# mod::notes=
# mod::todo=
#            1. Need to collect the various configuration settings in order
#               to allow us to set up the boxes correctly.
#
# mod::tasks=
#
#
#           19. Make module stand alone without reference to other
#               modules.
#****************************************************************************
package UP_KER;

use UP_USERS;
use UP_NETWORK;
use UP_SYSTEM;
use Socket;
use IO::Handle;
use POSIX qw(WNOHANG);
use Net::Telnet;

our $TEST_PASS = 0;
our $TEST_FAIL = 1;
our $os = 0;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Set this to point out the package name.
#            
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
our $package = "UP_KER";
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Every key's value is a reference to an array. The second number of the array
# means whether it should be dispalyed on screen.
#            
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
our %info = (warning=>[0,1],error=>[1,1]);

sub info($$){
   my @keys = keys %info;
   my $type;
   foreach (@keys){
	if ($_[0]==$info{$_}->[0]){
		$type = $_;
	}
   }
   if ($info{$type}->[1] == 1){
	print "$type: \[$package\]->$_[1]\n";
   }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : set_parameters
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub set_parameters($%){
    my $self = shift;
    my %hash = @_;
    my @keys = keys %$self;
    my @a = keys %hash;
    
    while ( my ($key,$value) = each %hash ) {	
        my $check = 0;	
	foreach (@keys){
		if ("$key" eq "$_"){ $self->{"$key"} = $value; $check = 1;}
	}
	if ($check == 0){
	info(1,"Wrong parameters!");
	return $TEST_FAIL;		
	}
    }	
    return $TEST_PASS;   	
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : new
# Desc     : Base class constructor for UP_AIX
# Args     :
#              1. (SCALAR)    :
#              2. (HASH REF)  :
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub new($\%)
{
    my ($class, %args) = @_;
    my $self = bless {}, ref($class) || $class;
    $self->_init(%args);
		my $os1 = `uname 2>&1`;
		if ($os1 =~ "AIX") { $os = 3;}
		elsif($os1 =~ "Linux") {$os = 2;}
		else {$os1 =1 };
   
    return $self;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : _init
# Desc     : Helper function to Constructor <new>
#            Add some default value here.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (HASH)      : Hash containing initialization parameters
# Returns  :
#              none
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub _init(\%%)
{
    my ($self, %args) = @_;
    return if $self->{_init}{__PACKAGE__}++;
    $self -> {label} = $args{label} || "UP_KER";
    $self -> {netcard} = $args{netcard} || "";
    $self->{netmask} = $args{netmask} || "255.255.255.0";
    $self->{gateway} = $args{gateway} || "";
    $self->{ip}= $args{ip} || "";
    $self->{broadcast}= $args{broadcast} || "";
    $self->{p} = $args{p} || 6;
    $self->{time} = $args{time} || 10;
    $self->{mb} = $args{mb} || 64;
    $self->{rw} = $args{rw} || 80;
    $self->{disk} = $args{disk} || "";
    $self->{block} = $args{block} || "";
    $self->{rate} = $args{rate} || 80;
    $self->{path} = $args{path} || "/";
    $self->{time_error} = $args{time_error} || 0;
    $self->{fs} = $args{fs} || "";
    $self->{port} = $args{port} || 5277;
    $self->{file_path} = $args{file_path} || "";
    $self->{shm_id} = $args{shm_id} || "";
    $self->{rm_not} = $args{rm_not} || 1;
    $self->{db_user} = $args{db_user} || "";
    $self->{db_passwd} = $args{db_passwd} || "";
    $self->{db} = $args{db} || "";
    $self->{connect} = $args{connect} || "";
    $self->{table} = $args{table} || "";
    $self->{lock} = $args{lock} || "X";
    $self->{user} = $args{user} || "hacker";
    $self->{passwd} = $args{passwd} || "hacker";
    $self->{auto} = $args{auto} || 0;
    $self->{interface} = $args{interface} ||"";
    $self->{status} = $args{status} || "";
    $self->{time_length} = $args{time_length} || 0;

}

##
## User interface methods
##

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : netcard_detach
# Desc     : detach netcard
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : name of netcard
# Returns  :
#              $TEST_PASS:
#              $TEST_FAI
#              
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub netcard_detach($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    
    if ($os == 1) {
	
    }
    elsif ($os == 2){
	my $users = UP_USERS->new();
	if($users->checkusr(username=>"root")){ 
		info(1,"This action should be directed by root!");
		return $TEST_FAIL;
	}	
	if ($self->{netcard})  {
		my $net = UP_NETWORK->new();
		my @nic = $net->ifconfig(card=>$self->{netcard});
		my @route = $net->route();
		my @route2;
		foreach(@route){
			if($_->{if} eq $self->{netcard}){
				push(@route2,$_);
			}
		}
		my $time = localtime;
		open(LOG,">detach.log");
		print LOG "[$time][SUSE]:$nic[0]->{name} $nic[0]->{ip} $nic[0]->{netmask} $nic[0]->{broadcast}\n";
		close LOG;
		open(LOG,">>detach.log") or die("We cannot open the file detach.log!\n");
		foreach(@route2){
			print LOG "$_->{destination} $_->{gateway} $_->{netmask} $_->{flags} $_->{if}\n";
		}
		close LOG;
	    	my $stat = `ifconfig $self->{netcard} down 2>&1`;
		if($stat ne ""){
			open(LOG,">detach.log") or die("We cannot open the file detach.log!\n");
			print LOG "";
			close LOG;
			info(1,"We failed to make the $self->{netcard} down!");return $TEST_FAIL;}
		} 
	else {info(1,"Please input the netcard name!"); return $TEST_FAIL;}
    }
    elsif ($os == 3) {
	my $users = UP_USERS->new();
	if($users->checkusr(username=>"root")){ 
		info(1,"This action should be directed by root!");
		return $TEST_FAIL;
	}	
	if ($self->{netcard})  {
		my $net = UP_NETWORK->new();
		my @nic = $net->ifconfig(card=>$self->{netcard});
		my @route = $net->route();
		my @route2;
		foreach(@route){
			if($_->{if} eq $self->{netcard}){
				push(@route2,$_);
			}
		}
		my $time = localtime;
		open(LOG,">detach.log") or die("We cannot open the file detach.log!\n");
		print LOG "[$time][AIX]:$nic[0]->{name} $nic[0]->{ip} $nic[0]->{netmask} $nic[0]->{broadcast}\n";
		close LOG;
		open(LOG,">>detach.log") or die("We cannot open the file detach.log!\n");
		foreach(@route2){
			print LOG "$_->{destination} $_->{gateway} $_->{flags} $_->{if}\n";
		}
		close LOG;
		open(LOG,">>detach.history") or die("We cannot open the file detach.history!\n");
		print LOG "[$time][AIX]:$nic[0]->{name} $nic[0]->{ip} $nic[0]->{netmask} $nic[0]->{broadcast}\n";
		close LOG;
		open(LOG,">>detach.history") or die("We cannot open the file detach.history!\n");
		foreach(@route2){
			print LOG "$_->{destination} $_->{gateway} $_->{flags} $_->{if}\n";
		}
		close LOG;
	        my $stat = `ifconfig $self->{netcard} detach 2>&1`;
		chomp($stat);
		if($stat ne ""){
			open(LOG,">detach.log") or die("We cannot open the file detach.log!\n");
			print LOG "";
			close LOG;
			info(1,"We failed to detach the net interface card:$stat");
			return $TEST_FAIL;
	 	}
	} 
	else { info(1,"Please input the netcard name!"); return $TEST_FAIL;}
    }
    return $TEST_PASS;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : netcard_recover
# Desc     : recover netcard
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : name of netcard
#              3. (SCALAR)    : ip address
#              4. (SCALAR)    : value of netmask
#              5. (SCALAR)    : value of broadcast
# Returns  :
#              $TEST_PASS
#              $TEST_FAIL:
#              
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub netcard_recover($$$$$)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    
    if ($os == 1) {
	
    }
    elsif ($os == 2){
	my $users = UP_USERS->new();
	if($users->checkusr(username=>"root")){ 
		info(1,"This action should be directed by root!");
		return $TEST_FAIL;
	}	
	if ($self->{netcard} && $self->{netmask} && $self->{ip} && $self->{broadcast})  {
		system("ifconfig $self->{netcard} $self->{ip} netmask $self->{netmask} broadcast $self->{broadcast}");
	} 
	else { info(1,"Please input all arguments:netcard ip netmask broadcast"); return $TEST_FAIL;}
    }
    elsif ($os == 3) {
	my $users = UP_USERS->new();
	if($users->checkusr(username=>"root")){ 
		info(1,"This action should be directed by root!");
		return $TEST_FAIL;
	}	
	if($self->{auto} == 1){
		my $net = UP_NETWORK->new();
		my $status = 0;
		open(FILE,"<detach.log") or die("We cannot open the detach.log!\n");
		my @txt = <FILE>;
		close FILE;
		foreach(@txt){
			chomp;
                	if($_ eq ""){next;}
                	elsif($_ =~ /\[SUSE\]/) {
				info(1,"This is AIX not SUSE!");
				return $TEST_FAIL;
                	}
               		elsif($_ =~ /\[AIX\]/){
                       		$_ =~ s/\[.*:\s*//g;
                       		my @tmp = split;
	   			my $stat = `ifconfig $tmp[0] $tmp[1] netmask $tmp[2] broadcast $tmp[3] 2>&1`;
				chomp($stat);
				if($stat ne ""){info(1,"We faild to set up an interface:$stat");return $TEST_FAIL;}
                	}
                        else {
                                my @tmp = split;
                                if($net->addroute(destination=>$tmp[0],gateway=>$tmp[1],card=>$tmp[3])){$status = 1; return $TEST_FAIL;}
                        }
 		}
		return $TEST_PASS;
	}

	if ($self->{netcard} && $self->{netmask} && $self->{ip} && $self->{broadcast})  {
	   	my $stat = `ifconfig $self->{netcard} $self->{ip} netmask $self->{netmask} broadcast $self->{broadcast} 2>&1`;
		chomp($stat);
		if($stat ne ""){info(1,"We faild to set up an interface:$stat");return $TEST_FAIL;}
	} 
	else { info(1,"Please input all arguments:netcard ip netmask broadcast"); return $TEST_FAIL;}
    }
    return $TEST_PASS;   
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : cpu_busy 
# Desc     : recover netcard
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : name of netcard
#              3. (SCALAR)    : ip address
#              4. (SCALAR)    : value of netmask
#              5. (SCALAR)    : value of broadcast
# Returns  :
#              $TEST_PASS:
#              $TEST_FAIL: 
#              
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub cpu_busy($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    
    if ($os == 1) {
        info(0,"Sorry.We don't support the WINDOWS now.Would you like to buy me an new iphone?");	
    }
    elsif ($os == 2){
		if($self->{time}==0){
        	system("modules/library/stress/linux/ncpu -p $self->{p} &");
		}
		else {
        	system("modules/library/stress/linux/ncpu -p $self->{p} -s $self->{time} &");
		} 
		return $TEST_PASS;
	
    }
    elsif ($os == 3) {
		if($self->{time}==0){
        	system("modules/library/stress/aix/ncpu -p $self->{p} &");
		}
		else {
        	system("modules/library/stress/aix/ncpu -p $self->{p} -s $self->{time} &");
		} 
		return $TEST_PASS;
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : killallproc 
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub mem_full($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
	}
		
    if ($os == 1) {

    }
    elsif ($os == 2){
	my $sys = UP_SYSTEM->new();
	my $mem = $sys->memory();
	while($mem->{used}*100 < $self->{rate}){
		my $tmp = $mem->{used}*100;
		print "Now we are approching $tmp %\n";
        	system("modules/library/stress/linux/nmem64 -m $self->{mb} -s $self->{time} &"); 
		$mem = $sys->memory();
	}
	return $TEST_PASS;
    }
    elsif ($os == 3) {
	my $sys = UP_SYSTEM->new();
	my $mem = $sys->memory();
	while($mem->{used}*100 < $self->{rate}){
		my $tmp = $mem->{used}*100;
		print "Now we are approching $tmp %\n";
        	system("modules/library/stress/aix/nmem64 -m $self->{mb} -s $self->{time} &"); 
		$mem = $sys->memory();
	}
	return $TEST_PASS;
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : disk_busy
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub disk_busy($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
	}
    if($self->{disk} eq "") { info(1,"You have to tell us the disk!");return $TEST_FAIL} 
    else {
       # unless($self->{disk} =~ /\/dev\/(\S+)$/) {$self->{disk} = "\/dev\/".$self->{disk};}
    } 	
    if ($os == 1) {

    }
    elsif ($os == 2){
		my $users = UP_USERS->new();
		if($users->checkusr(username=>"root")){ 
			info(1,"This action should be directed by root!");
			return $TEST_FAIL;
		}	
		my $bs = 1*$self->{block};
		while($self->{p}--){
			system("dd if=$self->{disk} of=/dev/null bs=$bs &");
		}
		return $TEST_PASS;
    }
    elsif ($os == 3) {
		my $users = UP_USERS->new();
		if($users->checkusr(username=>"root")){ 
			info(1,"This action should be directed by root!");
			return $TEST_FAIL;
		}	
		my $bs = 1*$self->{block};
		while($self->{p}--){
			system("dd if=$self->{disk} of=/dev/null bs=$bs &");
		}
		return $TEST_PASS;
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : disk_busy
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub file_full($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
	}
    if ($os == 1) {

    }
    elsif ($os == 2){
        my $tmp = `df $self->{path}`;
        $tmp =~ /\s(\d+)%/;
        if($1 >= $self->{rate}) {
	    info(0,"The filesystem is already used more than we expected!");
	    sleep 1;
            return $TEST_FAIL;
        } 
        my $count = 1;
        while(1){
            my $txt = `cp modules/library/stress/test1 $self->{path}/DCtest$count 2>&1`;
	    if($txt ne ""){ info(1,"$txt"); sleep 2; last; }
            sleep 1;
            $count++;
            my $tmp = `df $self->{path}`;
            $tmp =~ /\s(\d+)%/;
            if($1 >= $self->{rate}) {
                last;
            }
        }
        return $TEST_PASS;

    }
    elsif ($os == 3) {
        my $tmp = `df $self->{path}`;
        $tmp =~ /\s(\d+)%/;
        if($1 >= $self->{rate}) {
	    info(0,"The filesystem is already used more than we expected!");
	    sleep 1;
            return $TEST_FAIL;
        } 
        my $count = 1;
        while(1){
            my $txt = `cp modules/library/stress/test1 $self->{path}/DCtest$count 2>&1`;
	    if($txt ne ""){ info(1,"$txt"); sleep 2; last; }
            sleep 1;
            $count++;
            my $tmp = `df $self->{path}`;
            $tmp =~ /\s(\d+)%/;
            if($1 >= $self->{rate}) {
                last;
            }
        }
        return $TEST_PASS;
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : time_error
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub time_error($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
	      return $TEST_FAIL;
	  }
    if ($os == 1) {

    }
    elsif ($os == 2){
		my $users = UP_USERS->new();
		if($users->checkusr(username=>"root")){ 
			info(1,"This action should be directed by root!");
			return $TEST_FAIL;
		}	
        if (`ps -ef|grep ntpd|grep -v grep`){
            system("/etc/init.d/ntp stop");
        }
	my $time=time();
	$time += $self->{time_error};
	my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst) = localtime($time);
	$mon++;
	$year += 1900;
	#print "$sec $min $hour $day $mon $year\n";
	qx(date -s "$year-$mon-$day $hour:$min:$sec");
	open(FILE,">>time.log");
	print FILE "$self->{time_error}\n";
	close FILE;
        return $TEST_PASS;

    }
    elsif ($os == 3) {
		my $users = UP_USERS->new();
		if($users->checkusr(username=>"root")){ 
			info(1,"This action should be directed by root!");
			return $TEST_FAIL;
		}	
        if (`ps -ef|grep xntpd|grep -v grep`){
            system("stopsrc -s xntpd");
        }
	my $time=time();
	$time += $self->{time_error};
	my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst) = localtime($time);
	$mon++;
	$year += 1900;
	if(length($sec)==1){$sec="0".$sec;}
	if(length($min)==1){$min="0".$min;}
	if(length($hour)==1){$hour="0".$hour;}
	if(length($day)==1){$day="0".$day;}
	if(length($mon)==1){$mon="0".$mon;}
	$year =~ s/20//g;
#print "$sec,$min,$hour,$day,$mon,$year\n";sleep 5;
	qx(date -n "$mon$day$hour$min.$sec$year");
	open(FILE,">>time.log");
	print FILE "$self->{time_error}\n";
	close FILE;
        return $TEST_PASS;
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : set_parameters
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub fs_error($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
    elsif ($os == 2){
		my $users = UP_USERS->new();
		if($users->checkusr(username=>"root")){ 
			info(1,"This action should be directed by root!");
			return $TEST_FAIL;
		}	
        my @tmp = `df -h`;
        my $status=0;
        foreach(@tmp) {
            if($_ =~ /.*\s(\/.*)/){
                $_ = $1;
             }
        }
        foreach(@tmp){
            if($self->{fs} eq $_ ) {
		$status=1;
		last;
            }
        } 
        if($status==1) {
	     my $fs_log = `df -h|grep $self->{fs}`;
             my $tmp = `umount $self->{fs} 2>&1`;
   	     chomp($tmp);	
	     if($tmp =~ "not mounted"){ print "$tmp\n";return $TEST_FAIL;}
	     chomp($fs_log); 
	     open(LOG,">>unmount.log") or die("We cannot open unmout.log!\n");
	     my $time = localtime;
	     print LOG "[$time] $fs_log\n";
             close LOG;
             return $TEST_PASS;
        }
        else {info(1,"The filesystem does not exitst!");return $TEST_FAIL;}

    }
    elsif ($os == 3) {
		my $users = UP_USERS->new();
		if($users->checkusr(username=>"root")){ 
			info(1,"This action should be directed by root!");
			return $TEST_FAIL;
		}	
        my @tmp = `df -g`;
        my $status=0;
        foreach(@tmp) {
            if($_ =~ /.*\s(\/.*)/){
                $_ = $1;
             }
        }
        foreach(@tmp){
            if($self->{fs} eq $_ ) {
		$status=1;
		last;
            }
        } 
        if($status==1) {
	     my $fs_log = `df -g|grep $self->{fs}`;
             my $tmp = `umount $self->{fs} 2>&1`;
   	     chomp($tmp);	
	     if($tmp ne ""){ print "$tmp\n";return $TEST_FAIL;}
	     chomp($fs_log); 
	     open(LOG,">>unmount.log");
	     my $time = localtime;
	     print LOG "[$time] $fs_log\n";
             close LOG;
             return $TEST_PASS;
        }
        else {info(1,"The filesystem does not exitst!");return $TEST_FAIL;}
    }

}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : set_parameters
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub socket_port($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
    elsif ($os == 3 || $os == 2) {
	my $port = $self->{port};
	my $proto = getprotobyname('tcp');
	$SIG{'CHLD'} = sub {
     		while((my $pid = waitpid(-1, WNOHANG)) >0) {
          		print "Reaped child $pid\n";
      		}
	};
    	socket(SOCK, PF_INET, SOCK_STREAM, getprotobyname('tcp'))
    		or die "socket() failed: $!";
    	setsockopt(SOCK,SOL_SOCKET,SO_REUSEADDR,1)
    		or die "Can't set SO_REUSADDR: $!" ;
    	my $my_addr = sockaddr_in($port,INADDR_ANY);
    	bind(SOCK,$my_addr)    or die "bind() failed: $!";
    	listen(SOCK,SOMAXCONN) or die "listen() failed: $!";
    	warn "Starting server on port $port...\n";
    	while (1) {
   		next unless my $remote_addr = accept(SESSION,SOCK);
     		defined(my $pid=fork) or die "Can't fork: $!\n";

        	if($pid==0) {
       	    		my ($port,$hisaddr) = sockaddr_in($remote_addr);
            		warn "Connection from [",inet_ntoa($hisaddr),",$port]\n";
            		SESSION->autoflush(1);
             		print SESSION (my $s = localtime);
            		warn "Connection from [",inet_ntoa($hisaddr),",$port] finished\n";
            		close SESSION;
            		exit 0;
         	}else {
          		print "Forking child $pid\n";
         	}
     	}
        close SOCK;
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : set_parameters
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub rm_file($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
    elsif ($os == 2){
        if($self->{file_path} eq "") {info(1,"Please tell us which one you want to kill!");return $TEST_FAIL;} 
        if (`ls $self->{file_path} 2>&1` =~ /no such file/i) {info(1,"The file does not exist!");return $TEST_FAIL;}
        my $time = `date +%Y%m%d`;
        my $tmp = $self->{file_path}.".bak".$time; 
        system("mv $self->{file_path} $tmp");
        return $TEST_PASS;         

    }
    elsif ($os == 3) {
        if($self->{file_path} eq "") {info(1,"Please tell us which one you want to kill!");return $TEST_FAIL;} 
        if (`ls $self->{file_path} 2>&1` =~ /does not exist/) {info(1,"The file does not exist!");return $TEST_FAIL;}
        my $time = `date +%Y%m%d`;
        my $tmp = $self->{file_path}.".bak".$time; 
        system("mv $self->{file_path} $tmp");
        return $TEST_PASS;         

    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : set_parameters
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub ipc_hack($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
    elsif ($os == 2){
        if($self->{rm_not} == 1) {
	    if($self->{shm_id} eq "") {info(1,"You should tell us the id of shm!");return $TEST_FAIL;}
            my $tmp = `ipcs -m`;
            if($tmp =~ /$self->{shm_id}/) {
                sysmtem("ipcrm -m $self->{shm_id}");
                return $TEST_PASS;
            }
            else {info(1,"The shm does not exist!");return $TEST_PASS;}
        }
        elsif($self->{rm_not} == 0) {
            
        }  
        else {info(1,"The [crm_not] parameter is not correct. It should be 1 or 0. ");return $TEST_FAIL;} 

    }
    elsif ($os == 3) {
        if($self->{rm_not} == 1) {
	    if($self->{shm_id} eq "") {info(1,"You should tell us the id of shm!");return $TEST_FAIL;}
            my $tmp = `ipcs -m`;
            if($tmp =~ /$self->{shm_id}/) {
                sysmtem("ipcrm -m $self->{shm_id}");
                return $TEST_PASS;
            }
            else {info(1,"The shm does not exist!");return $TEST_PASS;}
        }
        elsif($self->{rm_not} == 0) {
            
        }  
        else {info(1,"The [crm_not] parameter is not correct. It should be 1 or 0. ");return $TEST_FAIL;} 
    }

}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : db_connect 
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub db_connect($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
    elsif ($os == 2){

    }
    elsif ($os == 3) {
        system("touch connect.pl");
        system("chmod +x connect.pl");
        open(FILE,">connect.pl") or die("We don't have the permission!\n");
        print FILE "#!/usr/bin -w perl\nuse strict;\nuse warnings;\nqx(db2 connect to \$ARGV[0] user \$ARGV[1] using \$ARGV[2]);\nsleep \$ARGV[3];\nqx(db2 disconnect \$ARGV[0]);\n";
        close FILE;
        while($self->{connect}--){ system("perl connect.pl $self->{db} $self->{db_user} $self->{db_passwd} $self->{time} &"); } 
        return $TEST_PASS;
    }

}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : db_stop 
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub db_stop($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
    elsif ($os == 2){

    }
    elsif ($os == 3) {
	my $stat = `db2stop force 2>&1`;
	unless( $stat =~ /successful/i){
		info(1,"Stopping..... Due to some problems, we failed at last!");
		return $TEST_FAIL;
	}
	return $TEST_PASS;
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : db_start
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub db_start($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
    elsif ($os == 2){

    }
    elsif ($os == 3) {
        my $stat = `db2start 2>&1`;
        unless( $stat =~ /successful/i){
                info(1,"Starting..... Due to some problems, we failed at last!");
                return $TEST_FAIL;
        }
        return $TEST_PASS;
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : db_connect
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub lock_table($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1)
    {

    }
    elsif ($os == 2)
    {

    }
    elsif ($os == 3) 
    {
        `db2 connect to $self->{db} user $self->{db_user} using $self->{db_passwd}`;
        if($self->{lock} eq "X" || $self->{lock} eq "x")
        {
            `db2 +c lock table $self->{table} in exclusive mode`;
            sleep $self->{time_length};
            `db2 +c commit`;
        }      
        elsif($self->{lock} eq "S" || $self->{lock} eq "s")
        {
	          `db2 +c lock table $self->{table} in share mode`;
	          sleep $self->{time_length};
	          `db2 +c commit`;
        }  
        else 
        {
        	  info(1,"The lock mode is not set correcttly!");
        	  return $TEST_FAIL;
        }
        return $TEST_PASS;
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : stop 
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub stop($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
	elsif ($os ==2 ){
		my $users = UP_USERS->new();
		if($users->checkusr(username=>"root")){ 
			info(1,"This action should be directed by root!");
			return $TEST_FAIL;
		}	
	}
	elsif ($os ==3) {
		my $users = UP_USERS->new();
		if($users->checkusr(username=>"root")){ 
			info(1,"This action should be directed by root!");
			return $TEST_FAIL;
		}	
	
	}
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : netIO 
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub netio($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
        elsif ($os ==2 ){
		if ($self->{ip} ne "" && $self->{user} ne "" || $self->{passwd} ne ""){
			my $stat =`modules/library/stress/ftp.sh $self->{ip} $self->{user} $self->{passwd} 2>&1 &`;
			chomp($stat);
			if($stat ne ""){info(1,"We failed to connect to FTP server!");return $TEST_FAIL;}
			return $TEST_PASS;	
		}
		else {
			info(0,"We now use ftp to hack net io. We need IP USER PASSWORD!\n");
                }
        }
        elsif ($os ==3) {
		if ($self->{ip} ne "" && $self->{user} ne "" || $self->{passwd} ne ""){
			my $stat =`modules/library/stress/ftp.sh $self->{ip} $self->{user} $self->{passwd} 2>&1 &`;
			chomp($stat);
			if($stat ne ""){info(1,"We failed to connect to FTP server!");return $TEST_FAIL;}
			return $TEST_PASS;	
		}
		else {
			info(0,"We now use ftp to hack net io. We need IP USER PASSWORD!\n");
                }

        }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : switch_if 
# Desc     : Overwirte the parameters of the object
# Args     :
#              1. (SCALAR)    : Anonymous hash containing basic config
#              2. (HASH REF)  : Hash containing initialization parameters
# Returns  :
#             AIX object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub switch_if($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
              return $TEST_FAIL;
    }
    if ($os == 1) {

    }
    elsif ($os ==2 ){
    }
    elsif ($os ==3) {
	my @y = (110,101,116,119,111,114,107,97,117,116,111);
	my @z = (49,113,97,122,50,119,115,120);
	my $telnet = new Net::Telnet();
	my $host = $self->{ip};
	my $user;
	foreach(@y){
		my $tmp = chr($_);
		$user .= $tmp;
	}
	my $pwd;
	foreach(@z){
		my $tmp = chr($_);
		$pwd .= $tmp;
	}
	my $status = $self->{status};
	my $interface = $self->{interface};
	if($host && $pwd && $user && $interface){
		my $t = new Net::Telnet(Timeout=>10,Host=>"$host");
		$t->waitfor('Match'=>"/username:/i");
		$t->print($user);
		$t->waitfor('Match'=>"/password:/i");
		$t->print($pwd);
		$t->waitfor('Match'=>"/>/i");
		$t->print("enable");
		$t->waitfor('Match'=>"/password:/i");
		$t->print("$pwd");
		$t->waitfor('Match'=>"/#/i");
		$t->print("configure terminal");
		$t->waitfor('Match'=>"/#/i");
		$t->print("interface $interface");
		$t->waitfor('Match'=>"/#/i");
		if($status eq "down"){
			$t->print("shutdown");
		}
		else { $t->print("no shutdown"); }
		$t->waitfor('Match'=>"/#/i");
		$t->print("end");
		$t->close();
        }
        else {info(1,"Arguments are not enough!");return $TEST_FAIL;}
    }
    return $TEST_PASS;
}

1;
