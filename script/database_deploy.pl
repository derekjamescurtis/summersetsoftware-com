#!/usr/bin/env perl
use Modern::Perl '2010';
use Config::General qw/ParseConfig/;
use FindBin qw/$RealBin/;
use Path::Class;
use lib dir($RealBin, '..', 'lib')->stringify;
use Summerset::Model;
use Try::Tiny;

=head1 NAME 

database_deploy.pl

=head1 DESCRIPTION

This is a simple module that will deploy the model classes in this installation 
to whichever connection string you've configured in myapp.conf.  Originally, I 
generated these model classes from MySQL, however you can just as well use this
script to deploy and run the database from SQLite or Postgres.  

=cut

try {
    
    print 'Opening our config file...';
    my $conf_filename   = file($RealBin, '..', 'summerset.conf');
    my %cfg             = new Config::General(-ConfigFile => $conf_filename, -ApacheCompatible => 1)->getall;
    my $schema          = Summerset::Model->connect(@{$cfg{'Model'}->{connect_info}}) or die "Failed to connect to database";     
    say 'Done!';
    
    
    print 'Preparing to deploy database...';        
    $schema->deploy();    
    say 'Done!';
    
}
catch {
    say 'Hey.. sorry.  Something went wrong =/';  
    say "I got this error message: $_";
};
