package DDNS;

use Dancer ':syntax';
use Dancer::Plugin::Database;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/ddns/:ID' => sub {

  my $ENTRY = qq(
    SELECT hostname, domain
      FROM ddns 
        WHERE id         = ?
              AND active = 1
  );

  my $sth_entry = database->prepare( $ENTRY );
  $sth_entry->execute( params->{ID} );

  my $entry = $sth_entry->fetchrow_hashref ;

  if ( ( defined $entry->{hostname} && $entry->{hostname} ne '' ) 
       && 
       ( defined $entry->{domain}   && $entry->{domain}   ne '' ) ) {

    my $cmd = "/home/ddns/apps/DDNS/ddns-bin/ddns_server.sh " 
            . $entry->{domain} .  " "
            . $entry->{hostname} . " "
            . request->forwarded_for_address;

    debug $cmd;

    my $ret = `$cmd`;
    debug $ret;

    my $SEEN = qq(
      UPDATE ddns
        SET last_seen = NULL
          WHERE id         = ?
    );

    my $sth_seen = database->prepare( $SEEN );
    $sth_seen->execute( params->{ID} );

    to_json { status => 1 } ;
  } else {
    to_json { status => 0 } ;
  }
 
};


1;


