package Summerset::Model::Result::Blog;
use Modern::Perl '2010';
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components('InflateColumn::DateTime');

__PACKAGE__->table('blog');

__PACKAGE__->add_columns(
    'id'        => { data_type => 'integer', is_auto_increment => 1, is_nullable => 0 },
    'slug'      => { data_type => 'varchar', is_nullable => 0, size => 100 },
    'title'     => { data_type => 'varchar', is_nullable => 0, size => 100 },
    'content'   => { data_type => 'text', is_nullable => 0 },    
    'author_id' => { data_type => 'integer', is_nullable => 0 },
    'pub_date'  => { data_type => 'datetime', is_nullable => 1, datetime_undef_if_invalid => 1 },
    'edit_date' => { data_type => 'datetime', is_nullable => 0, datetime_undef_if_invalid => 1 },    
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint('slug_UNIQUE', ['slug']);
__PACKAGE__->belongs_to(
    'author',
    'Summerset::Model::Result::User',
    { id => 'author_id'},
    { is_deferrable => 1, on_delete => 'NO ACTION', on_update => 'NO ACTION' },
);

__PACKAGE__->meta->make_immutable;
1;