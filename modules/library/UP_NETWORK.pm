# UP_NETWORK.pm
#
# Copyright (c) 2000 - 2014 China UnionPay. All rights reserved.
# This program is used to manipulate DB2 server.
#
# mod::name= UP_NETWORK.pm
# mod::desc= Perl package for network to complete tasks that are
#            useful for aix servers' wide configurations.
# mod::author= Ding Wenhao, and many others
# mod::cvs= $Id: //SVN/µÄ/Î»/ÖÃ/lib/UP_NETWORK.pm#1 $
# mod::changed= $Date: 2014/02/26 $
# mod::modusr= $Author: dingwenhao $
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
package UP_NETWORK;

#use Net::Telnet ();
#use Sys::Info::OS;
use UP_USERS;

our $TEST_PASS = 0;
our $TEST_FAIL = 1;
our $os = 0;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Set this to point out the package name.
#            
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
our $package = "UP_NETWORK";
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
# Desc     : Base class constructor for UP_DB2_LIB
# Args     :
#              1. (SCALAR)    :
#              2. (HASH REF)  :
# Returns  :
#             DB2 object
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub new($%)
{
    my ($class, %args) = @_;
    my $self = bless {}, ref($class) || $class;
    $self->_init(%args);
 #   my $system = Sys::Info::OS->new();
    my $name = `uname 2>&1`; 
    if ($name =~ "Windows") {
	$os = 1;
    }
    elsif ($name =~ "Linux"){
	$os = 2;
    }
    elsif ($name =~ "AIX") {
	$os = 3;
    }
    else {
	info(1,"Operation System is not applied!");
	return $TEST_FAIL;
    }  
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
sub _init($%)
{
    my ($self, %args) = @_;
  # return if $self->{_init}{__PACKAGE__}++;
    $self->{label} = $args{label} || "UP_NETWORK";
    $self->{host} = $args{host} || "localhost";
    $self->{port} = $args{host} || 4444;
    $self->{prompt} = $args{promtp} || '/[\$%#>] $/';
    $self->{timeout} = $args{timeout} || 5;
    $self->{card} = $args{card} || "";
    $self->{netmask} = $args{netmask} || "";
    $self->{gateway} = $args{gateway} || "";
    $self->{destination} = $args{destination} || "";
}

##
## User interface methods
##

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : port_alive
# Desc     : check the specific port is alive
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : port number
#              4. (SCALAR)    : timeout
# Returns  :
#              $TEST_PASS means the port is alive
#              $TEST_FAIL means the port cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub port_alive($@)
{    
    my $self = shift;  
    $self->_init();
    my %hash = @_;   
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    
    my $t = new Net::Telnet (  
                                Prompt  => '/bash\$ $/',
                            );  
    my $status = 0;
    eval {
    $status = $t->open(Host=>$self->{host},Timeout =>$self->{timeout},Port=>$self->{port});
    };
    $t->close;   
    return ($status == 1) ? $TEST_PASS : $TEST_FAIL;
    
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : host_alive
# Desc     : check the specific port is alive
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : try times
# Returns  :
#              $TEST_PASS means the host is alive
#              $TEST_FAIL means the host cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub host_alive($@)
{    
    my $self = shift;  
    $self->_init();
    my %hash = @_;   
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    my $status = 0;
    if ($os == 1) {

    }
    elsif ($os == 2){

    }
    elsif ($os == 3) {
	$_ = `ping -c 3 $self->{host}`;
	$status = /\s+0% packet loss/;
    }
    return ($status == 1) ? $TEST_PASS : $TEST_FAIL;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : ifconfig
# Desc     : check the NIC configuration
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : try times
# Returns  :
#              $TEST_PASS means the host is alive
#              $TEST_FAIL means the host cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub ifconfig($@)
{    
    my $self = shift;  
    $self->_init();
    my %hash = @_;   
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    my @nic;
    
    if ($os == 1) {
	
    }
    elsif ($os == 2){
	my $text;
	my @net_card;
	if ($self->{card}){ 
	    $net_card[0] = $self->{card};
	}
	else { 
	    my @tmp = `ifconfig -a|grep -v lo|grep 'Link'`;
            foreach(@tmp){
            	$_ =~ /^(\S+)\s+/;
                push(@net_card,$1);
	    }
	}
	foreach (@net_card) {
            my $tmp = `ifconfig $_`;
            my $temp;
            $temp->{name} = $_;
            $temp->{status} = ($tmp=~/UP BROADCAST RUNNING/ ? "UP":"DOWN");
            $temp->{ip} = ($tmp=~/addr:(\d+\.\d+\.\d+\.\d+)\s/ ? "$1":"NA");
			$temp->{netmask} = ($tmp=~/Mask:(\d+\.\d+\.\d+\.\d+)/i ? "$1":"NA");
			$temp->{broadcast} = ($tmp=~/Bcast:(\d+\.\d+\.\d+\.\d+)/i ? "$1":"NA");
            push(@nic,$temp);
	}		
    }
    elsif ($os == 3) {
	my $text;
	my @net_card;
	if ($self->{card}){ 
	    $net_card[0] = `ifconfig $self->{card}`;
	}
	else { 
	    $_ = `ifconfig -l`;
	    chomp($_);
	    my @l = split;
	    foreach(@l){
		my $text = `ifconfig $_`;
		push(@net_card,$text);
	    }
	  #  $text = `ifconfig -a`;
	  #  my @text = split /(en\d+:|lo\d+:)/,$text;
	  #  my $nu=@text;
	  #  for(my $i=0;$i<$nu-1;$i+=2){
	#	$text[$i+1] .= $text[$i+2];
	#	push(@net_card,$text[$i+1]);
	 #   }	    
	}
	foreach (@net_card) {
		my $temp;
		$temp->{raw} = $_;
		$temp->{name} = "";
		$temp->{ip} = "";
		$temp->{netmask} = "";
		$temp->{broadmask} = "";
		if(/^(.*):/){
			$temp->{name} = $1;
		}
		if(/<(\w*),/){
			if($1 eq "UP" || $1 eq "up"){
				$temp->{status} = $1;
			}
			else {$temp->{status} = "DOWN"}
		}
		if(/inet\s((\d+\.?)*)\s/){
		$temp->{ip} = $1;
		}
		if(/netmask 0x(\S\S)(\S\S)(\S\S)(\S\S)\s+/){
		my $text = "0x"."$1";
		my $text1 = oct $text;
		$text = "0x"."$2";
		my $text2 = oct $text;
		$text = "0x"."$3";
		my $text3 = oct $text;
		$text = "0x"."$4";
		my $text4 = oct $text;
		$temp->{netmask} = "$text1"."."."$text2"."."."$text3"."."."$text4";
	        }	
		if(/broadcast (\S+)\s+/){
		$temp->{broadcast} = "$1";
		}
		push(@nic,$temp);
	}		
    }
    return @nic;     
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : route
# Desc     : check the NIC configuration
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : try times
# Returns  :
#              $TEST_PASS means the host is alive
#              $TEST_FAIL means the host cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub route($@)
{    
    my $self = shift;  
    $self->_init();
    my %hash = @_;   
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    my @route;
    
    if ($os == 1) {
	
    }
    elsif ($os == 2){
	my $ins=0;
	my $text = `route`;
	my @text = split /\n/,$text;
	foreach (@text) {
	    if (/^\s*$/ && $ins) {$ins=0;}
	    if ($ins) {
		my $temp;
		$temp->{raw}=$_;
		my @sp = split;
		$temp->{destination}=$sp[0];
		$temp->{gateway}=$sp[1];
		$temp->{netmask}=$sp[2];
		$temp->{flags}=$sp[3];
		$temp->{refs}=$sp[5];
		$temp->{use}=$sp[6];
		$temp->{if}=$sp[7];
		push(@route,$temp);
	    }
	    if (/Destination/ && !$ins) {$ins=1;}	
	}			
	
    }
    elsif ($os == 3) {
	my $ins=0;
	my @text = `netstat -rn`;
	foreach (@text) {
		chomp;
	    	if (/^\s*$/ && $ins) {$ins=0;}
	    	if ($ins) {
			my $temp;
			$temp->{raw}=$_;
			my @sp = split;
			$temp->{destination}=$sp[0];
			$temp->{gateway}=$sp[1];
			$temp->{flags}=$sp[2];
			$temp->{refs}=$sp[3];
			$temp->{use}=$sp[4];
			$temp->{if}=$sp[5];
			push(@route,$temp);
	    }
	    if (/Route Tree.*/i && !$ins) {$ins=1;}	
	}			
    }
    return @route;     
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : addroute
# Desc     : check the NIC configuration
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : try times
# Returns  :
#              $TEST_PASS means the host is alive
#              $TEST_FAIL means the host cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub addroute($@)
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
	my $users=UP_USERS->new();
	if($users->checkusr(username=>"root")){
		info(1,"This actions is only supported for root!");
		return $TEST_FAIL;
	}
	if ($self->{destination}) {
	   	system("route add -net $self->{destination} netmask $self->{netmask} dev $self->{card}");
	}
	else { info(1,"Arguments not applied!"); return $TEST_FAIL;}			
	
    }
    elsif ($os == 3) {
	my $users=UP_USERS->new();
	if($users->checkusr(username=>"root")){
		info(1,"This actions is only supported for root!");
		return $TEST_FAIL;
	}
	if ($self->{netmask} ne ""){info(0,"We now use xx.xx.xx/xx to set netmask! However,you can expect we modify that later!");return $TEST_FAIL;}
	if ($self->{destination} && $self->{gateway} && $self->{card}) {
		my $stat = "[INFO]:$self->{destination} --> It's already there! Inet0 changed\n";
		my $num = `netstat -rn|grep "$self->{destination}"|grep "$self->{gateway}"|grep "$self->{card}"|wc -l`;
		chomp($num);
		if($self->{destination} =~ /\//){
			$self->{destination}=~/^(.*)\/24/;
			my $des = $1;
			if($num > 0){ ; }
			else {$stat = `chdev -l inet0 -a route=net,-hopcount,0,-if,$self->{card},,,$des,$self->{gateway} 2>&1`;}
		}
		else {
			if($num > 0){ ; }
			else { $stat = `chdev -l inet0 -a route=host,-hopcount,0,-if,$self->{card},,,$self->{destination},$self->{gateway} 2>&1`;}
		}
		unless($stat =~ /inet0 changed/i){info(0,"We failed to add some route!");return $TEST_FAIL;}	
	}
	else { info(1,"Arguments not applied!Add route."); return $TEST_FAIL;}			
    }
    return $TEST_PASS;     
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : delroute
# Desc     : check the NIC configuration
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : try times
# Returns  :
#              $TEST_PASS means the host is alive
#              $TEST_FAIL means the host cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub delroute($@)
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
	my $users=UP_USERS->new();
	if($users->checkusr(username=>"root")){
		info(1,"This actions is only supported for root!");
		return $TEST_FAIL;
	}
	if($self->{destination} =~ 'default') {info(1,"We cannot remove the default gateway now!");sleep 1; return $TEST_FAIL;}
		if ($self->{destination} && $self->{gateway}) {
		open(LOG,">>delroute.log")||die("We cannont write to the file!\n");
		my $tmp = `netstat -rn|grep $self->{destination}`;
		chomp($tmp);
		my $time = localtime;
		print LOG "[$time][SUSE]:$tmp\n";
		close LOG;
		system("route del -net $self->{destination} netmask $self->{netmask}");
	}
	else { info(1,"Arguments not applied!"); return $TEST_FAIL;}			

    }
    elsif ($os == 3) {
	my $users=UP_USERS->new();
	if($users->checkusr(username=>"root")){
		info(1,"This actions is only supported for root!");
		return $TEST_FAIL;
	}
	if($self->{destination} =~ 'default') {info(1,"We cannot remove the default gateway now!");sleep 1; return $TEST_FAIL;}
	if ($self->{destination} && $self->{gateway}) {
		open(LOG,">>delroute.log")||die("We cannont write to the file!\n");
        	my $time=localtime;
		my $tmp = `netstat -rn|grep $self->{destination}|grep $self->{gateway}`;
		chomp($tmp);
		print LOG "[$time][AIX]:$tmp\n";
		close LOG;
		my $stat = `route delete $self->{destination} $self->{gateway} 2>&1`;
		if($stat =~ /no such process/i){info(1,"We failed to add the route!"); return $TEST_FAIL;}	
	}
	else { info(1,"Arguments not applied!"); return $TEST_FAIL;}			
    }
    return $TEST_PASS;     
}

1;
#------------------------------------------------------
# Module code ends
#------------------------------------------------------

__END__
