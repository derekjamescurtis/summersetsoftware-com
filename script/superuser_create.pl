#!/usr/bin/env perl
use Modern::Perl '2010';
use Config::General qw/ParseConfig/;
use FindBin qw/$RealBin/;
use Path::Class;
use lib dir($RealBin, '..', 'lib')->stringify;
use Summerset::Model;
use Getopt::Long;
use Try::Tiny;
use DateTime;
use Email::Valid;

=head1 NAME 

admin_create.pl

=head1 DESCRIPTION

This simple script will create a superuser for our application.  
Wherease the deploy script is not unique to our application, this script is
although it can easily be modified (privilges, password handling, etc..).

Once the superuser is created, they're not required to confirm their e-mail address.

=cut


my $username; 
my $email;
my $password;
my $usage;
GetOptions(
    'username=s'    => \$username,
    'email=s'       => \$email,
    'password=s'    => \$password,
    'help|usage'  => \$usage,
);


if ($usage) {
    say &usage();
    exit 1;
}


try {
    
    # first off, do some basic input validation
    die 'Missing one or more required parameters: \n' . &usage() 
        unless $username && $password && $email;
    die "The e-mail address you provided (${email}) does not appear valid" unless Email::Valid->address( $email );
    
    # create a database schema object based on their current configuration
    my $conf_filename   = file($RealBin, '..', 'jakartapm.conf');
    my %cfg             = new Config::General(-ConfigFile => $conf_filename, -ApacheCompatible => 1)->getall;
    my $schema          = Summerset::Model->connect(@{$cfg{'Model'}->{connect_info}}) or die "Failed to connect to database";     
    
    # insert the user object, automatically confirm it
    my $u = $schema->resultset('User')->create({
        username            => $username,
        email               => $email,
        roles               => 'superuser',
        confirmation_date   => DateTime->now(),
    });
    $u->set_password( password => $password );
    $u->update();
    
    # everything went well. we're done here.
    say "Created superuser $username (" . $u->id .  ')'; 
    
}
catch {
    say 'Hey.. sorry.  Something went wrong =/';  
    say "I got this error message: $_";
};


sub usage() {
    
    print "\n";
    say "Usage: ";
    say "database_deploy.pl --username myUsername --email myUsername\@something.com --password myCoolPassword";
    say "Note:  Since you are using the command line script, it is assumed that you are a big kid and can provide a good password so no enforcement is done here.";
    print "\n\n";
    
}
