<?php
# Plugin "PostgreSQL Infos" OCSInventory
# Author: Léa DROGUET

 /**
  * This file is used to build a table refering to the plugin and define its 
  * default columns as well as SQL request.
  */

if (AJAX) {
    parse_str($protectedPost['ocs']['0'], $params);
    $protectedPost += $params;
    ob_start();
    $ajax = true;
} else {
    $ajax = false;
}


// print a title for the table
print_item_header($l->g(52000));

if (!isset($protectedPost['SHOW'])) {
    $protectedPost['SHOW'] = 'NOSHOW';
}

// form details and tab options
$form_name = 'postgresqlinfos';
$table_name = $form_name;
$tab_options = $protectedPost;
$tab_options['form_name'] = $form_name;
$tab_options['table_name'] = $table_name;


echo open_form($form_name);


$list_fields = array(
    $l->g(52001) => 'CLUSTERNAME',
    $l->g(52002) => 'PGVERSION',
    $l->g(52003)  => 'PGPORT',
    $l->g(52004) => 'PGDATABASES',
    $l->g(52005)  => 'ROLE',
);


// columns to include at any time and default columns
$list_col_cant_del = $list_fields;
$default_fields = $list_fields;

// select columns for table display
$sql = prepare_sql_tab($list_fields);
$sql['SQL']  .= "FROM postgresqlinfos WHERE (hardware_id = $systemid)";

array_push($sql['ARG'], $systemid);
$tab_options['ARG_SQL'] = $sql['ARG'];
$tab_options['ARG_SQL_COUNT'] = $systemid;
ajaxtab_entete_fixe($list_fields, $default_fields, $tab_options, $list_col_cant_del);

echo close_form();


if ($ajax) {
    ob_end_clean();
    tab_req($list_fields, $default_fields, $list_col_cant_del, $sql['SQL'], $tab_options);
    ob_start();
}
?>
