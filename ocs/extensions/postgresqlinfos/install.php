<?php
/**
 * The following functions are used by the extension engine to generate a new table
 * for the plugin / destroy it on removal.
 */


/**
 * This function is called on installation and is used to 
 * create database schema for the plugin
 */
function extension_install_postgresqlinfos() {
    $commonObject = new ExtensionCommon;
    $commonObject -> sqlQuery("DROP TABLE IF EXISTS `postgresqlinfos`");
    $commonObject -> sqlQuery(
        "CREATE TABLE IF NOT EXISTS `postgresqlinfos` (
        ID INT(11) NOT NULL AUTO_INCREMENT, 
        HARDWARE_ID INT(11) NOT NULL,
        CLUSTERNAME VARCHAR(255) NOT NULL,
        PGVERSION VARCHAR(255) NOT NULL,
        PGPORT INTEGER(11) NOT NULL,
        PGDATABASES VARCHAR(255) NOT NULL,
        ROLE VARCHAR(255) NOT NULL,
        PRIMARY KEY (ID, HARDWARE_ID)) ENGINE=INNODB;"
    );
}

/**
 * This function is called on removal and is used to 
 * destroy database schema for the plugin
 */
function extension_delete_postgresqlinfos()
{
    $commonObject = new ExtensionCommon;
    $commonObject -> sqlQuery("DROP TABLE IF EXISTS `postgresqlinfos`");
}

/**
 * This function is called on plugin upgrade
 */
function extension_upgrade_postgresqlinfos()
{

}

?>