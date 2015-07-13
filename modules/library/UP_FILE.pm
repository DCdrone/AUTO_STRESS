# UP_FILE.pm
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
package UP_FILE;

use Badger::Filesystem 'Path File Dir';
use File::Path 'mkpath';
use Sys::Info::OS;

our $TEST_PASS = 0;
our $TEST_FAIL = 1;
our $os = 0;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Set this to point out the package name.
#            
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
our $package = "UP_FILE";
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
    my $system = Sys::Info::OS->new();
    my $name = $system->name(); 
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
    $self -> {label} = $args{label} || "UP_FILE";
    $self->{path} = $args{path} || "";
    $self->{type} = $args{type}|| 'file';
    $self->{content} = $args{content} || "";
    $self->{cover} = $args{cover} || 0;
    $self->{mod} = $args{mod} || 600;
    return $TEST_PASS;
}

##
## User interface methods
##

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : create
# Desc     : create file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub create($@)
{
    my $self = shift;
    $self->_init(type=>"file");
    my %hash = @_;
    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    }   
      
    my $fs = Badger::Filesystem->new;
    if ($self->{type} eq 'dir') {
	if ($fs->dir_exists($self->{path})){
		info(0,"Directory already exists!");
	}
	else {
		$fs->create_dir($self->{path});
		#$fs->chmod_path($self->{path}, 0400);
	}
    }
    elsif ($self->{type} eq 'file') {
	if ($fs->file_exists($self->{path})) {
		info(0,"File already exists!");
	}
	else {
		$fs->create_file($self->{path});
		#$fs->chmod_path($self->{path}, 0400);
	}
	}
    else { info(0,"Wrong type!"); }
    return $TEST_PASS;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : delete
# Desc     : delete file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub delete($@)
{
    my $self = shift;
    $self->_init(type=>"file");
    my %hash = @_;
    
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
        
    my $fs = Badger::Filesystem->new;
    if ($self->{type} eq 'dir') {
	if ($fs->dir_exists($self->{path})){
		$fs->delete_dir($self->{path});
	}
	else {
		info(0,"Directory doesn't exists!");
	}
    }
    elsif ($self->{type} eq 'file') {
	if ($fs->file_exists($self->{path})) {
		$fs->delete_file($self->{path});
	}
	else {
		info(0,"File doesn't exists!");
	}
    } 
    else {
	info(0,"Wrong type!");
    }
    return $TEST_PASS;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : read
# Desc     : read file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub read($@)
{
    my $self = shift;
    $self->_init();
    my %hash = @_;   
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    
    my @text; 
    my $fs = Badger::Filesystem->new;
    if ($self->{type} eq 'dir') {
	if ($fs->dir_exists($self->{path})){
		#$fs->delete_dir($self->{path});
	}
	else {
		info(0,"Directory doesn't exists!");
	}
    }
    elsif ($self->{type} eq 'file'){
	if ($fs->file_exists($self->{path})) {
		@text = $fs->read_file($self->{path});
	}
	else {
		info(0,"File doesn't exists!");
	}
    } 
    else {
	info(0,"Wrong type!");
    }
    return @text;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : write
# Desc     : write file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub write($@)
{
    my $self = shift;
    $self->_init(type=>"file",cover=>0);
    my %hash = @_;   
    if (set_parameters($self,%hash)==$TEST_FAIL){
	return $TEST_FAIL;
    } 
    
    my $fs = Badger::Filesystem->new; 
    if ($self->{type} eq 'file'){
	if ($fs->file_exists($self->{path})) {
		if ($self->{cover} == 0){
			$fs->append_file($self->{path},"$self->{content}");
		}
		else {
			$fs->write_file($self->{path},"$self->{content}");
		}
	}
	else {
		info(0,"File doesn't exists but we created it!");
		if ($self->{cover} == 0){
			$fs->append_file($self->{path},"$self->{content}");
		}
		else {
			$fs->write_file($self->{path},"$self->{content}");
		}
	}
    } 
    else {
	info(0,"Wrong type!");
    }
    return $TEST_PASS;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Name     : chmod
# Desc     : chmod file or directory based on the arguments.
# Args     :
#              1. (HASH REF)  : Anonymous hash containing basic config
#              2. (SCALAR)    : file or direcotry's path
#              3. (SCALAR)    : type with default file
# Returns  :
#              success or failed
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub chmod($@)
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
    my $fs = Badger::Filesystem->new; 
    if ($self->{type} eq 'dir') {
	if ($fs->dir_exists($self->{path})){
		system("chmod -R $self->{mod} $self->{path}");
	}
	else {
		info(0,"Directory doesn't exists!");
	}
    }
    elsif ($self->{type} eq 'file'){
	if ($fs->file_exists($self->{path})) {
		$fs->chmod_path($self->{path},$self->{mod});
	}
	else{
		info(0,"File doesn't exists!");
	}
    } 
    else {
	info(0,"Wrong type!");
    }
    }
    return $TEST_PASS;
}


1;


