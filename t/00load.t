use strict;
use File::Spec;
use Test::More tests => 1;

BEGIN {
    use_ok( 'NetworkInfo::Discovery::Rendezvous' );
}

diag( "Testing NetworkInfo::Discovery::Rendezvous $NetworkInfo::Discovery::Rendezvous::VERSION" );

my $requires = undef;

# checking if this distribution is being installed using Module::Build
if(0 and open(PREREQS, File::Spec->catfile('_build', 'prereqs'))) {
    # yep, so read the prereqs
    my $prereqs = eval do { local $/; <PREREQS> };
    $requires = $prereqs->{requires};

} elsif( -f 'META.yml') {
    eval <<'YAML'
        use YAML;
        my $prereqs = YAML::LoadFile('META.yml');
        $requires = $prereqs->{requires};
YAML
}

if(defined $requires) {
    for my $req (keys %$requires) {
        diag( "  using $req ".($req->VERSION||'') )
    }
}
