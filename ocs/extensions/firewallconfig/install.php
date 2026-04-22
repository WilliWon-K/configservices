<?php
/*
====================================================================================
 OCS INVENTORY PLUGINS
 Web: http://www.ocsinventory-ng.org
 
This code is open source and may be copied and modified as long as the source code is always made freely available.
Please refer to the General Public Licence http://www.gnu.org/ or LiCENSE.MD
====================================================================================
*/

/**
 * This function is called on installation and is used to create database schema for the plugin
 */
function extension_install_firewallconfig()
{
    $commonObject = new ExtensionCommon;

    // Remove older tables
    $commonObject->sqlQuery("DROP TABLE IF EXISTS `firewallconfig`;");

    // Install tables
    $commonObject->sqlQuery("CREATE TABLE IF NOT EXISTS `firewallconfig` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `HARDWARE_ID` int(11) NOT NULL,
        `PROFILE` varchar(255) DEFAULT NULL,
        `STATE` varchar(255) DEFAULT NULL,
        `FIREWALLPOLICY` varchar(255) DEFAULT NULL,
        `LOCALFIREWALLRULES` varchar(255) DEFAULT NULL,
        `FILENAME` varchar(255) DEFAULT NULL,
        `MAXFILESIZE` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`ID`,`HARDWARE_ID`)
      )  ENGINE=INNODB ;");   
}

/**
 * This function is called on removal and is used to destroy database schema for the plugin
 */
function extension_delete_firewallconfig()
{
    $commonObject = new ExtensionCommon;
    $commonObject->sqlQuery("DROP TABLE IF EXISTS `firewallconfig`;");
}

/**
 * This function is called on plugin upgrade
 */
function extension_upgrade_firewallconfig()
{

}
