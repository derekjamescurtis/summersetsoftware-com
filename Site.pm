use Mojolicious::Lite;
use lib 'lib';
use Summerset::Form::Contact;
use Summerset::Model;


helper db => sub {
	return Summerset::Model->connect('dbi::SQLite:summerset.db');
};

get '/' => sub {
	my $self = shift;
	$self->render;
} => 'index';

get '/projects' => sub {
	my $self = shift;
	$self->render( text => 'Projects hello!');
};

get '/services' => sub {
	my $self = shift;
	$self->render( text => 'Services hello!');
};

any '/contact' => sub { 
    my $self = shift;	
    
    my $f = Summerset::Form::Contact->new;
    
    if ( $self->req->method eq 'POST' ) {
    	
    	$f->process( params => $self->req->params->to_hash );
        
        if ($f->validated) {
	        $self->render( text => 'validated??');
	        # stash message sent message
	        # redirect to main page
	    }	    
    }
    	 
    $self->stash( form => $f );	
    $self->render;
};

any '/login' => sub {
	my $self = shift;
};
get '/logout' => sub {
	my $self = shift;
};



app->start;

__DATA__
@@ index.html.ep
<h1>Hello world, but bigger!</h1>

@@ projects.html.ep
<h1>Projects</h1>

@@ services.html.ep
<h1>Services</h1>

@@ contact.html.ep
<h1>Contact</h1>
<%== $form->render %>

@@ login.html.ep
<h1>Login</h1>
<%== $form->render %>
