# Plugin "PostgreSQL Infos" OCSInventory
# Author: Léa DROGUET
package Ocsinventory::Agent::Modules::Postgresqlinfos;


sub new {

    my $name="postgresqlinfos"; # Name of the module

    my (undef,$context) = @_;
    my $self = {};

    #Create a special logger for the module
    $self->{logger} = new Ocsinventory::Logger ({
        config => $context->{config}
    });
    $self->{logger}->{header}="[$name]";
    $self->{context}=$context;
    $self->{structure}= {
        name => $name,
        start_handler => undef,    #or undef if don't use this hook
        prolog_writer => undef,    #or undef if don't use this hook
        prolog_reader => undef,    #or undef if don't use this hook
        inventory_handler => $name."_inventory_handler",    #or undef if don't use this hook
        end_handler => undef       #or undef if don't use this hook
    };
    bless $self;
}

######### Hook methods ############
sub postgresqlinfos_inventory_handler {

    my $self = shift;
    my $logger = $self->{logger};
    my $common = $self->{context}->{common};
    
    $logger->debug("Yeah you are in postgresqlinfos_inventory_handler:)");
    
    # check if psql available
    if (`su postgres -c 'psql --version' 2>/dev/null`) {
        $logger->debug("postgresqlinfos : psql command found");
    } else {
        $logger->debug("postgresqlinfos : psql command not found");
        return;
    }

    # get cluster name
    my $cluster = `su postgres -c 'psql -Xtc "show cluster_name;"'`;
    $cluster = trim($cluster);

    # get postgresql version
    my $version = `su postgres -c 'psql -Xtc "show server_version;"'`;
    $version = trim($version);

    # get postgresql port
    my $port = `su postgres -c 'psql -Xtc "show port;"'`;
    $port = trim($port);

    # get postgresql database
    my $database = `su postgres -c "psql -Xtc \\"select datname from pg_database where datname not in ('template1', 'template0', 'postgres');\\""`;
    # trimming and replacing newlines
    $database = trim($database);
    my @databases = split(/\s+/, $database);
    foreach my $db (@databases) {
        $db = trim($db);
    }
    $database = join(',', @databases);
    $database = trim($database);

    # get roles
    my $role = `su postgres -c "psql -qtAX -c \\"select substring(conninfo, 'host=([^ ]*) ') from pg_stat_wal_receiver;\\""`;
    $role = trim($role);
    if ($role eq '') {
        $role = 'Primary';
    } else {
        $role = 'Standby';
    }

    push @{$common->{xmltags}->{POSTGRESQLINFOS}},
    {
        CLUSTERNAME => [$cluster],
        PGVERSION => [$version],
        PGPORT => [$port],
        PGDATABASES => [$database],
        ROLE => [$role]
    };

}

sub trim {
    ($string) = @_;
    $string =~ s/^\s+|\s+$//g;
    return $string;
}

1;