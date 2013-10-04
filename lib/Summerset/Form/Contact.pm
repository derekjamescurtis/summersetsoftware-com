package Summerset::Form::Contact;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+is_html5'       => ( default => 0 );
has '+widget_wrapper' => ( default => 'Bootstrap3' );

has_field 'name'    => ( type => 'Text', required => 1 );
has_field 'company' => ( type => 'Text' );
has_field 'email'   => ( type => 'Email' );
has_field 'message' => ( type => 'TextArea', required => 1 );
has_field 'submit'  => ( type => 'Submit', value => 'Send' );

1;
