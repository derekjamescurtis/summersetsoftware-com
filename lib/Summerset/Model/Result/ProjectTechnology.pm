package Summerset::Model::Result::ProjectTechnology;
use Modern::Perl '2010';
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components('InflateColumn::DateTime');

__PACKAGE__->table('project_technology');

__PACKAGE__->add_columns(
    'project_id'    => { data_type => 'integer', is_foreign_key => 1, is_nullable => 0 },
    'technology_id' => { data_type => 'integer', is_foreign_key => 1, is_nullable => 0 },
);

__PACKAGE__->set_primary_key('project_id', 'technology_id');

__PACKAGE__->belongs_to( 
    'project',  
    'Summerset::Model::Result::Project',
    { id => 'project_id' },
    { is_deferrable => 1, on_delete => 'NO ACTION', on_update => 'NO ACTION' },
);
__PACKAGE__->belongs_to(
    'technology',
    'Summerset::Model::Result::Technology',
    { id => 'technology_id' },
    { is_deferrable => 1, on_delete => 'NO ACTION', on_update => 'NO ACTION' }, 
);


__PACKAGE__->meta->make_immutable;
1;