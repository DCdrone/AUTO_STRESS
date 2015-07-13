# UP_USERS.pm
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
package UP_USERS;

our $TEST_PASS = 0;
our $TEST_FAIL = 1;
our $os = 0;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Set this to point out the package name.
#            
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
our $package = "UP_USERS";
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
sub _init(\%%)
{
    my ($self, %args) = @_;
    return if $self->{_init}{__PACKAGE__}++;
    $self -> {label} = $args{label} || "UP_USERS";
    $self -> {username} = $args{username} || "";
    $self -> {group} = $args{group} || "";
    $self -> {uid} = $args{uid} || "";
    $self -> {gid} = $args{gid} || "";
    $self -> {chmod} = $args{chmod} || "";
    $self -> {passwd} = $args{passwd} || ""; 
    $self -> {rwx} = $args{rwx} || "w"; 
    $self -> {path} = $args{path} || "w"; 
}

##
## User interface methods
##

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : adduser
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub adduser($@)
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
	if (!$sel->{username}){my @text = `useradd -m $self->{username}`;}
	if (!$sel->{group}){my @text = `usermod -G $self->{group} $self->{username}`;}
	#if (!$sel->{passwd}){my @text = `usermod -G $self->{group} $self->{username}`;}
    }
      
    return $TEST_PASS;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : deluser
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub deluser($@)
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
	if (!$sel->{username}){my @text = `userdel $self->{username}`;}
    }
   
    return $TEST_PASS;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : addgroup
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub addgroup($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }   
    
   
   
    return $TEST_PASS;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : delgroup
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub delgroup($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }   
   
   
    return $TEST_PASS;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : adduser
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub chgroup($@)
{
    my $self = shift;
    $self->{type} = 'file';
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }   
   
   
   
    return $TEST_PASS;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : adduser
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub checkusr($@)
{
    my $self = shift;
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
		return $TEST_FAIL;
    }

   	if($os==1){}
	elsif($os==2){
 		my $txt=`id`;
		chomp;
        $txt =~ /uid=\d+\((\S+)\)/;
		my $usr=$1;
		if($self->{username} eq $usr){
			return $TEST_PASS;
		}
		else {return $TEST_FAIL;}
	
	}
	elsif($os==3){
 		my $txt=`id`;
		chomp($txt);
        $txt =~ /uid=\d+\((\S+)\)/;
		my $usr=$1;
		if($self->{username} eq $usr){
			return $TEST_PASS;
		}
		else {return $TEST_FAIL;}
	}
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     :checkrwx 
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub checkrwx($@)
{
    my $self = shift;
    my %hash = @_;    
    if (set_parameters($self,%hash)==$TEST_FAIL){
		return $TEST_FAIL;
    }

   	if($os==1){}
	elsif($os==2){
	}
	elsif ($os==3){
	
	}
}
1;
