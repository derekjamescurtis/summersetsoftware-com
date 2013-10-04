package Summerset::Model::Result::Project;
use Modern::Perl '2010';
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components('InflateColumn::DateTime');

__PACKAGE__->table('project');

__PACKAGE__->add_columns(
    'id'          => { data_type => 'integer', is_auto_increment => 1, is_nullable => 0 },
    'slug'        => { data_type => 'varchar', is_nullable => 0, size => 100 },
    'name'        => { data_type => 'varchar', is_nullable => 0, size => 100 },
    'url'         => { data_type => 'varchar', is_nullable => 0, size => 255 },
    'date'        => { data_type => 'datetime', is_nullable => 0, datetime_undef_if_invalid => 1, },
    'description' => { data_type => 'text', is_nullable => 0 },
    'image_url'   => { data_type => 'text', is_nullable => 1, size => 255 },    
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint('slug_UNIQUE', ['slug']);

__PACKAGE__->many_to_many('technologies', 'project_technology', 'technology');

__PACKAGE__->meta->make_immutable;
1;