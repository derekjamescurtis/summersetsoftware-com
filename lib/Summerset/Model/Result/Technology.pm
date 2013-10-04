package Summerset::Model::Result::Technology;
use Modern::Perl '2010';
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components('InflateColumn::DateTime');

__PACKAGE__->table('technology');

__PACKAGE__->add_columns(
    'id'            => { data_type => 'integer', is_auto_increment => 1, is_nullable => 0 },
    'slug'          => { data_type => 'varchar', is_nullable => 0, size => 100 },
    'name'          => { data_type => 'varchar', is_nullable => 0, size => 100 },
    'description'   => { data_type => 'text', is_nullable => 0 },
    'logo_url'      => { data_type => 'varchar', is_nullable => 1, size => 255 },
    'url'           => { data_type => 'varchar', is_nullable => 0, size => 255 },
    'is_language'   => { data_type => 'tinyint', is_nullable => 0, default => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint('slug_UNIQUE', ['slug']);

__PACKAGE__->many_to_many( 'projects', 'project_technology', 'project' );

__PACKAGE__->meta->make_immutable;
1;