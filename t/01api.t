use strict;
use Test;
BEGIN { plan tests => 8 }
use NetworkInfo::Discovery::Rendezvous;

# check that the following functions are available
ok( defined \&NetworkInfo::Discovery::Rendezvous::new   );  #01
ok( defined \&NetworkInfo::Discovery::Rendezvous::do_it );  #02

# create an object
my $scanner = new NetworkInfo::Discovery::Rendezvous;
ok( defined $scanner                                    );  #03
ok( $scanner->isa('NetworkInfo::Discovery::Rendezvous') );  #04
ok( ref $scanner, 'NetworkInfo::Discovery::Rendezvous'  );  #05
 
# check that the following object methods are available
ok( ref $scanner->can('can')                   , 'CODE' );  #06
ok( ref $scanner->can('new')                   , 'CODE' );  #07
ok( ref $scanner->can('do_it')                 , 'CODE' );  #08
