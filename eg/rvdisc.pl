#!/usr/bin/perl
use strict;
use NetworkInfo::Discovery::Rendezvous;

@ARGV = qw(local.) and print "No domain specified. Using 'local.'\n" unless @ARGV;

my $scanner = new NetworkInfo::Discovery::Rendezvous domain => [ @ARGV ];
$scanner->do_it;

for my $host ($scanner->get_interfaces) {
    printf "%s (%s)\n", $host->{nodename}, $host->{ip};
    
    for my $service (@{$host->{services}}) {
        printf "  %s (%s:%d) %s\n", $service->{name}, $service->{proto}, 
            $service->{port}, join(', ', 
                map { $_ && $_.'='.$service->{attrs}{$_} } keys %{$service->{attrs}}
            ) || ''
    }
}
