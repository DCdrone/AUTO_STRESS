# UP_SYSTEM.pm
#
# Copyright (c) 2000 - 2014 China UnionPay. All rights reserved.
# This program is used to manipulate AIX server.
#
# mod::name= UP_FILE.pm
# mod::desc= Perl package for all OS to complete tasks that are
#            useful for servers' wide configurations.
# mod::author= Chen Chen
# mod::cvs= $Id: //SVN/的/位/置/lib/UP_FILE.pm#1 $
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
package UP_SYSTEM;

#use Sys::Info::OS;

our $TEST_PASS = 0;
our $TEST_FAIL = 1;
our $os = 0;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Set this to point out the package name.
#            
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
our $package = "UP_SYSTEM";
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
    return if $self->{_init}{__PACKAGE__}++;
    $self -> {label} = $args{label} || "UP_SYSTEM";
    $self -> {secure} = $args{secure} || "secure";
    $self -> {command} = $args{command} || "";
    $self -> {arguments}=$args{arguments}|| "k";
    $self -> {directory}=$args{direcotory} || "";
}

##
## User interface methods
##

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : get_time
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub get_time($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    my $time;  
    my ($sec, $min, $hour, $day, $mon, $year) = localtime;
    $year+=1900;
    $mon+=1;

    $mon =  (length($mon)   eq 2) ? $mon  : '0'.$mon ;
    $day =  (length($day)   eq 2) ? $day  : '0'.$day ;
    $hour = (length($hour)  eq 2) ? $hour : '0'.$hour;
    $min =  (length($min)   eq 2) ? $min  : '0'.$min ;
    $sec =  (length($sec)   eq 2) ? $sec  : '0'.$sec ;
    $time->{mon}=$mon;
    $time->{day}=$day;
    $time->{hour}=$hour;
    $time->{min}=$min;
    $time->{sec}=$sec;
    $time->{year}=$year; 
    $time->{raw}=$year.$mon.$day.$hour.$min.$sec;
    return $time; 
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : disk
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub disk($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }   
    my @disk;
 
    if ($os == 1) {
	
    }
    elsif ($os == 2){
	my $text = `df -$self->{arguments} $self->{directory}`;
	my @text = split /\n/,$text;
	for (my $i=1;$i<@text;$i++) {
            if($text[$i] =~ /proc/) {next;}
	    my $temp;
	    $temp->{raw}=$text[$i];
	    my @sp = split /\s+/,$text[$i];
	    $temp->{filesystem}=$sp[0];
	    $temp->{size}=$sp[1];
	    $temp->{free}=$sp[3];
	    $sp[4] =~ /^(\d+)%$/;
	    $temp->{used}=$1/100;
	    $temp->{Iused}=$sp[2];
	    $temp->{Iused_percentage}="NA";
	    $temp->{mount}=$sp[5];
	    push(@disk,$temp);
	}
	
    }
    elsif ($os == 3) {
	my $text = `df -$self->{arguments} $self->{directory}`;
	my @text = split /\n/,$text;
	for (my $i=1;$i<@text;$i++) {
            if($text[$i] =~ /proc/) {next;}
	    my $temp;
	    $temp->{raw}=$text[$i];
	    my @sp = split /\s+/,$text[$i];
	    $temp->{filesystem}=$sp[0];
	    $temp->{size}=$sp[1];
	    $temp->{free}=$sp[2];
	    $sp[3] =~ /^(\d+)%$/;
	    $temp->{used}=$1/100;
	    $temp->{Iused}=$sp[4];
	    $temp->{Iused_percentage}=$sp[4];
	    $temp->{mount}=$sp[6];
	    push(@disk,$temp);
	}	
	
    }
    return @disk; 
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : cpu
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub cpu($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }   
  
    my $cpu; 
    if ($os == 1) {
	
    }
    elsif ($os == 2){
	
    }
    elsif ($os == 3) {
	my $text = `iostat`;
	my $ins=0;
	my @text = split /\n/,$text;
	foreach(@text) {
		if($ins ==1) {
			$cpu->{raw} = $_;
			my @sp = split;
			$cpu->{used} = 1-$sp[4]/100;
			last;
		}
		if (/avg-cpu/) {
			$ins = 1;
		}
	}  
			
	
    }
    return $cpu; 
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : memory
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub memory($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }   
    
    my $memory;
    if ($os == 1) {
	
    }
    elsif ($os == 2){
		my @text=`free -m`;
		foreach(@text){
			chomp;
			if($_=~/mem:/i){
				my @tmp = split;
				$memory->{size} = $tmp[1];
				next;
			}
			if($_=~/buffers\/cache/){
				my @tmp=split;
				$memory->{inuse}=$tmp[2];
				$memory->{free}=$tmp[3];
				$memory->{used}=$memory->{inuse}/$memory->{size};
			}
		}	
    }
    elsif ($os == 3) {
	my $text = `svmon -G`;
	my @text = split /\n/,$text;
	foreach(@text) {
	    if (/^memory/) {
		$memory->{raw} = $_;
		my @sp = split;
		$memory->{size} = sprintf("%0.1f",$sp[1]/1024);
		$memory->{inuse} = sprintf("%0.1f",$sp[2]/1024);
		$memory->{free} = sprintf("%0.1f",$sp[3]/1024);
		$memory->{used} = $sp[2]/$sp[1];
		last;
	    }
	}        
    }
    return $memory; 
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : IPCS 
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub ipcs($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }   
    
    my @ipcs;
    if ($os == 1) {
	
    }
    elsif ($os == 2){
   	my @tmp = `ipcs`;
        my $type = "";
        foreach(@tmp) {
		chomp;
		if($_ =~ /shared memory segments/i) { $type = "shm";;next;}
                elsif($_ =~ /semaphore arrays/i) { $type = "sem";next; }
                elsif($_ =~ /message queues/i) { $type = "msq";next; }
                else {
			if($type eq "shm" || $type eq "sem" || $type eq "msq") {
				if($_=~ /key/i || $_ eq "") { next; }
 				my @txt = split;
				my $tmp;
 				$tmp->{key} = $txt[0];
 				$tmp->{id} = $txt[1];
 				$tmp->{user} = $txt[2];
 				$tmp->{type} = $type;
			        push(@ipcs,$tmp);	
			}
		}

	}	
    }
    elsif ($os == 3) {
   	my @tmp = `ipcs`;
        my $type = "";
        foreach(@tmp) {
		chomp;
		if($_ =~ /shared memory/i) { $type = "shm";;next;}
                elsif($_ =~ /semaphores/i) { $type = "sem";next; }
                elsif($_ =~ /message queues/i) { $type = "msq";next; }
                else {
			if($type eq "shm" || $type eq "sem" || $type eq "msq") {
				if($_=~ /key/i || $_ eq "") { next; }
 				my @txt = split;
				my $tmp;
 				$tmp->{key} = $txt[2];
 				$tmp->{id} = $txt[1];
 				$tmp->{user} = $txt[4];
 				$tmp->{type} = $type;
			        push(@ipcs,$tmp);	
			}
		}

	}	
 
    }
    return @ipcs; 
}
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : command
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub command($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }   
    if ($self->{secure} eq "free") {
        system("$self->{command}");
    }
    else {
	system("$self->{command}");
    }  
    return $TEST_PASS;
}



1;
