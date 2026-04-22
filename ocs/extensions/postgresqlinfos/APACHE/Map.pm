package Apache::Ocsinventory::Plugins::Postgresqlinfos::Map;

use strict;
use Apache::Ocsinventory::Map;

$DATA_MAP{POSTGRESQLINFOS} = {
   mask => 0,
   multi => 1,
   auto => 1,
   delOnReplace => 1,
   sortBy => 'CLUSTERNAME',
   writeDiff => 0,
   cache => 0,
   fields => {
        CLUSTERNAME => {},
        PGVERSION   => {},
        PGPORT      => {},
        PGDATABASES => {},
        ROLE        => {},
   }
};

1;
