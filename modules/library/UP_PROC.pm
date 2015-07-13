# UP_PROC.pm
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
package UP_PROC;


our $TEST_PASS = 0;
our $TEST_FAIL = 1;
our $os = 0;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Set this to point out the package name.
#            
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
our $package = "UP_PROC";
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
    my $name = `uname`; 
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
#    return if $self->{_init}{__PACKAGE__}++;
    $self -> {label} = $args{label} || "UP_PROC";
    $self -> {name} = $args{name} || ".*";
    $self -> {pid} = $args{pid} || ".*";
    $self -> {single} = $args{single} || 0;
    $self -> {user} = $args{user} || ".*";
    return $TEST_PASS;
}

##
## User interface methods
##

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : monitor
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub monitor($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }    
    my @text; 
    my @text_out;
    if ($os == 1) {
	@text = `tasklist`;
	foreach (@text) {
		chomp;
		if ($_ eq "") {	
			next;
		}	
		my @tmp = split;
		if ($tmp[0] =~ $self->{name} && $tmp[1] =~ $self->{pid}){
			$_ .= "\n";
			push(@text_out,$_);
		}
		
	}
	#print "@text_out";
    }
    elsif ($os == 2){
        @text = `ps -ef`;
        foreach (@text) {
		chomp;
                if ($_ =~ /UID\s+PID\s+/) { next; }
                my @tmp = split;
                my $cmd="";
                for(my $i=7;$i<@tmp;$i++) {
			$cmd = $cmd." ".$tmp[$i];
		}
                if ($tmp[0] =~ $self->{user} && $tmp[1] =~ "$self->{pid}" && $cmd =~ $self->{name}) {
			if($self->{pid} ne ".*") {
				if($tmp[1] ne $self->{pid}) { next; }
			}
			my $tmp;
                        $tmp->{user}=$tmp[0];
                        $tmp->{pid}=$tmp[1];
                        $tmp->{cmd}=$cmd;
 			push(@text_out,$tmp);
		}

	}	
    }
    elsif ($os == 3) {
	@text = `ps -ef|grep -v grep|grep -v UID|grep -v defunct|grep -v ksh`;
	foreach (@text) {
		chomp;
		if ($_ eq "") {	
			next;
		}
		if ($_ =~ /UID/){next;}
		my($uid,$pid,$ppid,$c,$stime,$stime2,$tty,$time,$cmd);
		if (/\d+\s+\d+:\d+:\d+\s+/) {
			($uid,$pid,$ppid,$c,$stime,$tty,$time,$cmd)= /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*)/;
		}
		else {
			($uid,$pid,$ppid,$c,$stime,$stime2,$tty,$time,$cmd)= /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*)/;
			$stime .= " $stime2";
		}
		if ($uid =~ $self->{user} && $pid =~ "$self->{pid}" && $cmd =~ $self->{name}){
			if($self->{pid} ne ".*") {
				if($pid ne $self->{pid}) { next; }
			}
			$_ .= "\n";
			unless($cmd =~/$0/){
			my $tmp;
			$tmp->{raw} = $_;
			$tmp->{user} = $uid;
			$tmp->{pid} = $pid;
			$tmp->{cmd} = $cmd;
			$tmp->{stime} = $stime;
			push(@text_out,$tmp);
			}
		}
		
	}
    }
    else {
	info(1,"Operation System is not applied!");
    }  
    return @text_out;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : killproc
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub killproc($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }  
    
    if($self->{pid} eq "" && $self->{user} eq "" && $self->{name} eq "") {
	info(1,"We can not kill everyone!");
	return $TEST_FAIL;
    }
    
    my @text = $self->monitor(pid=>"$self->{pid}",user=>"$self->{user}",name=>"$self->{name}");
#    if (@text<1) {
#	info(1,"There's no such progress!");
#	return $TEST_FAIL;
#    }
   
    if ($os == 1) {
	
    }
    elsif ($os == 2){
    
    }
    elsif ($os == 3) {
	if ($self->{single} != 0){
		if( @text > 1) {
			info(1,"You can not kill more than one progress!");
			return $TEST_FAIL;
		}
	}
	else {
		foreach(@text) {
			kill(9,$_->{pid});
			my @tmp =$self->monitor(pid=>$_->{pid},name=>$_->{cmd});
			if (@tmp>0) {
				info(1,"We can not kill the progress:$_->{raw}");
				return $TEST_FAIL;
			}
			else {
				;
			}
		}
	}
    } 
    return $TEST_PASS;
}
1;
