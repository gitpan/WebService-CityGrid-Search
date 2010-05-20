package WebService::CityGrid::Search;

use strict;
use warnings;

=head1 NAME

WebService::CityGrid::Search - Interface to the CityGrid Search API

=cut

use Any::Moose;
use Any::URI::Escape;

has 'api_key'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'publisher' => ( is => 'ro', isa => 'Str', required => 1 );

our $api_host = 'api2.citysearch.com';
our $api_base = "http://$api_host/search/";
our $VERSION  = '0.01';

=head1 METHODS

=over 4

=item make_url

  $url = $cs->make_url({
      mode => 'locations', 
      where => '90210',
      what  => 'pizza%20and%20burgers', });

Construct a url to make a call against the CityGrid API.

=cut

sub make_url {
    my ( $self, $args ) = @_;

    die "key mode missing, can be locations or events"
      unless ( defined $args->{mode} && ( $args->{mode} eq 'locations' )
        or ( $args->{mode} eq 'events' ) );

    my $url =
        $api_base
      . $args->{mode}
      . '?api_key='
      . $self->api_key
      . '&publisher='
      . $self->publisher . '&';
    delete $args->{mode};

    for (qw( what where )) {
        die "missing required arg $_" unless defined $_;
    }

    foreach my $arg ( keys %{$args} ) {

        die "invalid key $arg" unless grep { $arg eq $_ } qw( type what tag
              chain event first feature where lat lon radius from to page rpp
              sort publisher api_key placement format callback );

        $url .= join( '=', $arg, $args->{$arg} ) . '&';
    }
    $url = substr( $url, 0, length($url) - 1 );

    return $url;
}

=item javascript_tracker

Under construction

=back

=cut

sub javascript_tracker {
    my $self = shift;

    return <<END;
<script type=”text/javascript”>
    var _csv = {};
        _csv['action_target'] = '***'; 
        _csv['listing_id'] = '***'; 
        _csv['publisher'] = '***'; 
        _csv['reference_id'] = '***'; 
        _csv['placement'] = '***';
        _csv['mobile_type'] = '***';
        _csv['muid'] = '***';
        _csv['ua'] = '***'
</script>
<script type="text/javascript" src="http://images.citysearch.net/assets/pfp/scripts/tracker.js">/script>

<noscript>
<img src='http://api.citysearch.com/tracker/imp?action_target=***&listing_id=***&publisher=***&reference_id=***&placement=***&mobile_type=***&muid=***&ua=***' width='1' height='1' alt='' />
</noscript>
END
}

__PACKAGE__->meta->make_immutable;

1;

=head1 SYNOPSIS

  use WebService::CityGrid::Search;
  $cs = WebService::CityGrid::Search->new(
      api_key   => $my_apikey,
      publisher => $my_pubid, );

  $url = $cs->make_url({ mode => 'locations', 
      where => '90210',
      what  => 'pizza%20and%20burgers', });

=head1 DESCRIPTION

Currently just returns a url that can represents a call to the CityGrid Web Service.

=head1 SEE ALSO

L<http://developer.citysearch.com/docs/search/>

=head1 AUTHOR

Fred Moyer, E<lt>fred@slwifi.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Silver Lining Networks

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
