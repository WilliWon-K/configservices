
 
package Apache::Ocsinventory::Plugins::Firewallconfig::Map;
 
use strict;
 
use Apache::Ocsinventory::Map;

$DATA_MAP{firewallconfig} = {
		mask => 0,
        	multi => 1,
        	auto => 1,
        	delOnReplace => 1,
        	sortBy => 'PROFILE',
        	writeDiff => 0,
        	cache => 0,
        	fields => {
        		PROFILE => {},
				STATE => {},
				FIREWALLPOLICY => {},
				LOCALFIREWALLRULES => {},
				FILENAME => {},
				MAXFILESIZE => {}
}
};
1;
