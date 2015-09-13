package DDNS;

use Dancer ':syntax';
use Dancer::Plugin::Database;

use WebService::DigitalOcean;
my $do = WebService::DigitalOcean->new( { token => config->{ddns}->{token} } );

our $VERSION = '0.0002';

get '/' => sub {
  template 'index';
};

# This is the only valid route
get '/ddns/:ID' => sub {

  to_json { status => update_ip( params->{ID}, request->forwarded_for_address) };

};


# Match record and update ddns and DB
sub update_ip {
  my $ID   = shift;
  my $IP   = shift;

  # Only if this is an active ID
  my $ACTIVE = qq(
    SELECT hostname, domain
      FROM ddns 
        WHERE id         = ?
              AND active = 1
  );

  my $sth_entry = database->prepare($ACTIVE) ;
  $sth_entry->execute($ID);

  my $entry = $sth_entry->fetchrow_hashref;

  if ( defined $entry->{hostname} && $entry->{hostname} ne '' ) {

    # Make an A record if it doesn't exist
    insert_update_ddns_entry( $entry->{domain}, $entry->{hostname}, $IP );

    # Update time and active_ddns status
    my $UPDATE = qq(
      UPDATE ddns
        SET active_ddns = 1,
            updated     = NULL
          WHERE id      = ?
    );

    my $sth_seen = database->prepare($UPDATE);
    $sth_seen->execute($ID);

# Need more error checking
    return 1;

  } else {

    return 0;

  }
}

# Future implementation
sub deactivate_ddns_entry {
  my $date_since = shift;

  # Deactivate old DDNS entries
  my $TOO_OLD = qq(
    SELECT hostname, domain
      FROM ddns 
        WHERE updated         >= ?
              AND active_ddns  = 1
  );

  my $sth_old = database->prepare($TOO_OLD);
  $sth_old->execute($date_since);

  while ( my $entry = $sth_old->fetchrow_hashref ) {
    insert_update_ddns_entry( $entry->{domain}, $entry->{hostname}, 'DELETE' );
  }
}

# Actual work is done here
sub insert_update_ddns_entry {
  my $domain   = shift;
  my $hostname = shift;
  my $ip       = shift;

  # Get a list to match against
  my $response = $do->domain_record_list($domain);

  my $matched = undef;
  if ( $response->{is_success} ) {
    my $domain_list = $response->{content};

    foreach my $rec ( @{$domain_list} ) {
      if ( $rec->{name} eq $hostname ) {
        $matched = $rec;
        debug "Found $matched->{id} $matched->{name} $matched->{data}\n";
      }
    }

    # Delete if a match is found with a different IP or DELETE
    if ( $matched->{name} ne '' && $matched->{ip} ne $ip ) {
      $do->domain_record_delete(
                                 {
                                   domain => $domain,
                                   id     => $matched->{id},
                                 }
      );

      debug "Deleted $matched->{id}\n";
    }

    # If it's an IP, then add it
    if ( $ip ne 'DELETE' ) {
      my $response =
        $do->domain_record_create(
                                   {
                                     domain => $domain,
                                     type   => 'A',
                                     name   => $hostname,
                                     data   => $ip,
                                   }
        );

      debug "Added a new entry\n";
    }

  } else {
    debug "Failed to contact WebService\n";
  }

}

1;

