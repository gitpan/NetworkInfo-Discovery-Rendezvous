package NetworkInfo::Discovery::Rendezvous;
use strict;
use Carp;
use Net::Rendezvous;
use NetworkInfo::Discovery::Detect;

{ no strict;
  $VERSION = '0.01';
  @ISA = qw(NetworkInfo::Discovery::Detect);
}

=head1 NAME

NetworkInfo::Discovery::Rendezvous - NetworkInfo::Discovery extension to find Rendezvous services

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use NetworkInfo::Discovery::Rendezvous;

    my $scanner = new NetworkInfo::Discovery::Rendezvous domain => 'example.net';
    $scanner->do_it;
    
    

=head1 DESCRIPTION

This module is an extension to C<NetworkInfo::Discovery> which can find 
services that register themselves using DNS-SD (DNS Service Discovery), 
the services discovery protocol behind Apple Rendezvous. 

It will first try to enumerate all the registered services by querying 
the C<dns-sd> pseudo-service, which is available since the latest versions 
of mDNSResponder. If nothing is returned, it will then query some well-known 
services like C<afpovertcp>. 

=head1 METHODS

=over 4

=item new()

Create and return a new object. 

B<Options>

=over 4

=item *

C<domain> - expects a scalar or an arrayref of domains

=back

B<Example>

    # with a scalar argument
    my $scanner = new NetworkInfo::Discovery::Rendezvous domain => 'example.net';

    # with an arrayref
    my $scanner = new NetworkInfo::Discovery::Rendezvous domain => [ qw(local example.net) ];

=cut

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    my %args = @_;
    
    $class = ref($class) || $class;
    bless $self, $class;
    
    # add private fiels
    $self->{_domains_to_scan} = [];
    
    # treat given arguments
    for my $attr (keys %args) {
        $self->$attr($args{$attr}) if $self->can($attr);
    }
    
    return $self
}

=item do_it()

Run the services discovery. 

=cut

sub do_it {
    my $self = shift;
    
    for my $domain (@{$self->{_domains_to_scan}}) {
        # first, try to find all registered services in the domain
        my $services = undef;
        eval {
            $services = Net::Rendezvous->enumerate_services;
        };
        
        # if services enumeration worked, try to find all instances of each service
        if(defined $services and $services->entries) {
            for my $service ($services->entries) {
                $self->discover_service($service->name, $service->protocol, $domain)
            }
        
        # if it failed, try to find common services
        } else {
            $self->discover_service('afpovertcp', 'tcp', $domain);  # afpovertcp shares
            $self->discover_service('ipp',        'tcp', $domain);  # CUPS servers
            $self->discover_service('printer',    'tcp', $domain);  # printing servers
        }
    }
    
    # return list of found hosts
    return $self->get_interfaces
}

=item discover_service()

Discover instances of a given service. 

=cut

sub discover_service {
    my $self = shift;
    my($service,$proto,$domain) = @_;
    
    my $rsrc = new Net::Rendezvous;
    $rsrc->application($service, $proto);
    $rsrc->domain($domain);
    $rsrc->discover;
    
    for my $entry ($rsrc->entries) {
        # host name: $entry->name
        # host addr: $entry->address
        # host services: 
        #   > this service: 
        #       service name: $service
        #       service fqdn: $entry->fqdn
        #       service port: $entry->port
        #       service attr: $entry->all_attrs
        $self->add_interface({
            ip => $entry->address, nodename => $entry->name, service => {
                name => $service, port => $entry->port, proto => $proto, 
                fqdn => $entry->fqdn, attrs => { $entry->all_attrs }
            }
        })
    }
}

=item domain()

Add domains to the search list.

B<Examples>

    $scanner->domain('zeroconf.org');
    $scanner->domain(qw(local zeroconf.org example.com));

=cut

sub domain {
    my $self = shift;
    if(ref $_[0] eq 'ARRAY') {
        push @{$self->{_domains_to_scan}}, @{$_[0]}
    } elsif(ref $_[0]) {
        croak "Don't know how to deal with a ", lc(ref($_[0])), "ref."
    } else {
        push @{$self->{_domains_to_scan}}, @_
    }
}

=back

=head1 SEE ALSO

L<NetworkInfo::Discovery>, L<Net::Rendezvous>

=head1 AUTHOR

Sébastien Aperghis-Tramoni, E<lt>sebastien@aperghis.netE<gt>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-networkinfo-discovery-rendezvous@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2004 Sébastien Aperghis-Tramoni, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of NetworkInfo::Discovery::Rendezvous
