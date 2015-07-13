# UP_DB2.pm
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
package UP_DB2;

#use Sys::Info::OS;

our $TEST_PASS = 0;
our $TEST_FAIL = 1;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Set this to point out the package name.
#            
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
our $package = "UP_DB2";
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
    $self -> {label} = $args{label} || "UP_DB2";
    $self -> {user} = $args{user} || ".*";
    $self -> {passwd} = $args{passwd} || ".*";
    $self -> {db} = $args{db} || ".*";
    $self -> {table} = $args{table} || ".*";
    $self -> {schema} = $args{schema} || "";
}

##
## User interface methods
##

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : connect
# Desc     : check the NIC configuration
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : try times
# Returns  :
#              $TEST_PASS means the host is alive
#              $TEST_FAIL means the host cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub connect($@)
{    
    my $self = shift;  
    $self->_init();
    my %hash = @_;   
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    my $result = `db2 connect to $self->{db} user $self->{user} using $self->{passwd}`;
    if ($result =~ "Database Connection Information"){return $TEST_PASS;}
    else {return $TEST_FAIL;}   
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : drop_table
# Desc     : check the NIC configuration
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : try times
# Returns  :
#              $TEST_PASS means the host is alive
#              $TEST_FAIL means the host cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub drop_table($@)
{    
    my $self = shift;  
    $self->_init();
    my %hash = @_;   
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    my $result = `db2 drop table $self->{table}`;
    if ($result =~ "completed successfully"){return $TEST_PASS;}
    else {return $TEST_FAIL;}  
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : reset 
# Desc     : check the NIC configuration
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : try times
# Returns  :
#              $TEST_PASS means the host is alive
#              $TEST_FAIL means the host cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub reset($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL){
        return $TEST_FAIL;
    }

    `db2 connect reset 2>&1`;
    return $TEST_PASS;
}
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : set_schema
# Desc     : check the NIC configuration
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : ip address
#              3. (SCALAR)    : try times
# Returns  :
#              $TEST_PASS means the host is alive
#              $TEST_FAIL means the host cannot be reached
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub set_schema($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;
    if (set_parameters($self,%hash)==$TEST_FAIL)
    {
              return $TEST_FAIL;
    }
    my $result = `db2 set current schema $self->{schema}`;
    if ($result =~ "completed successfully"){return $TEST_PASS;}
    else {return $TEST_FAIL;}
}


1;
