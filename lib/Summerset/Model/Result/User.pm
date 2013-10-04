package Summerset::Model::Result::User;
use Modern::Perl '2010';
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
use Carp;
use DateTime;
use Crypt::SaltedHash;
use String::Random;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("user");

__PACKAGE__->add_columns(
  "id"               => { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username"         => { data_type => "varchar", is_nullable => 0, size => 50 },
  "password"         => { data_type => "varchar", is_nullable => 1, size => 500 },
  "email"            => { data_type => "varchar", is_nullable => 0, size => 254 },
  "roles"            => { data_type => "varchar", is_nullable => 0, size => 500 },
  "internal_notes"   => { data_type => "text", is_nullable => 1 },
  "is_active"        => { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "confirmation_date"=> { data_type => "datetime", datetime_undef_if_invalid => 1, is_nullable => 1, },
  "confirmation_key" => { data_type => "varchar", is_nullable => 1, size => 45 },
  "reset_date"       => { data_type => "datetime", datetime_undef_if_invalid => 1, is_nullable => 1, },
  "reset_key"        => { data_type => "varchar", is_nullable => 1, size => 45 },
  "about_me"         => { data_type => "text", is_nullable => 1 },
  "city"             => { data_type => "varchar", is_nullable => 1, size => 50 },
  "province"         => { data_type => "varchar", is_nullable => 1, size => 50 },
  "country"          => { data_type => "varchar", is_nullable => 1, size => 3 },
  "last_active"      => { data_type => "datetime", datetime_undef_if_invalid => 1, is_nullable => 1, },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint("confirmation_key_UNIQUE", ["confirmation_key"]);
__PACKAGE__->add_unique_constraint("email_UNIQUE", ["email"]);
__PACKAGE__->add_unique_constraint("reset_key_UNIQUE", ["reset_key"]);
__PACKAGE__->add_unique_constraint("username_UNIQUE", ["username"]);


=head1 METHODS

=over 4


=item set_password(password)

Creates a new salted+hashed password for this object using SHA-1 and using a salt length of 4 bytes.
The new password hash is automatically updated to the database.  If there is a reset_key generated
for this account, it will automatically be cleared.

Returns: The string representation of the hashed password.  If this is an error, this method will 
return undef and write to STDERR.

Note: NO validation of password strength is done here.  If this is being run from the command line
then we're going to assume you're smart enough to set a big-boy password.. If this is being set 
from the web application, then validation has already been performed by our form classes.


=item generate_confirmation_key()

Generates a new, 45 character confirmation key for this user and saves it to the database.
This method will also reset the confirmation_time to null (in case it has been previously set).

Confirmation keys are guarenteed to be unique by the database, so there wouldn't be MUCH harm
in not verifying our key was unique (the application would just crash for the user that was trying
to generate the new confirmation key).. and the odds of generating a conflicting key are hugely minimal
(4.5459644e+80 possibilities) .. but just in the crazy one-off event that would ever occur .. we'll check.

Returns: The 45 character string confirmation key.


=item generate_reset_key()

Generates a new 45 character passsword reset key for the user and saves it to the database.
The reset_date field is set to the current date/time (this should be used in the controllers to 
enforce reset_key expiry). 

Returns: The 45 character string reset key


=back 

=cut

sub set_password {
    my $self = shift;
    my %args = @_;
    
    unless ($args{password}) {
        carp "Argument 'password' is required.";
        return undef;
    }
    
    my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
    $csh->add($args{password});
    
    my $pwd_hash = $csh->generate;
    
    $self->update({
        password    => $pwd_hash,
        reset_key   => undef,
        reset_date  => undef, 
    });    
    
    return $pwd_hash;    
}

sub generate_confirmation_key {
    my $self = shift;
        
    my $rnd = String::Random->new();
    my $key; 
    my $conflict;
    my $schema  = $self->result_source->schema;
    
    do {    
        $key        = $rnd->randregex('[a-zA-Z0-9]{45}');                   
        $conflict   = $schema->resultset('User')->search({ confirmation_key => $key })->count;
                
    } while ($conflict);
           
    $self->confirmation_key($key);
    $self->confirmation_date(undef);    
    $self->update;
    
    return $key;    
}

sub generate_reset_key {
    my $self = shift;
    
    my $rnd = String::Random->new;
    my $key;
    my $conflict;
    my $schema  = $self->result_source->schema;
    do {
        $key        = $rnd->randregex('[a-zA-Z0-9]{45}');        
        $conflict   = $schema->resultset('User')->search({ reset_key => $key })->count;
        
    } while ($conflict);
    
    $self->reset_key($key);
    $self->reset_date(DateTime->now);
    $self->update;
    
    return $key;
}


__PACKAGE__->meta->make_immutable;
1;