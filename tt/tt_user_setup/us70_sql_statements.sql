-- IMPORTANT: read comments about insert statements further down in this file.

-- Space lines in groups of four to make it easier for to get the C++
-- code in agreement with the SQL.

-- Stick to ANSI SQL.   Avoid Access specific sql syntax.

-- Start the name with "private_" if it's not supposed to be used from outside the app directly.
-- For example, instead of insert_account, name it private_insert_account.    We don't want
-- accounts to be inserted bypassing the scheme for notifying the risk server.

-- You can #include files like this:
-- #include sql_statements_for_replication.sql
-- The files must be in the same folder as the main file.

-- ctrager

#include sql_statements_for_replication.sql
#include sql_statements_for_hfs.sql
#include sql_statements_for_x_risk.sql
#include sql_statements_for_x_trader.sql
#include sql_statements_for_autocredit.sql
#include sql_statements_for_ttus_server.sql

-----------------------------------------------------------------------
-- lookup tables starts here
-----------------------------------------------------------------------


--$get_currencies
SELECT 
'A' as [action],
tt_currency.crn_currency_id, 
tt_currency.crn_abbrev, 
tt_currency.crn_last_updated_datetime, 
tt_login_server_settings.lss_primary_currency_abbrev,
tt_user.user_login AS last_updated_user_login
FROM (tt_currency LEFT JOIN tt_user ON tt_currency.crn_last_updated_user_id = tt_user.user_id) LEFT JOIN tt_login_server_settings ON tt_currency.crn_abbrev = tt_login_server_settings.lss_primary_currency_abbrev;

--$get_markets
select * from tt_market order by market_name

--$get_gateways
SELECT
tt_gateway.gateway_id, 
tt_gateway.gateway_name, 
tt_gateway.gateway_market_id, 
tt_gateway.gateway_locked, 
tt_gateway.gateway_last_updated_datetime, 
tt_gateway.gateway_is_active,
tt_user.user_login AS last_updated_user_login 
from tt_gateway
LEFT JOIN tt_user 
ON tt_gateway.gateway_last_updated_user_id = tt_user.user_id
where gateway_id <> 0

--$get_countries
select * from tt_country order by country_name

--$get_states
select * from tt_us_state order by state_abbrev

--$get_account_types
SELECT accType_id, acctType_code
FROM tt_account_type order by acctType_code;

--$get_order_restrictions
SELECT ordrest_code, ordrest_short_description
FROM tt_order_restriction order by ordrest_short_description;

--$get_product_types
SELECT product_id, product_description
FROM tt_product_type order by product_description;

--$get_x_trader_mode
SELECT x_trader_mode_id, x_trader_mode_name
FROM tt_x_trader_mode;

--$get_algo_types
SELECT al_algo_id, al_algo_name
FROM tt_algos;

--$get_tt_apps
select ttapp_app_id, ttapp_display_name, ttapp_allow_user_to_create_rule 
from tt_tt_app
where ttapp_display_in_version_rules = 1
order by ttapp_display_order, ttapp_display_name

-----------------------------------------------------------------------
-- lookup tables ends here
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- "gets" used by User Setup client start here
--
--  The number after the name indicates which ? corresponds to the 
--  logged in user's id.   
--  There server fills in that arg instead of the client.  So, 
--  for example:
--  If there are two question marks and the number is 1, the client
--  supplies the value for the 2nd question mark, while the server
--  supplies the value for the 1st one.
-----------------------------------------------------------------------

--$get_currency_exchange_rates
SELECT 
'A' as [action],
tt_currency.crn_abbrev AS from_currency, 
tt_currency_1.crn_abbrev AS to_currency, 
cex_exchange_rate_id,
cex_created_datetime,
cex_last_updated_datetime,
cex_rate_times_10000, 
tt_user.user_login AS last_updated_user_login
FROM (tt_currency 
INNER JOIN (tt_currency_exchange_rate 
INNER JOIN tt_currency AS tt_currency_1 
ON tt_currency_exchange_rate.cex_to_currency_id = tt_currency_1.crn_currency_id) 
ON tt_currency.crn_currency_id = tt_currency_exchange_rate.cex_from_currency_id) 
LEFT JOIN tt_user ON tt_currency_exchange_rate.cex_last_updated_user_id = tt_user.user_id;

--$get_app_version_rules

SELECT  
tt_app_version_rule.*,
tt_user.user_login AS last_updated_user_login
FROM tt_app_version_rule LEFT JOIN tt_user 
ON tt_app_version_rule.avr_last_updated_user_id = tt_user.user_id

-----------------------------------------------------------------------

--$get_work_items_restricted,1
-- same as unrestricted for now...
SELECT tt_work_item.*, tt_user_last_updated.user_login AS last_updated_user_login, tt_user_created.user_login AS created_user_login
FROM ((tt_company 
INNER JOIN ((tt_work_item 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_work_item.wi_last_updated_user_id = tt_user_last_updated.user_id) 
LEFT JOIN tt_user AS tt_user_created ON tt_work_item.wi_created_user_id = tt_user_created.user_id) 
ON tt_company.comp_id = tt_work_item.wi_created_by_comp_id or tt_company.comp_id = tt_work_item.wi_assigned_to_comp_id) 
INNER JOIN tt_user_group ON tt_company.comp_id = tt_user_group.ugrp_comp_id) 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id
where tt_user.user_id = ?


--$get_work_items_bycompany,1
SELECT tt_work_item.*, tt_user_last_updated.user_login AS last_updated_user_login, tt_user_created.user_login AS created_user_login
FROM tt_company 
INNER JOIN ((tt_work_item 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_work_item.wi_last_updated_user_id = tt_user_last_updated.user_id) 
LEFT JOIN tt_user AS tt_user_created ON tt_work_item.wi_created_user_id = tt_user_created.user_id) 
ON tt_company.comp_id = tt_work_item.wi_created_by_comp_id or tt_company.comp_id = tt_work_item.wi_assigned_to_comp_id
where tt_company.comp_id = ?

--$get_work_items_unrestricted

SELECT tt_work_item.*, tt_user_last_updated.user_login AS last_updated_user_login, tt_user_created.user_login AS created_user_login
FROM (tt_work_item 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_work_item.wi_last_updated_user_id = tt_user_last_updated.user_id) 
LEFT JOIN tt_user AS tt_user_created ON tt_work_item.wi_created_user_id = tt_user_created.user_id;


-----------------------------------------------------------------------

--$get_company_market_products_restricted
-- same as unrestricted
select tt_company_market_product.*, 
tt_user_last_updated.user_login AS last_updated_user_login 
FROM (tt_company_market_product LEFT JOIN (tt_user AS tt_user_last_updated)
	  ON tt_company_market_product.cmkp_last_updated_user_id = tt_user_last_updated.user_id)

--$get_company_market_products_bycompany,1
select tt_company_market_product.*, 
tt_user_last_updated.user_login AS last_updated_user_login 
FROM (tt_company_market_product LEFT JOIN (tt_user AS tt_user_last_updated)
	  ON tt_company_market_product.cmkp_last_updated_user_id = tt_user_last_updated.user_id)
WHERE cmkp_comp_id = ?

--$get_company_market_products_unrestricted

select tt_company_market_product.*, 
tt_user_last_updated.user_login AS last_updated_user_login 
FROM (tt_company_market_product LEFT JOIN (tt_user AS tt_user_last_updated)
	  ON tt_company_market_product.cmkp_last_updated_user_id = tt_user_last_updated.user_id)

-----------------------------------------------------------------------

--$get_ob_passing_groups_restricted,1
SELECT 1

--$get_ob_passing_groups_bycompany,1
SELECT tt_ob_passing_group.*, tt_user_last_updated.user_login AS last_updated_user_login
FROM tt_ob_passing_group
LEFT JOIN tt_user AS tt_user_last_updated ON tt_ob_passing_group.obpg_last_updated_user_id = tt_user_last_updated.user_id
WHERE tt_ob_passing_group.obpg_owning_comp_id = ?

--$get_ob_passing_groups_unrestricted
SELECT tt_ob_passing_group.*, tt_user_last_updated.user_login AS last_updated_user_login
FROM tt_ob_passing_group
LEFT JOIN tt_user AS tt_user_last_updated ON tt_ob_passing_group.obpg_last_updated_user_id = tt_user_last_updated.user_id
	  
-----------------------------------------------------------------------

--$get_netting_organizations_restricted,1
SELECT tt_netting_organization.*, tt_user_last_updated.user_login AS last_updated_user_login
FROM (( tt_user
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_netting_organization ON tt_user_group.ugrp_comp_id = tt_netting_organization.no_comp_id )
LEFT JOIN tt_user AS tt_user_last_updated ON tt_netting_organization.no_last_updated_user_id = tt_user_last_updated.user_id
WHERE tt_user.user_id = ?

--$get_netting_organizations_bycompany,1
SELECT tt_netting_organization.*, tt_user_last_updated.user_login AS last_updated_user_login
FROM tt_netting_organization
LEFT JOIN tt_user AS tt_user_last_updated ON tt_netting_organization.no_last_updated_user_id = tt_user_last_updated.user_id
WHERE tt_netting_organization.no_comp_id = ?

--$get_netting_organizations_unrestricted
SELECT tt_netting_organization.*, tt_user_last_updated.user_login AS last_updated_user_login
FROM tt_netting_organization
LEFT JOIN tt_user AS tt_user_last_updated ON tt_netting_organization.no_last_updated_user_id = tt_user_last_updated.user_id
	  
-----------------------------------------------------------------------

--$get_algo_types_restricted,1
SELECT tt_algos.*, tt_user_last_updated.user_login AS last_updated_user_login
FROM (( tt_user
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_algos ON tt_user_group.ugrp_comp_id = tt_algos.al_comp_id )
LEFT JOIN tt_user AS tt_user_last_updated ON tt_algos.al_last_updated_user_id = tt_user_last_updated.user_id
WHERE tt_user.user_id = ?

--$get_algo_types_bycompany,1
SELECT tt_algos.*, tt_user_last_updated.user_login AS last_updated_user_login
FROM tt_algos
LEFT JOIN tt_user AS tt_user_last_updated ON tt_algos.al_last_updated_user_id = tt_user_last_updated.user_id
WHERE tt_algos.al_comp_id = ?

--$get_algo_types_unrestricted
SELECT tt_algos.*, tt_user_last_updated.user_login AS last_updated_user_login
FROM tt_algos
LEFT JOIN tt_user AS tt_user_last_updated ON tt_algos.al_last_updated_user_id = tt_user_last_updated.user_id

-----------------------------------------------------------------------

--$get_companies_restricted,1
-- get own company and brokers
SELECT tt_company.*,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM ((((tt_company 
INNER JOIN tt_user_group ON tt_company.comp_id = tt_user_group.ugrp_comp_id) 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_user.user_id = ?
UNION
select tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM ((tt_company
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_company.comp_is_broker = 1 or tt_company.comp_id = 0

--$get_companies_bycompany,1:2
-- get own company and any buy side that lets him see users

SELECT tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM (((tt_company
INNER JOIN tt_company_company_permission ON tt_company.comp_id = tt_company_company_permission.ccp_buyside_comp_id) 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_company_company_permission.ccp_broker_comp_id = ?
UNION
select tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM ((tt_company 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_company.comp_id = ?
UNION
select tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM ((tt_company 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_company.comp_id = 0
	  
--$get_companies_unrestricted

select tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM ((tt_company 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)

-----------------------------------------------------------------------

--$get_companies_with_logos_restricted,1
SELECT tt_company.*,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_blob.blb_data AS comp_logo,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM (((((tt_company 
INNER JOIN tt_user_group ON tt_company.comp_id = tt_user_group.ugrp_comp_id) 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_blob ON tt_blob.blb_key = 'CompanyBitmap' + CStr(tt_company.comp_id))
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_user.user_id = ?
UNION ALL
select tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_blob.blb_data AS comp_logo,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM (((tt_company
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_blob ON tt_blob.blb_key = 'CompanyBitmap' + CStr(tt_company.comp_id))
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_company.comp_is_broker = 1 or tt_company.comp_id = 0

--$get_companies_with_logos_bycompany,1:2
SELECT tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_blob.blb_data AS comp_logo,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM ((((tt_company
INNER JOIN tt_company_company_permission ON tt_company.comp_id = tt_company_company_permission.ccp_buyside_comp_id) 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_blob ON tt_blob.blb_key = 'CompanyBitmap' + CStr(tt_company.comp_id))
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_company_company_permission.ccp_broker_comp_id = ?
UNION ALL
select tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_blob.blb_data AS comp_logo,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM (((tt_company 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_blob ON tt_blob.blb_key = 'CompanyBitmap' + CStr(tt_company.comp_id))
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_company.comp_id = ?
UNION ALL
select tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_blob.blb_data AS comp_logo,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM (((tt_company 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_blob ON tt_blob.blb_key = 'CompanyBitmap' + CStr(tt_company.comp_id))
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)
WHERE tt_company.comp_id = 0

--$get_companies_with_logos_unrestricted,1
select tt_company.*, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_blob.blb_data AS comp_logo,
tt_user_trading_enabled_last_updated.user_login AS trading_enabled_last_updated_user_login
FROM (((tt_company 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_company.comp_last_updated_user_id = tt_user_last_updated.user_id)
LEFT JOIN tt_blob ON tt_blob.blb_key = 'CompanyBitmap' + CStr(tt_company.comp_id))
LEFT JOIN tt_user AS tt_user_trading_enabled_last_updated ON tt_company.comp_trading_enabled_last_updated_user_id = tt_user_trading_enabled_last_updated.user_id)

-----------------------------------------------------------------------

--$get_user_groups_restricted,1

SELECT tt_user_group.*
FROM tt_user_group 
INNER JOIN tt_user_group_permission 
ON tt_user_group.ugrp_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?

--$get_user_groups_bycompany,1
--SELECT DISTINCT tt_user_group.*
--FROM tt_user_group 
--INNER JOIN tt_view_user_group_company_relationships 
--ON tt_user_group.ugrp_group_id = tt_view_user_group_company_relationships.ugrp_group_id
--where tt_view_user_group_company_relationships.ugrp_comp_id = ?
SELECT tt_user_group.*
FROM tt_user_group

--$get_user_groups_unrestricted

SELECT tt_user_group.*
FROM tt_user_group 

-----------------------------------------------------------------------

--$get_accounts_by_account_group_id
SELECT
tt_account.acct_id,
tt_account.acct_name,
tt_account.acct_description,
tt_account.acct_mgt_id,
tt_account.acct_comp_id,
tt_account.acct_include_in_auto_sods,
tt_account.acct_account_group_id,
tt_account.acct_last_updated_datetime,
tt_account.acct_created_datetime,
tt_user.user_login AS last_updated_user_login
FROM tt_account
LEFT JOIN tt_user ON tt_account.acct_last_updated_user_id = tt_user.user_id
WHERE tt_account.acct_account_group_id = ?

-----------------------------------------------------------------------

--$get_mini_users_restricted,1

SELECT 
tt_user.user_id, 
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_group_id 
FROM tt_user 
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?

--$get_mini_users_bycompany,1

SELECT 
tt_user.user_id, 
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_group_id 
FROM tt_user 
INNER JOIN tt_user_company_permission
ON tt_user.user_id = tt_user_company_permission.ucp_user_id
WHERE tt_user_company_permission.ucp_comp_id = ?

--$get_mini_users_unrestricted

SELECT 
tt_user.user_id, 
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_group_id 
FROM tt_user 

-----------------------------------------------------------------------

--$get_users_restricted,1

SELECT 
tt_user.*,
tt_user_last_updated.user_login AS last_updated_user_login 
FROM (tt_user LEFT JOIN (tt_user AS tt_user_last_updated)
	  ON tt_user.user_last_updated_user_id = tt_user_last_updated.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?

--$get_users_bycompany,1

SELECT 
tt_user.*,
tt_user_last_updated.user_login AS last_updated_user_login 
FROM (tt_user LEFT JOIN (tt_user AS tt_user_last_updated)
	  ON tt_user.user_last_updated_user_id = tt_user_last_updated.user_id)
INNER JOIN tt_user_company_permission 
ON tt_user.user_id = tt_user_company_permission.ucp_user_id
WHERE tt_user_company_permission.ucp_comp_id = ?

--$get_users_unrestricted

SELECT 
tt_user.*,
tt_user_last_updated.user_login AS last_updated_user_login 
FROM tt_user LEFT JOIN (tt_user AS tt_user_last_updated)
ON tt_user.user_last_updated_user_id = tt_user_last_updated.user_id;

-----------------------------------------------------------------------

--$get_users_for_password_admin_restricted,1

SELECT 
tt_user.user_id, 
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_most_recent_login_datetime,
tt_user.user_most_recent_login_datetime_for_inactivity,
tt_user.user_most_recent_failed_login_attempt_datetime,
tt_user.user_failed_login_attempts_count,
tt_user.user_email,
tt_user.user_phone,
tt_user.user_user_setup_user_type,
tt_user.user_status,
tt_user.user_force_logoff_switch,
tt_user.user_never_locked_by_inactivity,
tt_user_group.ugrp_name,
tt_company.comp_name
FROM ((tt_user INNER JOIN tt_user_group 
      ON tt_user.user_group_id = tt_user_group.ugrp_group_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id)
INNER JOIN tt_company ON tt_company.comp_id = tt_user_group.ugrp_comp_id
WHERE tt_user.user_status = 1 
AND tt_user_group_permission.ugp_user_id = ?

--$get_users_for_password_admin_bycompany,1

SELECT 
tt_user.user_id, 
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_most_recent_login_datetime,
tt_user.user_most_recent_login_datetime_for_inactivity,
tt_user.user_most_recent_failed_login_attempt_datetime,
tt_user.user_failed_login_attempts_count,
tt_user.user_email,
tt_user.user_phone,
tt_user.user_user_setup_user_type,
tt_user.user_status,
tt_user.user_force_logoff_switch,
tt_user.user_never_locked_by_inactivity,
tt_user_group.ugrp_name,
tt_company.comp_name
FROM( tt_user INNER JOIN tt_user_group 
ON tt_user.user_group_id = tt_user_group.ugrp_group_id)
INNER JOIN tt_company ON tt_company.comp_id = tt_user_group.ugrp_comp_id
WHERE tt_user.user_status = 1
AND tt_user_group.ugrp_comp_id = ?

--$get_users_for_password_admin_unrestricted

SELECT 
tt_user.user_id, 
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_most_recent_login_datetime,
tt_user.user_most_recent_login_datetime_for_inactivity,
tt_user.user_most_recent_failed_login_attempt_datetime,
tt_user.user_failed_login_attempts_count,
tt_user.user_email,
tt_user.user_phone,
tt_user.user_user_setup_user_type,
tt_user.user_status,
tt_user.user_force_logoff_switch,
tt_user.user_never_locked_by_inactivity,
tt_user_group.ugrp_name,
tt_company.comp_name
FROM (tt_user INNER JOIN tt_user_group 
ON tt_user.user_group_id = tt_user_group.ugrp_group_id)
INNER JOIN tt_company ON tt_company.comp_id = tt_user_group.ugrp_comp_id
WHERE tt_user.user_status = 1

-----------------------------------------------------------------------

--$get_user_names_and_their_group_names_restricted,1

SELECT tt_user.user_id,
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_status,
tt_user_group.ugrp_group_id,
tt_user_group.ugrp_name
FROM (tt_user INNER JOIN tt_user_group 
      ON tt_user.user_group_id = tt_user_group.ugrp_group_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
ORDER BY tt_user.user_login

----$get_user_names_and_their_group_names_bycompany,1

--SELECT tt_user.user_id,
--tt_user.user_login,
--tt_user.user_display_name,
--tt_user.user_status,
--tt_user_group.ugrp_group_id,
--tt_user_group.ugrp_name
--FROM (tt_user INNER JOIN tt_user_group 
--      ON tt_user.user_group_id = tt_user_group.ugrp_group_id)
--INNER JOIN tt_user_company_permission 
--ON tt_user.user_id = tt_user_company_permission.ucp_user_id
--WHERE tt_user_company_permission.ucp_comp_id = ?

--$get_user_names_and_their_group_names_unrestricted

SELECT tt_user.user_id,
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_status,
tt_user_group.ugrp_group_id,
tt_user_group.ugrp_name
FROM tt_user INNER JOIN tt_user_group 
ON tt_user.user_group_id = tt_user_group.ugrp_group_id
ORDER BY tt_user.user_login

-----------------------------------------------------------------------

--$get_user_names_and_their_ob_passing_group_names_restricted,1
SELECT 1

--$get_user_names_and_their_ob_passing_group_names_bycompany,1
SELECT
    target_user.user_id,
    target_user.user_login,
    target_user.user_display_name,
    target_user.user_status,
    obpg.obpg_id,
    obpg.obpg_group_name,
    obpg.obpg_owning_comp_id
FROM ( tt_ob_passing_group AS [obpg]
INNER JOIN tt_user_company_permission AS [ucp] ON obpg.obpg_id = ucp.ucp_ob_passing_group_id )
INNER JOIN tt_user AS [target_user] ON ucp.ucp_user_id = target_user.user_id
WHERE obpg.obpg_owning_comp_id = ?
ORDER BY target_user.user_login, obpg.obpg_group_name

--$get_user_names_and_their_ob_passing_group_names_unrestricted
SELECT
    target_user.user_id,
    target_user.user_login,
    target_user.user_display_name,
    target_user.user_status,
    obpg.obpg_id,
    obpg.obpg_group_name,
    obpg.obpg_owning_comp_id
FROM ( tt_ob_passing_group AS [obpg]
INNER JOIN tt_user_company_permission AS [ucp] ON obpg.obpg_id = ucp.ucp_ob_passing_group_id )
INNER JOIN tt_user AS [target_user] ON ucp.ucp_user_id = target_user.user_id
ORDER BY target_user.user_login, obpg.obpg_group_name


-----------------------------------------------------------------------

--$get_netting_organization_ids_and_their_related_user_ids_restricted,1
SELECT
    target_user.user_login,
    [no].no_id
FROM ((( tt_netting_organization AS [no]
INNER JOIN tt_user AS [target_user] ON [no].no_id = target_user.user_netting_organization_id )
INNER JOIN tt_user_group ON [no].no_comp_id = tt_user_group.ugrp_comp_id )
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id )
WHERE tt_user.user_id = ?
ORDER BY [no].no_id, target_user.user_login


--$get_netting_organization_ids_and_their_related_user_ids_bycompany,1
SELECT
    target_user.user_login,
    [no].no_id
FROM tt_netting_organization AS [no]
INNER JOIN tt_user AS [target_user] ON [no].no_id = target_user.user_netting_organization_id
WHERE [no].no_comp_id = ?
ORDER BY [no].no_id, target_user.user_login

--$get_netting_organization_ids_and_their_related_user_ids_unrestricted
SELECT
    target_user.user_login,
    [no].no_id
FROM tt_netting_organization AS [no]
INNER JOIN tt_user AS [target_user] ON [no].no_id = target_user.user_netting_organization_id
ORDER BY [no].no_id, target_user.user_login

-----------------------------------------------------------------------

--$get_company_id_for_user_unrestricted
SELECT tt_user_group.ugrp_comp_id
FROM tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id
WHERE tt_user.user_id = ?

--$get_user_by_id_restricted,2

SELECT 
tt_user.*,
tt_user_last_updated.user_login AS last_updated_user_login 
FROM (tt_user LEFT JOIN (tt_user AS tt_user_last_updated)
	  ON tt_user.user_last_updated_user_id = tt_user_last_updated.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user.user_id = ? 
AND tt_user_group_permission.ugp_user_id = ?

--$get_user_by_id_bycompany,2
SELECT 
tt_user.*,
tt_user_last_updated.user_login AS last_updated_user_login 
FROM (tt_user LEFT JOIN (tt_user AS tt_user_last_updated)
      ON tt_user.user_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user_company_permission
ON tt_user.user_id = tt_user_company_permission.ucp_user_id
WHERE tt_user.user_id = ? 
AND tt_user_company_permission.ucp_comp_id = ?

--$get_user_by_id_unrestricted
SELECT 
tt_user.*,
tt_user_last_updated.user_login AS last_updated_user_login 
FROM tt_user LEFT JOIN (tt_user AS tt_user_last_updated)
ON tt_user.user_last_updated_user_id = tt_user_last_updated.user_id 
WHERE tt_user.user_id = ?

-----------------------------------------------------------------------

--$get_mgt_to_users_mapping_restricted,1

SELECT DISTINCT tt_user.user_login, tt_mgt.mgt_id, tt_user_group.ugrp_name
FROM (((( tt_mgt
INNER JOIN tt_gmgt ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader )
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_user_group_permission ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
ORDER BY tt_mgt.mgt_id, tt_user.user_login

--$get_mgt_to_users_mapping_bycompany,1

SELECT DISTINCT tt_user.user_login, tt_mgt.mgt_id, tt_user_group.ugrp_name
FROM ((( tt_mgt
INNER JOIN tt_gmgt ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader )
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id
WHERE tt_mgt.mgt_comp_id = ? 
ORDER BY tt_mgt.mgt_id, tt_user.user_login

--$get_mgt_to_users_mapping_unrestricted

SELECT DISTINCT tt_user.user_login, tt_mgt.mgt_id, tt_user_group.ugrp_name
FROM ((( tt_mgt
INNER JOIN tt_gmgt ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader )
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id
ORDER BY tt_mgt.mgt_id, tt_user.user_login

-----------------------------------------------------------------------

--$get_mgt_to_users_mapping_by_mgt_id_restricted,1

SELECT DISTINCT tt_user.user_login, tt_mgt.mgt_id, tt_user_group.ugrp_name
FROM ((((tt_mgt
INNER JOIN tt_gmgt ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader )
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id) 
INNER JOIN tt_user_group_permission ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?
AND tt_mgt.mgt_id = ?
ORDER BY tt_user.user_login

----$get_mgt_to_users_mapping_by_mgt_id_bycompany,1

--SELECT DISTINCT tt_user.user_login, tt_mgt.mgt_id
--FROM (((tt_mgt INNER JOIN tt_gmgt 
--        ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader
--       )INNER JOIN tt_user_gmgt 
--       ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
--      )INNER JOIN tt_user 
--      ON tt_user_gmgt.uxg_user_id = tt_user.user_id) 
--INNER JOIN tt_user_company_permission
--ON tt_user.user_id = tt_user_company_permission.ucp_user_id
--WHERE tt_user_company_permission.ucp_comp_id = ?
--AND tt_mgt.mgt_id = ?
--ORDER BY tt_user.user_login

--$get_mgt_to_users_mapping_by_mgt_id_unrestricted

SELECT DISTINCT tt_user.user_login, tt_mgt.mgt_id, tt_user_group.ugrp_name
FROM (((tt_mgt
INNER JOIN tt_gmgt ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader )
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id
ORDER BY tt_user.user_login

-----------------------------------------------------------------------

--$get_gmgt_to_users_mapping_restricted,1

SELECT tt_user.user_login, tt_user_gmgt.uxg_gmgt_id
FROM (tt_user INNER JOIN tt_user_gmgt 
      ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?
ORDER BY tt_user_gmgt.uxg_gmgt_id, tt_user.user_login

----$get_gmgt_to_users_mapping_bycompany,1

--SELECT tt_user.user_login, tt_user_gmgt.uxg_gmgt_id
--FROM (tt_user INNER JOIN tt_user_gmgt 
--      ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
--INNER JOIN tt_user_company_permission
--ON tt_user.user_id = tt_user_company_permission.ucp_user_id
--WHERE tt_user_company_permission.ucp_comp_id = ? 
--ORDER BY tt_user_gmgt.uxg_gmgt_id, tt_user.user_login

--$get_gmgt_to_users_mapping_unrestricted

SELECT tt_user.user_login, tt_user_gmgt.uxg_gmgt_id
FROM tt_user INNER JOIN tt_user_gmgt 
     ON tt_user.user_id = tt_user_gmgt.uxg_user_id
ORDER BY tt_user_gmgt.uxg_gmgt_id, tt_user.user_login;

-----------------------------------------------------------------------

--$get_gmgt_to_users_mapping_by_gmgt_id_restricted,1

SELECT tt_user.user_login, tt_user_gmgt.uxg_gmgt_id
FROM (tt_user INNER JOIN tt_user_gmgt 
      ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
AND tt_user_gmgt.uxg_gmgt_id = ?
ORDER BY tt_user.user_login

----$get_gmgt_to_users_mapping_by_gmgt_id_bycompany,1

--SELECT tt_user.user_login, tt_user_gmgt.uxg_gmgt_id
--FROM (tt_user INNER JOIN tt_user_gmgt 
--      ON tt_user.user_id = tt_user_gmgt.uxg_user_id)
--INNER JOIN tt_user_company_permission
--ON tt_user.user_id = tt_user_company_permission.ucp_user_id
--WHERE tt_user_company_permission.ucp_comp_id = ?
--AND tt_user_gmgt.uxg_gmgt_id = ?
--ORDER BY tt_user.user_login

--$get_gmgt_to_users_mapping_by_gmgt_id_unrestricted

SELECT tt_user.user_login, tt_user_gmgt.uxg_gmgt_id
FROM tt_user INNER JOIN tt_user_gmgt 
     ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE tt_user_gmgt.uxg_gmgt_id = ?
ORDER BY tt_user.user_login

-----------------------------------------------------------------------

--$get_customer_defaults_all_inc_algo_restricted,1

SELECT 
tt_customer_default.*,
tt_user.user_login, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM ((((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_user_group_permission.ugp_user_id = ?

--$get_customer_defaults_all_inc_algo_bycompany,1

SELECT
tt_customer_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM (((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_customer_default.cusd_comp_id = ?

--$get_customer_defaults_all_inc_algo_unrestricted

SELECT
tt_customer_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM (((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id

-----------------------------------------------------------------------

--$get_customer_defaults_all_restricted,1

SELECT 
tt_customer_default.*,
tt_user.user_login, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM ((((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_user_group_permission.ugp_user_id = ? and tt_customer_default.cusd_al_algo_id <=0

--$get_customer_defaults_all_bycompany,1

SELECT
tt_customer_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM (((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_customer_default.cusd_comp_id = ? and tt_customer_default.cusd_al_algo_id <=0

--$get_customer_defaults_all_unrestricted

SELECT
tt_customer_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM (((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_customer_default.cusd_al_algo_id <=0
	 	 
-----------------------------------------------------------------------

--$get_customer_defaults_by_user_id_inc_algo_restricted,1

SELECT 
tt_customer_default.*,
tt_user.user_login, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM ((((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_user_group_permission.ugp_user_id = ?
AND tt_customer_default.cusd_user_id = ?

--$get_customer_defaults_by_user_id_inc_algo_bycompany,2

SELECT
tt_customer_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM (((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_customer_default.cusd_user_id = ?
AND tt_customer_default.cusd_comp_id = ?

--$get_customer_defaults_by_user_id_inc_algo_unrestricted

SELECT
tt_customer_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM (((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_customer_default.cusd_user_id = ?

-----------------------------------------------------------------------

--$get_customer_defaults_by_user_id_restricted,1

SELECT 
tt_customer_default.*,
tt_user.user_login, 
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM ((((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_user_group_permission.ugp_user_id = ?
AND tt_customer_default.cusd_user_id = ? AND tt_customer_default.cusd_al_algo_id <=0

--$get_customer_defaults_by_user_id_bycompany,2

SELECT
tt_customer_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM (((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_customer_default.cusd_user_id = ?
AND tt_customer_default.cusd_comp_id = ? AND tt_customer_default.cusd_al_algo_id <=0

--$get_customer_defaults_by_user_id_unrestricted

SELECT
tt_customer_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login,
tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader,
tt_user_obo.user_login AS obo_user,
tt_account.acct_name AS obo_account,
IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as default_member,
default_gmgt.gm_group as default_group,
default_gmgt.gm_trader as default_trader
FROM (((((tt_customer_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_customer_default.cusd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id) 
INNER JOIN tt_mgt 
ON tt_customer_default.cusd_on_behalf_of_mgt_id = tt_mgt.mgt_id)
LEFT JOIN tt_user AS tt_user_obo
ON tt_customer_default.cusd_on_behalf_of_user_id = tt_user_obo.user_id)
LEFT JOIN tt_account
ON tt_customer_default.cusd_on_behalf_of_account_id = tt_account.acct_id)
LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id
WHERE tt_customer_default.cusd_user_id = ? AND tt_customer_default.cusd_al_algo_id <=0

-----------------------------------------------------------------------

--$get_account_defaults_all_restricted,1

SELECT 
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_account_default LEFT JOIN tt_user AS tt_user_last_updated 
       ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id
      )INNER JOIN tt_user
      ON tt_account_default.acctd_user_id = tt_user.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ? AND tt_account_default.acctd_al_algo_id <=0

--$get_account_defaults_all_bycompany,1

SELECT
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_account_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_account_default.acctd_user_id = tt_user.user_id) 
WHERE tt_account_default.acctd_comp_id = ? AND tt_account_default.acctd_al_algo_id <=0

--$get_account_defaults_all_unrestricted

SELECT
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_account_default LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_account_default.acctd_user_id = tt_user.user_id
WHERE tt_account_default.acctd_al_algo_id <=0


-----------------------------------------------------------------------

--$get_account_defaults_by_user_id_restricted,1

SELECT 
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_account_default LEFT JOIN tt_user AS tt_user_last_updated 
       ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id
      )INNER JOIN tt_user
      ON tt_account_default.acctd_user_id = tt_user.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
AND tt_account_default.acctd_user_id = ? AND tt_account_default.acctd_al_algo_id <=0
ORDER BY acctd_comp_id, acctd_sequence_number

--$get_account_defaults_by_user_id_bycompany,1

SELECT
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_account_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_account_default.acctd_user_id = tt_user.user_id) 
WHERE tt_account_default.acctd_comp_id = ?
AND tt_account_default.acctd_user_id = ? AND tt_account_default.acctd_al_algo_id <=0
ORDER BY acctd_comp_id, acctd_sequence_number

--$get_account_defaults_by_user_id_unrestricted

SELECT
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_account_default LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_account_default.acctd_user_id = tt_user.user_id
WHERE tt_account_default.acctd_user_id = ? AND tt_account_default.acctd_al_algo_id <=0
ORDER BY acctd_comp_id, acctd_sequence_number

-----------------------------------------------------------------------

--$get_account_defaults_all_inc_algo_restricted,1

SELECT 
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_account_default LEFT JOIN tt_user AS tt_user_last_updated 
       ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id
      )INNER JOIN tt_user
      ON tt_account_default.acctd_user_id = tt_user.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?

--$get_account_defaults_all_inc_algo_bycompany,1

SELECT
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_account_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_account_default.acctd_user_id = tt_user.user_id) 
WHERE tt_account_default.acctd_comp_id = ?

--$get_account_defaults_all_inc_algo_unrestricted

SELECT
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_account_default LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_account_default.acctd_user_id = tt_user.user_id


-----------------------------------------------------------------------

--$get_account_defaults_by_user_id_inc_algo_restricted,1

SELECT 
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_account_default LEFT JOIN tt_user AS tt_user_last_updated 
       ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id
      )INNER JOIN tt_user
      ON tt_account_default.acctd_user_id = tt_user.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
AND tt_account_default.acctd_user_id = ?
ORDER BY acctd_comp_id, acctd_sequence_number

--$get_account_defaults_by_user_id_inc_algo_bycompany,1

SELECT
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_account_default 
LEFT JOIN tt_user AS tt_user_last_updated 
ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id) 
INNER JOIN tt_user 
ON tt_account_default.acctd_user_id = tt_user.user_id) 
WHERE tt_account_default.acctd_comp_id = ?
AND tt_account_default.acctd_user_id = ?
ORDER BY acctd_comp_id, acctd_sequence_number

--$get_account_defaults_by_user_id_inc_algo_unrestricted

SELECT
tt_account_default.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_account_default LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_account_default.acctd_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_account_default.acctd_user_id = tt_user.user_id
WHERE tt_account_default.acctd_user_id = ?
ORDER BY acctd_comp_id, acctd_sequence_number

-----------------------------------------------------------------------

--$get_mgt_sod_bc_by_gateway_id
SELECT distinct
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader,
tt_mgt.mgt_enable_sods,
tt_gmgt.gm_gateway_id
FROM ((tt_mgt 
  INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id)
  INNER JOIN tt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id)
  WHERE tt_gmgt.gm_gateway_id = ?

-- tt_user_logged_in position intentionally omitted
-- used by server too.
--$get_login_server_settings

SELECT *,
IIF( 1 = lss_2fa_state, CByte( 1 ), CByte( 0 ) ) as [lss_2fa_on]
FROM tt_login_server_settings

-- tt_user_logged_in position intentionally omitted
--$get_account_by_name_in_hex

SELECT * 
FROM tt_account
WHERE acct_name_in_hex = ?;


--$get_account_group_by_name_in_hex
SELECT * 
FROM tt_account_group
WHERE ag_name_in_hex = ?;

--$get_user_smtp_settings
select 
user_smtp_enable_settings,
user_smtp_host,
user_smtp_port,                  
user_smtp_requires_authentication,
user_smtp_login_user,
user_smtp_login_password,
user_smtp_use_ssl,
user_smtp_from_address,
user_smtp_subject,
user_smtp_body,
user_smtp_include_username_in_message
from tt_user
where user_id = ?

-----------------------------------------------------------------------

--$get_mgts_for_broker_api_only
SELECT 
tt_mgt.mgt_id,
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader,
tt_mgt.mgt_description,
tt_mgt.mgt_credit,
tt_mgt.mgt_use_simulation_credit,
tt_mgt.mgt_simulation_credit,
tt_mgt.mgt_currency,
tt_mgt.mgt_allow_trading,
tt_mgt.mgt_ignore_pl,
tt_mgt.mgt_risk_on,
tt_mgt.mgt_publish_to_guardian,
tt_mgt.mgt_can_associate_with_user_directly,
tt_mgt.mgt_comp_id,
tt_mgt.mgt_enable_sods,
IIf(tt_mgt.mgt_password= '',CByte(0),CByte(1)) AS has_password,
tt_mgt.mgt_last_updated_datetime,
tt_mgt.mgt_created_datetime,
tt_user_last_updated.user_login as last_updated_user_login
FROM tt_mgt LEFT JOIN tt_user AS tt_user_last_updated
ON tt_mgt.mgt_last_updated_user_id = tt_user_last_updated.user_id
WHERE tt_mgt.mgt_comp_id in ( ?, 0 )

--$get_mgts_admin_mgts_only
SELECT 
tt_mgt.mgt_id,
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader,
tt_mgt.mgt_description,
tt_mgt.mgt_credit,
tt_mgt.mgt_use_simulation_credit,
tt_mgt.mgt_simulation_credit,
tt_mgt.mgt_currency,
tt_mgt.mgt_allow_trading,
tt_mgt.mgt_ignore_pl,
tt_mgt.mgt_risk_on,
tt_mgt.mgt_publish_to_guardian,
tt_mgt.mgt_can_associate_with_user_directly,
tt_mgt.mgt_comp_id,
tt_mgt.mgt_enable_sods,
IIf(tt_mgt.mgt_password= '',CByte(0),CByte(1)) AS has_password,
tt_mgt.mgt_last_updated_datetime,
tt_mgt.mgt_created_datetime,
tt_user_last_updated.user_login as last_updated_user_login
FROM tt_mgt LEFT JOIN tt_user AS tt_user_last_updated
ON tt_mgt.mgt_last_updated_user_id = tt_user_last_updated.user_id
WHERE tt_mgt.mgt_member = "TTADM"
AND tt_mgt.mgt_group = "XXX"
AND (tt_mgt.mgt_trader = "MGR" OR tt_mgt.mgt_trader = "VIEW")

-----------------------------------------------------------------------

--$get_mgt_gmgts_for_broker_api_only
SELECT 
tt_mgt.*,
mxg_id, 
mxg_mgt_id, 
mxg_gmgt_id 
FROM tt_mgt_gmgt
INNER JOIN tt_mgt on tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
where tt_mgt.mgt_comp_id in ( ?, 0 )

--$get_mgt_gmgts_admin_gmgts_only
SELECT 
mxg_id, 
mxg_mgt_id, 
mxg_gmgt_id 
FROM tt_mgt_gmgt
INNER JOIN tt_mgt on tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
WHERE tt_mgt.mgt_member = "TTADM"
AND tt_mgt.mgt_group = "XXX"
AND (tt_mgt.mgt_trader = "MGR" OR tt_mgt.mgt_trader = "VIEW")

-----------------------------------------------------------------------

--$get_gmgts_for_broker_api_only
SELECT
tt_gmgt.gm_id,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
tt_gmgt.gm_gateway_id,
tt_gmgt.gm_last_updated_datetime,
tt_gmgt.gm_created_datetime,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ( tt_gmgt 
  LEFT JOIN tt_user AS tt_user_last_updated ON tt_gmgt.gm_last_updated_user_id = tt_user_last_updated.user_id) 
  INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)
WHERE tt_mgt.mgt_comp_id in ( ?, 0 )

--$get_gmgts_admin_gmgts_only
SELECT
tt_gmgt.gm_id,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
tt_gmgt.gm_gateway_id,
tt_gmgt.gm_last_updated_datetime,
tt_gmgt.gm_created_datetime,
tt_user_last_updated.user_login AS last_updated_user_login
FROM tt_gmgt LEFT JOIN tt_user AS tt_user_last_updated
ON tt_gmgt.gm_last_updated_user_id = tt_user_last_updated.user_id
WHERE tt_gmgt.gm_member = "TTADM"
AND tt_gmgt.gm_group = "XXX"
AND (tt_gmgt.gm_trader = "MGR" OR tt_gmgt.gm_trader = "VIEW")

-----------------------------------------------------------------------

--$get_user_gmgts_for_broker_api_only
select DISTINCT *
FROM
(
  SELECT 
    tt_user_gmgt.uxg_user_gmgt_id, 
    tt_user_gmgt.uxg_user_id,
    tt_user_gmgt.uxg_gmgt_id,
    tt_user_gmgt.uxg_automatically_login, 
    tt_user_gmgt.uxg_preferred_ip, 
    tt_user_gmgt.uxg_clearing_member, 
    tt_user_gmgt.uxg_default_account, 
    tt_user_gmgt.uxg_available_to_user, 
    tt_user_gmgt.uxg_available_to_fix_adapter_user,
    tt_user_gmgt.uxg_mandatory_login,
    tt_user_gmgt.uxg_last_updated_datetime, 
    tt_user_gmgt.uxg_created_datetime,
    tt_user_gmgt.uxg_operator_id,
    tt_user_gmgt.uxg_max_orders_per_second,
    tt_user_gmgt.uxg_max_orders_per_second_on,
    tt_user_gmgt.uxg_exchange_data1,
    tt_user_gmgt.uxg_exchange_data2,
    tt_user_gmgt.uxg_exchange_data3,
    tt_user_gmgt.uxg_exchange_data4,
    tt_user_gmgt.uxg_exchange_data5,
    tt_user_gmgt.uxg_exchange_data6,
    tt_user_gmgt.uxg_market_orders,
    tt_gmgt.gm_gateway_id, 
    tt_user_last_updated.user_login AS last_updated_user_login
  FROM ((((( tt_user_gmgt
    INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
    INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader )
    INNER JOIN tt_user AS target_user ON tt_user_gmgt.uxg_user_id = target_user.user_id )
    INNER JOIN tt_user_group ON target_user.user_group_id = tt_user_group.ugrp_group_id )
    LEFT JOIN tt_user_company_permission ON target_user.user_id = tt_user_company_permission.ucp_user_id )
    LEFT JOIN tt_user AS tt_user_last_updated ON tt_user_gmgt.uxg_last_updated_user_id = tt_user_last_updated.user_id
  WHERE ( tt_mgt.mgt_member = "TTADM" AND tt_mgt.mgt_group = "XXX" AND (tt_mgt.mgt_trader = "MGR" OR tt_mgt.mgt_trader = "VIEW") )
      AND ( tt_user_group.ugrp_comp_id = ? OR ( tt_user_company_permission.ucp_comp_id = ? ) )
UNION
 
  SELECT
    tt_user_gmgt.uxg_user_gmgt_id, 
    tt_user_gmgt.uxg_user_id,
    tt_user_gmgt.uxg_gmgt_id,
    tt_user_gmgt.uxg_automatically_login, 
    tt_user_gmgt.uxg_preferred_ip, 
    tt_user_gmgt.uxg_clearing_member, 
    tt_user_gmgt.uxg_default_account, 
    tt_user_gmgt.uxg_available_to_user, 
    tt_user_gmgt.uxg_available_to_fix_adapter_user,
    tt_user_gmgt.uxg_mandatory_login,
    tt_user_gmgt.uxg_last_updated_datetime, 
    tt_user_gmgt.uxg_created_datetime,
    tt_user_gmgt.uxg_operator_id,
    tt_user_gmgt.uxg_max_orders_per_second,
    tt_user_gmgt.uxg_max_orders_per_second_on,
    tt_user_gmgt.uxg_exchange_data1,
    tt_user_gmgt.uxg_exchange_data2,
    tt_user_gmgt.uxg_exchange_data3,
    tt_user_gmgt.uxg_exchange_data4,
    tt_user_gmgt.uxg_exchange_data5,
    tt_user_gmgt.uxg_exchange_data6,
    tt_user_gmgt.uxg_market_orders,
    tt_gmgt.gm_gateway_id, 
    tt_user_last_updated.user_login AS last_updated_user_login
  FROM (( tt_user_gmgt
    LEFT JOIN tt_user AS tt_user_last_updated ON tt_user_gmgt.uxg_last_updated_user_id = tt_user_last_updated.user_id )
    INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
    INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader
  WHERE tt_mgt.mgt_comp_id = ?
)

-----------------------------------------------------------------------

--$get_user_gmgts_by_MGT_restricted,1
SELECT DISTINCT 
tt_user_gmgt.uxg_user_gmgt_id, 
tt_user_gmgt.uxg_user_id,
tt_user_gmgt.uxg_gmgt_id,
tt_user_gmgt.uxg_automatically_login, 
tt_user_gmgt.uxg_preferred_ip, 
tt_user_gmgt.uxg_clearing_member, 
tt_user_gmgt.uxg_default_account, 
tt_user_gmgt.uxg_available_to_user,
tt_user_gmgt.uxg_available_to_fix_adapter_user,
tt_user_gmgt.uxg_mandatory_login,
tt_user_gmgt.uxg_last_updated_datetime,
tt_user_gmgt.uxg_created_datetime,
tt_user_gmgt.uxg_operator_id,
tt_user_gmgt.uxg_max_orders_per_second,
tt_user_gmgt.uxg_max_orders_per_second_on,
tt_user_gmgt.uxg_exchange_data1,
tt_user_gmgt.uxg_exchange_data2,
tt_user_gmgt.uxg_exchange_data3,
tt_user_gmgt.uxg_exchange_data4,
tt_user_gmgt.uxg_exchange_data5,
tt_user_gmgt.uxg_exchange_data6,
tt_user_gmgt.uxg_market_orders,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (((tt_gmgt INNER JOIN tt_user_gmgt 
        ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
	   )LEFT JOIN tt_user AS tt_user_last_updated
       ON tt_user_gmgt.uxg_last_updated_user_id = tt_user_last_updated.user_id
)INNER JOIN tt_user 
ON tt_user_gmgt.uxg_user_id = tt_user.user_id
)INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?
AND tt_gmgt.gm_member = ? 
AND tt_gmgt.gm_group = ?
AND tt_gmgt.gm_trader = ?


--$get_user_gmgts_by_MGT_bycompany,1
SELECT DISTINCT 
tt_user_gmgt.uxg_user_gmgt_id, 
tt_user_gmgt.uxg_user_id,
tt_user_gmgt.uxg_gmgt_id,
tt_user_gmgt.uxg_automatically_login, 
tt_user_gmgt.uxg_preferred_ip, 
tt_user_gmgt.uxg_clearing_member, 
tt_user_gmgt.uxg_default_account, 
tt_user_gmgt.uxg_available_to_user, 
tt_user_gmgt.uxg_available_to_fix_adapter_user,
tt_user_gmgt.uxg_mandatory_login,
tt_user_gmgt.uxg_last_updated_datetime, 
tt_user_gmgt.uxg_created_datetime,
tt_user_gmgt.uxg_operator_id,
tt_user_gmgt.uxg_max_orders_per_second,
tt_user_gmgt.uxg_max_orders_per_second_on,
tt_user_gmgt.uxg_exchange_data1,
tt_user_gmgt.uxg_exchange_data2,
tt_user_gmgt.uxg_exchange_data3,
tt_user_gmgt.uxg_exchange_data4,
tt_user_gmgt.uxg_exchange_data5,
tt_user_gmgt.uxg_exchange_data6,
tt_user_gmgt.uxg_market_orders,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_gmgt INNER JOIN tt_user_gmgt 
       ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
	  )LEFT JOIN tt_user AS tt_user_last_updated
      ON tt_user_gmgt.uxg_last_updated_user_id = tt_user_last_updated.user_id
)INNER JOIN tt_mgt 
ON tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader
WHERE tt_mgt.mgt_comp_id = ?
AND tt_gmgt.gm_member = ? 
AND tt_gmgt.gm_group = ?
AND tt_gmgt.gm_trader = ?


--$get_user_gmgts_by_MGT_unrestricted
SELECT DISTINCT 
tt_user_gmgt.uxg_user_gmgt_id, 
tt_user_gmgt.uxg_user_id,
tt_user_gmgt.uxg_gmgt_id,
tt_user_gmgt.uxg_automatically_login, 
tt_user_gmgt.uxg_preferred_ip, 
tt_user_gmgt.uxg_clearing_member, 
tt_user_gmgt.uxg_default_account, 
tt_user_gmgt.uxg_available_to_user,
tt_user_gmgt.uxg_available_to_fix_adapter_user,
tt_user_gmgt.uxg_mandatory_login,
tt_user_gmgt.uxg_last_updated_datetime, 
tt_user_gmgt.uxg_created_datetime,
tt_user_gmgt.uxg_operator_id,
tt_user_gmgt.uxg_max_orders_per_second,
tt_user_gmgt.uxg_max_orders_per_second_on,
tt_user_gmgt.uxg_exchange_data1,
tt_user_gmgt.uxg_exchange_data2,
tt_user_gmgt.uxg_exchange_data3,
tt_user_gmgt.uxg_exchange_data4,
tt_user_gmgt.uxg_exchange_data5,
tt_user_gmgt.uxg_exchange_data6,
tt_user_gmgt.uxg_market_orders,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_gmgt INNER JOIN tt_user_gmgt 
      ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
     )LEFT JOIN tt_user AS tt_user_last_updated
     ON tt_user_gmgt.uxg_last_updated_user_id = tt_user_last_updated.user_id
WHERE tt_gmgt.gm_member = ? 
AND tt_gmgt.gm_group = ?
AND tt_gmgt.gm_trader = ?

------------------------------------------------------------------------------------------

--$get_mgt_sod_bc_by_gateway_id
SELECT distinct
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader,
tt_mgt.mgt_enable_sods,
tt_gmgt.gm_gateway_id
FROM ((tt_mgt 
  INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id)
  INNER JOIN tt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id)
  WHERE tt_gmgt.gm_gateway_id = ?

------------------------------------------------------------------------------------------
-- Gets
------------------------------------------------------------------------------------------

--$get_user_group_permissions_restricted,1
SELECT DISTINCT
data_table.*
FROM tt_user_group_permission AS data_table
INNER JOIN tt_user_group_permission AS permission_table
ON data_table.ugp_group_id = permission_table.ugp_group_id
WHERE permission_table.ugp_user_id = ?

--$get_user_group_permissions_unrestricted
SELECT tt_user_group_permission.*
FROM tt_user_group_permission

------------------------------------------------------------------------------------------

--$get_user_group_sod_permissions_restricted,1
SELECT DISTINCT
data_table.*
FROM tt_user_group_sod_permission AS data_table
INNER JOIN tt_user_group_sod_permission AS permission_table
ON data_table.ugps_group_id = permission_table.ugps_group_id
WHERE permission_table.ugps_user_id = ?

--$get_user_group_sod_permissions_unrestricted
SELECT tt_user_group_sod_permission.*
FROM tt_user_group_sod_permission

------------------------------------------------------------------------------------------

--$get_user_group_permissions_by_user_id_restricted,2
SELECT DISTINCT
data_table.*
FROM tt_user_group_permission AS data_table
INNER JOIN tt_user_group_permission AS permission_table
ON data_table.ugp_group_id = permission_table.ugp_group_id
WHERE data_table.ugp_user_id = ? 
AND permission_table.ugp_user_id = ?

--$get_user_group_permissions_by_user_id_bycompany,2
SELECT DISTINCT
data_table.*
FROM ( tt_user_group_permission AS data_table
INNER JOIN tt_user_group_permission AS permission_table ON data_table.ugp_group_id = permission_table.ugp_group_id )
INNER JOIN tt_user_group on data_table.ugp_group_id = tt_user_group.ugrp_group_id
WHERE data_table.ugp_user_id = ?
AND tt_user_group.ugrp_comp_id = ?

--$get_user_group_permissions_by_user_id_unrestricted
SELECT tt_user_group_permission.*
FROM tt_user_group_permission
WHERE tt_user_group_permission.ugp_user_id = ? 

------------------------------------------------------------------------------------------

--$get_user_group_sod_permissions_by_user_id_restricted,2
SELECT DISTINCT
data_table.*
FROM tt_user_group_sod_permission AS data_table
INNER JOIN tt_user_group_permission AS permission_table
ON data_table.ugps_group_id = permission_table.ugp_group_id
WHERE data_table.ugps_user_id = ? 
AND permission_table.ugp_user_id = ?

--$get_user_group_sod_permissions_by_user_id_bycompany,2
SELECT DISTINCT
data_table.*
FROM ( tt_user_group_sod_permission AS data_table
INNER JOIN tt_user_group_sod_permission AS permission_table ON data_table.ugps_group_id = permission_table.ugps_group_id )
INNER JOIN tt_user_group on data_table.ugps_group_id = tt_user_group.ugrp_group_id
WHERE data_table.ugps_user_id = ?
AND tt_user_group.ugrp_comp_id = ?

--$get_user_group_sod_permissions_by_user_id_unrestricted
SELECT tt_user_group_sod_permission.*
FROM tt_user_group_sod_permission
WHERE tt_user_group_sod_permission.ugps_user_id = ? 

------------------------------------------------------------------------------------------

--$get_user_companies_restricted,1
SELECT DISTINCT tt_user_company_permission.*
FROM tt_user_group_permission 
INNER JOIN (tt_user INNER JOIN tt_user_company_permission 
ON tt_user.user_id = tt_user_company_permission.ucp_user_id) 
ON tt_user_group_permission.ugp_group_id = tt_user.user_group_id
where tt_user_group_permission.ugp_user_id = ?

--$get_user_companies_bycompany,1
SELECT tt_user_company_permission.*
FROM tt_user_company_permission
where ucp_comp_id = ?

--$get_user_companies_unrestricted
SELECT tt_user_company_permission.*
FROM tt_user_company_permission

------------------------------------------------------------------------------------------

--$get_user_accounts_restricted,1
SELECT DISTINCT tt_user_account.*
FROM tt_user_group_permission 
INNER JOIN (tt_user INNER JOIN tt_user_account
ON tt_user.user_id = tt_user_account.uxa_user_id) 
ON tt_user_group_permission.ugp_group_id = tt_user.user_group_id
where tt_user_group_permission.ugp_user_id = ?

--$get_user_accounts_bycompany,1
SELECT tt_user_account.*
FROM tt_user_account
INNER JOIN tt_account ON tt_user_account.uxa_account_id = tt_account.acct_id
where tt_account.acct_comp_id = ?

--$get_user_accounts_unrestricted
SELECT tt_user_account.*
FROM tt_user_account

------------------------------------------------------------------------------------------

--$get_user_companies_by_user_id_restricted
SELECT tt_user_company_permission.*
FROM tt_user_company_permission
WHERE tt_user_company_permission.ucp_user_id = ? 

--$get_user_companies_by_user_id_bycompany,1
SELECT tt_user_company_permission.*
FROM tt_user_company_permission
WHERE tt_user_company_permission.ucp_comp_id = ?
AND tt_user_company_permission.ucp_user_id = ? 

--$get_user_companies_by_user_id_unrestricted
SELECT tt_user_company_permission.*
FROM tt_user_company_permission
WHERE tt_user_company_permission.ucp_user_id = ? 

------------------------------------------------------------------------------------------

--$get_user_accounts_by_user_id_restricted
SELECT tt_user_account.*
FROM tt_user_account
WHERE tt_user_account.uxa_user_id = ? 

--$get_user_accounts_by_user_id_bycompany,1
SELECT tt_user_account.*
FROM tt_user_account
INNER JOIN tt_account ON tt_user_account.uxa_account_id = tt_account.acct_id
WHERE tt_account.acct_comp_id = ?
AND tt_user_account.uxa_user_id = ?

--$get_user_accounts_by_user_id_unrestricted
SELECT tt_user_account.*
FROM tt_user_account
WHERE tt_user_account.uxa_user_id = ? 

------------------------------------------------------------------------------------------

--$get_manual_mgp_by_mgt_id_restricted,2
SELECT DISTINCT
mgp_id, 
mgp_mgt_id, 
mgp_group_id
FROM tt_mgt_group_permission as mgp
INNER JOIN tt_user_group_permission as ugp
ON mgp.mgp_group_id = ugp.ugp_group_id
WHERE mgp_mgt_id = ? 
AND ugp_user_id = ? 

--$get_manual_mgp_by_mgt_id_bycompany,2
SELECT DISTINCT
mgp_id, 
mgp_mgt_id, 
mgp_group_id
FROM tt_mgt_group_permission as mgp
WHERE mgp.mgp_mgt_id = ? 
AND tt_mgt.mgt_comp_id = ? 

--$get_manual_mgp_by_mgt_id_unrestricted
SELECT DISTINCT
mgp_id, 
mgp_mgt_id, 
mgp_group_id
FROM tt_mgt_group_permission
WHERE mgp_mgt_id = ? 

------------------------------------------------------------------------------------------

--$get_manual_mgp_by_group_id_restricted,2
SELECT DISTINCT
mgp_id, 
mgp_mgt_id, 
mgp_group_id
FROM tt_mgt_group_permission as mgp
INNER JOIN tt_user_group_permission as ugp
ON mgp.mgp_group_id = ugp.ugp_group_id
WHERE mgp_group_id = ? 
AND ugp_user_id = ? 

--$get_manual_mgp_by_group_id_unrestricted
SELECT DISTINCT
mgp_id, 
mgp_mgt_id, 
mgp_group_id
FROM tt_mgt_group_permission
WHERE mgp_group_id = ? 

------------------------------------------------------------------------------------------

--$get_company_company_permissions_by_company_id
SELECT * FROM tt_company_company_permission where ccp_broker_comp_id = ? or ccp_buyside_comp_id = ?

--$get_company_company_permissions_restricted
SELECT tt_company_company_permission.*
FROM ( tt_company_company_permission
INNER JOIN tt_user_group ON tt_company_company_permission.ccp_buyside_comp_id = tt_user_group.ugrp_comp_id )
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id
where tt_user.user_id = ?

--$get_company_company_permissions_bycompany
SELECT * FROM tt_company_company_permission where ccp_broker_comp_id = ?

--$get_company_company_permissions_unrestricted
SELECT * FROM tt_company_company_permission

-----------------------------------------------------------------------

--$get_user_user_relationships_restricted,1
SELECT tt_user_user_relationship.*
FROM (((tt_user_user_relationship 
INNER JOIN tt_user AS tt_user_1 ON tt_user_user_relationship.uur_user_id1 = tt_user_1.user_id) 
INNER JOIN tt_user ON tt_user_user_relationship.uur_user_id2 = tt_user.user_id) 
INNER JOIN tt_user_group_permission AS tt_user_group_permission_1 ON tt_user_1.user_group_id = tt_user_group_permission_1.ugp_group_id) 
INNER JOIN tt_user_group_permission 
ON (tt_user_group_permission.ugp_user_id = tt_user_group_permission_1.ugp_user_id) AND (tt_user.user_group_id = tt_user_group_permission.ugp_group_id)
WHERE tt_user_group_permission.ugp_user_id=? 

--$get_user_user_relationships_bycompany,1
SELECT tt_user_user_relationship.*
FROM (((tt_user_user_relationship 
INNER JOIN tt_user AS tt_user_1 ON tt_user_user_relationship.uur_user_id1 = tt_user_1.user_id) 
INNER JOIN tt_user_group AS tt_user_group_1 ON tt_user_1.user_group_id = tt_user_group_1.ugrp_group_id) 
INNER JOIN tt_user AS tt_user_2 ON tt_user_user_relationship.uur_user_id2 = tt_user_2.user_id) 
INNER JOIN tt_user_group AS tt_user_group_2 ON tt_user_2.user_group_id = tt_user_group_2.ugrp_group_id
WHERE tt_user_group_1.ugrp_comp_id = ?

--$get_user_user_relationships_unrestricted
select * from tt_user_user_relationship

-----------------------------------------------------------------------

--$get_fix_adapter_servers_by_user_id_restricted,1
SELECT tt_user_user_relationship.*
FROM (((tt_user_user_relationship 
INNER JOIN tt_user AS tt_user_1 ON tt_user_user_relationship.uur_user_id1 = tt_user_1.user_id) 
INNER JOIN tt_user ON tt_user_user_relationship.uur_user_id2 = tt_user.user_id) 
INNER JOIN tt_user_group_permission AS tt_user_group_permission_1 ON tt_user_1.user_group_id = tt_user_group_permission_1.ugp_group_id) 
INNER JOIN tt_user_group_permission 
ON (tt_user_group_permission.ugp_user_id = tt_user_group_permission_1.ugp_user_id) AND (tt_user.user_group_id = tt_user_group_permission.ugp_group_id)
WHERE tt_user_group_permission.ugp_user_id=?
and uur_user_id1 = ?
and uur_relationship_type = "fix"

-- Company is dummy arg here
--$get_fix_adapter_servers_by_user_id_bycompany,2
select * from tt_user_user_relationship
where uur_user_id1 = ?
and uur_relationship_type = "fix"

--$get_fix_adapter_servers_by_user_id_unrestricted
select * from tt_user_user_relationship
where uur_user_id1 = ?
and uur_relationship_type = "fix"

-----------------------------------------------------------------------

--$get_fix_adapter_clients_by_server_user_id_restricted,1
SELECT tt_user_user_relationship.*
FROM (((tt_user_user_relationship 
INNER JOIN tt_user AS tt_user_1 ON tt_user_user_relationship.uur_user_id1 = tt_user_1.user_id) 
INNER JOIN tt_user ON tt_user_user_relationship.uur_user_id2 = tt_user.user_id) 
INNER JOIN tt_user_group_permission AS tt_user_group_permission_1 ON tt_user_1.user_group_id = tt_user_group_permission_1.ugp_group_id) 
INNER JOIN tt_user_group_permission 
ON (tt_user_group_permission.ugp_user_id = tt_user_group_permission_1.ugp_user_id) AND (tt_user.user_group_id = tt_user_group_permission.ugp_group_id)
WHERE tt_user_group_permission.ugp_user_id=?
and uur_user_id2 = ?
and uur_relationship_type = "fix"

--$get_fix_adapter_clients_by_server_user_id_unrestricted
select * from tt_user_user_relationship
where uur_user_id2 = ?
and uur_relationship_type = "fix"




-----------------------------------------------------------------------
-----------------------------------------------------------------------

--$get_market_product_group
select mkpg_market_id, mkpg_product_group_id, mkpg_product_group
from tt_market_product_group 
where mkpg_market_product_group_id = ?

--$get_market_product_groups
select * from tt_market_product_group
where mkpg_market_product_group_id <> 0

--$get_all_user_group_sod_permissions
select * from tt_user_group_sod_permission

--$get_markets_and_their_product_groups
select tt_market.market_name, mkpg.mkpg_product_group
from tt_market
inner join tt_market_product_group [mkpg] on tt_market.market_id = mkpg.mkpg_market_id
order by tt_market.market_name, mkpg.mkpg_product_group

----------------------------------------------------------------------
-----------------------------------------------------------------------

--$get_user_market_product_groups_all_restricted,1
SELECT 
tt_user_product_group.*,
tt_user.user_login, 
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_user_product_group LEFT JOIN tt_user AS tt_user_last_updated 
       ON tt_user_product_group.upg_last_updated_user_id = tt_user_last_updated.user_id
      )INNER JOIN tt_user
	  ON tt_user_product_group.upg_user_id = tt_user.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?

--$get_user_market_product_groups_all_bycompany,1
SELECT
tt_user_product_group.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_user_product_group LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_user_product_group.upg_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_user_product_group.upg_user_id = tt_user.user_id
WHERE upg_comp_id = ?

--$get_user_market_product_groups_all_unrestricted
SELECT
tt_user_product_group.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_user_product_group LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_user_product_group.upg_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_user_product_group.upg_user_id = tt_user.user_id

-----------------------------------------------------------------------

--$get_user_market_product_groups_by_user_id_restricted,1
SELECT 
tt_user_product_group.*,
tt_user.user_login, 
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_user_product_group LEFT JOIN tt_user AS tt_user_last_updated 
       ON tt_user_product_group.upg_last_updated_user_id = tt_user_last_updated.user_id
      )INNER JOIN tt_user
	  ON tt_user_product_group.upg_user_id = tt_user.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
AND tt_user.user_id = ?

--$get_user_market_product_groups_by_user_id_bycompany,1
SELECT
tt_user_product_group.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_user_product_group LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_user_product_group.upg_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_user_product_group.upg_user_id = tt_user.user_id
WHERE upg_comp_id = ?
and tt_user.user_id = ?

--$get_user_market_product_groups_by_user_id_unrestricted
SELECT
tt_user_product_group.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_user_product_group LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_user_product_group.upg_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_user_product_group.upg_user_id = tt_user.user_id
WHERE tt_user.user_id = ?	 
	 
------------------------------------------------------------------------------------------

--$get_account_and_account_group_mapping
SELECT
    'A' as [action],
    tt_account_group.ag_id as account_group_id,
    tt_account.acct_id as account_id,
    tt_account.acct_comp_id as broker_id,
    tt_account.acct_name as account_name,
    tt_account.acct_description as account_description
FROM tt_account
INNER JOIN tt_account_group ON tt_account.acct_account_group_id = tt_account_group.ag_id
WHERE tt_account.acct_name <> '' AND tt_account_group.ag_name <> ''
ORDER BY
    tt_account.acct_name,
    tt_account.acct_description

--$get_account_groups_all
SELECT
    'A' as [action],
    tt_account_group.ag_id as account_group_id,
    tt_account_group.ag_name as account_group_name,
    tt_account_group.ag_comp_id as broker_id,
    tt_account_group.ag_risk_enabled as group_risk_enabled,
    tt_account_group.ag_trading_allowed as group_trading_allowed,
    tt_account_group.ag_risk_enabled_for_wholesale_trades as group_risk_enabled_for_wholesale_trades,
    tt_account_group.ag_avoid_orders_that_cross as group_avoid_orders_that_cross,
    tt_account_group.ag_credit as group_credit,
    tt_account_group.ag_credit_currency_abbrev as group_credit_currency_abbrev,
    tt_account_group.ag_apply_margin as group_apply_margin,
    tt_account_group.ag_apply_pl as group_apply_pl

FROM tt_account_group
WHERE tt_account_group.ag_name <> ''
ORDER BY
    tt_account_group.ag_name,
    tt_account_group.ag_comp_id

--$get_account_groups_and_product_limits_NG_by_gateway_id
SELECT
    'A' as [action],
    tt_account_group.ag_id as account_group_id,
    tt_account_group.ag_comp_id as broker_id,
    tt_product_limit.plim_product_limit_id as product_limit_id,
    tt_product_limit.plim_product as product,
    iif( tt_product_limit.plim_product_type = 515, 2, iif( tt_product_limit.plim_product_type = 516, 4, tt_product_limit.plim_product_type ) ) as product_type,
    tt_product_limit.plim_allow_trading_outrights_on as allow_trading_outrights_on,
    tt_product_limit.plim_allow_trading_spreads_on as allow_trading_spreads_on,
    tt_product_limit.plim_max_outright_order_size_on as max_outright_order_size_on,
    tt_product_limit.plim_max_outright_order_size as max_outright_order_size,
    tt_product_limit.plim_max_outright_wholesale_order_size_on as max_outright_wholesale_order_size_on,
    tt_product_limit.plim_max_outright_wholesale_order_size as max_outright_wholesale_order_size,
    tt_product_limit.plim_max_spread_order_size_on as max_spread_order_size_on,
    tt_product_limit.plim_max_spread_order_size as max_spread_order_size,
    tt_product_limit.plim_max_spread_wholesale_order_size_on as max_spread_wholesale_order_size_on,
    tt_product_limit.plim_max_spread_wholesale_order_size as max_spread_wholesale_order_size,
    tt_product_limit.plim_max_product_position_on as max_product_position_on,
    tt_product_limit.plim_max_product_position as max_product_position,
    tt_product_limit.plim_max_outright_position_on as max_outright_position_on,
    tt_product_limit.plim_max_outright_position as max_outright_position,
    tt_product_limit.plim_max_product_long_short_on as max_product_long_short_on,
    tt_product_limit.plim_max_product_long_short as max_product_long_short,
    tt_product_limit.plim_outright_price_rsn_on as outright_price_rsn_on,
    tt_product_limit.plim_outright_price_rsn as outright_price_rsn,
    tt_product_limit.plim_outright_wholesale_price_rsn_on as outright_wholesale_price_rsn_on,
    tt_product_limit.plim_outright_wholesale_price_rsn as outright_wholesale_price_rsn,
    tt_product_limit.plim_outright_price_rsn_into_market_on as outright_price_rsn_into_market_on,
    tt_product_limit.plim_spread_price_rsn_on as spread_price_rsn_on,
    tt_product_limit.plim_spread_price_rsn as spread_price_rsn,
    tt_product_limit.plim_spread_wholesale_price_rsn_on as spread_wholesale_price_rsn_on,
    tt_product_limit.plim_spread_wholesale_price_rsn as spread_wholesale_price_rsn,
    tt_product_limit.plim_spread_price_rsn_into_market_on as spread_price_rsn_into_market_on,
    tt_product_limit.plim_tradeout_only_on as tradeout_only_on,
    tt_product_limit.plim_tradeout_only_days as tradeout_only_days,
    tt_product_limit.plim_additional_outright_margin_pct as addl_outright_margin_pct,
    tt_product_limit.plim_additional_spread_margin_pct as addl_spread_margin_pct,
    tt_product_limit.plim_wholesale_overrides_on as wholesale_overrides_on,
    tt_product_limit.plim_outright_apply_during_non_matching_states_on as outright_apply_during_non_matching_states_on,
    tt_product_limit.plim_spread_apply_during_non_matching_states_on as spread_apply_during_non_matching_states_on,
    tt_product_limit.plim_outright_reject_orders_when_no_market_data_on as outright_reject_orders_when_no_market_data_on,
    tt_product_limit.plim_spread_reject_orders_when_no_market_data_on as spread_reject_orders_when_no_market_data_on
FROM tt_product_limit
INNER JOIN tt_account_group ON tt_product_limit.plim_account_group_id = tt_account_group.ag_id
WHERE tt_product_limit.plim_gateway_id = ?

--$get_contract_limits_by_gateway_id
SELECT
    'A' as [action],
    tt_account_group.ag_id as [account_group_id],
    tt_account_group.ag_comp_id as [broker_id],
    tt_product_limit.plim_product_limit_id as [product_limit_id],
    tt_contract_limit.clim_contract_limit_id as [contract_limit_id],
    tt_contract_limit.clim_name as [name],
    tt_contract_limit.clim_series_key as [series_key],
    tt_contract_limit.clim_expiration as [expiration],
    tt_contract_limit.clim_allow_trading as [allow_trading],
    tt_contract_limit.clim_max_order_size_on as [max_order_size_on],
    tt_contract_limit.clim_max_order_size as [max_order_size],
    tt_contract_limit.clim_max_position_on as [max_position_on],
    tt_contract_limit.clim_max_position as [max_position],
    tt_contract_limit.clim_price_rsn_on as [price_rsn_on],
    tt_contract_limit.clim_price_rsn as [price_rsn]
FROM ( tt_product_limit
INNER JOIN tt_account_group ON tt_product_limit.plim_account_group_id = tt_account_group.ag_id )
INNER JOIN tt_contract_limit ON tt_product_limit.plim_product_limit_id = tt_contract_limit.clim_product_limit_id
WHERE tt_product_limit.plim_gateway_id = ?

--$get_account_groups_and_margin_limits_by_gateway_id
SELECT
    'A' as [action],
    tt_account_group.ag_id as account_group_id,
    tt_margin_limit.mlim_margin_limit_id as margin_limit_id,
    tt_margin_limit.mlim_gateway_id as gateway_id,
    tt_account_group.ag_comp_id as broker_id,
    tt_margin_limit.mlim_margin_limit as [margin_limit],
    iif( tt_margin_limit.mlim_margin_limit > 2000000, 2000000, tt_margin_limit.mlim_margin_limit ) * 100 as [margin_limit_times_100],
    tt_currency.crn_abbrev as [currency]
FROM ( tt_margin_limit
INNER JOIN tt_account_group ON tt_margin_limit.mlim_account_group_id = tt_account_group.ag_id )
INNER JOIN tt_currency ON tt_margin_limit.mlim_currency_id = tt_currency.crn_currency_id
WHERE tt_margin_limit.mlim_margin_limit_enabled = 1 and tt_margin_limit.mlim_gateway_id = ?

--$get_account_groups_and_prevent_dup_orders_by_gateway_id
SELECT
    'A' as [action],
    tt_account_group.ag_id as account_group_id,
    tt_margin_limit.mlim_margin_limit_id as id,
    tt_margin_limit.mlim_gateway_id as gateway_id,
    tt_account_group.ag_comp_id as broker_id,
    tt_margin_limit.mlim_order_threshold as order_threshold
FROM ( tt_margin_limit
INNER JOIN tt_account_group ON tt_margin_limit.mlim_account_group_id = tt_account_group.ag_id )
WHERE tt_margin_limit.mlim_prevent_dup_orders_enabled=1 and  tt_margin_limit.mlim_gateway_id = ?

--$get_margin_by_market_id
SELECT
    'A' as [action],
    tt_company_market_product.cmkp_comp_market_product_id as margin_id,
    tt_company_market_product.cmkp_comp_id as broker_comp_id,
    tt_company_market_product.cmkp_product as product, 
    tt_company_market_product.cmkp_product_type as product_type, 
    tt_company_market_product.cmkp_margin_times_100 as [margin_times_100]
FROM tt_company_market_product 
WHERE tt_company_market_product.cmkp_margin_times_100 <> 0 AND tt_company_market_product.cmkp_market_id = ?

--$private_get_user_groups_all
SELECT
    tt_user_group.ugrp_group_id, 
    tt_user_group.ugrp_name, 
    tt_user_group.ugrp_comp_id, 
    tt_user_group.ugrp_order_passing_allowed, 
    tt_user_group.ugrp_allow_order_passing_to_all_user_groups, 
    tt_user_group.ugrp_show_accounts_on_passed_orders
FROM tt_user_group
ORDER BY
    tt_user_group.ugrp_name,
    tt_user_group.ugrp_comp_id

--$private_get_ob_passing_groups_all
SELECT
    obpg_id, 
    obpg_group_name,
    obpg_owning_comp_id,
    obpg_assigned_comp_id,
    obpg_allow_ob_passing_to_all,
    obpg_show_accounts_on_passed_orders
FROM tt_ob_passing_group
ORDER BY
    obpg_group_name,
    obpg_owning_comp_id

--$get_valid_ob_user_group_mapping
SELECT
    a.group_id1,
    a.group_id2
FROM
(
    SELECT
        group1.ugrp_group_id AS [group_id1],
        group2.ugrp_group_id AS [group_id2]
    FROM ( tt_user_group AS group1
    INNER JOIN tt_ob_passing ON group1.ugrp_group_id = tt_ob_passing.ob_user_group_id )
    INNER JOIN tt_user_group AS group2 ON tt_ob_passing.ob_user_group_id_allowed = group2.ugrp_group_id
    WHERE group1.ugrp_order_passing_allowed = CByte(1)
        AND group1.ugrp_allow_order_passing_to_all_user_groups = CByte(0)
        AND( group2.ugrp_order_passing_allowed = CByte(1) OR group2.ugrp_allow_order_passing_to_all_user_groups = CByte(1) )
    UNION
    SELECT
        group1.ugrp_group_id AS [group_id1],
        group2.ugrp_group_id AS [group_id2]
    FROM tt_user_group AS group1, tt_user_group AS group2
    WHERE group1.ugrp_order_passing_allowed = CByte(1)
        AND ( group2.ugrp_order_passing_allowed = CByte(1) OR group2.ugrp_allow_order_passing_to_all_user_groups = CByte(1) )
        AND group1.ugrp_allow_order_passing_to_all_user_groups = CByte(1)
) a
INNER JOIN
(
    SELECT
        group1.ugrp_group_id AS [group_id1],
        group2.ugrp_group_id AS [group_id2]
    FROM ( tt_user_group AS group1
    INNER JOIN tt_ob_passing ON group1.ugrp_group_id = tt_ob_passing.ob_user_group_id )
    INNER JOIN tt_user_group AS group2 ON tt_ob_passing.ob_user_group_id_allowed = group2.ugrp_group_id
    WHERE group1.ugrp_order_passing_allowed = CByte(1)
        AND group1.ugrp_allow_order_passing_to_all_user_groups = CByte(0)
        AND( group2.ugrp_order_passing_allowed = CByte(1) OR group2.ugrp_allow_order_passing_to_all_user_groups = CByte(1) )
    UNION
    SELECT
        group1.ugrp_group_id AS [group_id1],
        group2.ugrp_group_id AS [group_id2]
    FROM tt_user_group AS group1, tt_user_group AS group2
    WHERE group1.ugrp_order_passing_allowed = CByte(1)
        AND ( group2.ugrp_order_passing_allowed = CByte(1) OR group2.ugrp_allow_order_passing_to_all_user_groups = CByte(1) )
        AND group1.ugrp_allow_order_passing_to_all_user_groups = CByte(1)
) B ON a.group_id1 = b.group_id2 AND a.group_id2 = b.group_id1
WHERE a.group_id1 <> a.group_id2

--$get_valid_ob_passing_group_mapping
SELECT
    a.group_id1,
    a.group_id2
FROM
(
    SELECT
        group1.obpg_id AS [group_id1],
        group2.obpg_id AS [group_id2]
    FROM ( tt_ob_passing_group AS group1
    INNER JOIN tt_ob_passing_mb ON group1.obpg_id = tt_ob_passing_mb.ob_obpg_id )
    INNER JOIN tt_ob_passing_group AS group2 ON tt_ob_passing_mb.ob_obpg_id_allowed = group2.obpg_id
    WHERE group1.obpg_allow_ob_passing_to_all = CByte(0)
        AND group1.obpg_owning_comp_id = group2.obpg_owning_comp_id
    UNION
    SELECT
        group1.obpg_id AS [group_id1],
        group2.obpg_id AS [group_id2]
    FROM tt_ob_passing_group AS group1
    INNER JOIN tt_ob_passing_group AS group2 ON group1.obpg_owning_comp_id = group2.obpg_owning_comp_id
    WHERE group1.obpg_allow_ob_passing_to_all = CByte(1)
) a
INNER JOIN
(
    SELECT
        group1.obpg_id AS [group_id1],
        group2.obpg_id AS [group_id2]
    FROM ( tt_ob_passing_group AS group1
    INNER JOIN tt_ob_passing_mb ON group1.obpg_id = tt_ob_passing_mb.ob_obpg_id )
    INNER JOIN tt_ob_passing_group AS group2 ON tt_ob_passing_mb.ob_obpg_id_allowed = group2.obpg_id
    WHERE group1.obpg_allow_ob_passing_to_all = CByte(0)
        AND group1.obpg_owning_comp_id = group2.obpg_owning_comp_id
    UNION
    SELECT
        group1.obpg_id AS [group_id1],
        group2.obpg_id AS [group_id2]
    FROM tt_ob_passing_group AS group1
    INNER JOIN tt_ob_passing_group AS group2 ON group1.obpg_owning_comp_id = group2.obpg_owning_comp_id
    WHERE group1.obpg_allow_ob_passing_to_all = CByte(1)
) B ON a.group_id1 = b.group_id2 AND a.group_id2 = b.group_id1
WHERE a.group_id1 <> a.group_id2

--$private_get_account_and_account_group_mapping_all
SELECT
    'A' as [action],
    tt_account_group.ag_id as account_group_id,
    tt_account.acct_id as account_id,
    tt_account.acct_comp_id as broker_id,
    tt_account.acct_name as account_name,
    tt_account.acct_description as account_description
FROM tt_account
INNER JOIN tt_account_group ON tt_account.acct_account_group_id = tt_account_group.ag_id
WHERE tt_account.acct_name <> '' AND tt_account_group.ag_name <> ''
ORDER BY
    tt_account_group.ag_name,
    tt_account_group.ag_comp_id,
    tt_account.acct_name,
    tt_account.acct_description

--$private_get_account_groups_and_product_limits_all
SELECT
    'A' as [action],
    tt_account_group.ag_id as account_group_id,
    tt_account_group.ag_comp_id as broker_id,
    tt_product_limit.plim_product_limit_id as product_limit_id,
    tt_product_limit.plim_product as product,
    tt_product_limit.plim_product_type as product_type,
    tt_product_limit.plim_gateway_id as exchange_id,
    tt_product_limit.plim_allow_trading_outrights_on as allow_trading_outrights_on,
    tt_product_limit.plim_allow_trading_spreads_on as allow_trading_spreads_on,
    tt_product_limit.plim_max_outright_order_size_on as max_outright_order_size_on,
    tt_product_limit.plim_max_outright_order_size as max_outright_order_size,
    tt_product_limit.plim_max_outright_wholesale_order_size_on as max_outright_wholesale_order_size_on,
    tt_product_limit.plim_max_outright_wholesale_order_size as max_outright_wholesale_order_size,
    tt_product_limit.plim_max_spread_order_size_on as max_spread_order_size_on,
    tt_product_limit.plim_max_spread_order_size as max_spread_order_size,
    tt_product_limit.plim_max_spread_wholesale_order_size_on as max_spread_wholesale_order_size_on,
    tt_product_limit.plim_max_spread_wholesale_order_size as max_spread_wholesale_order_size,
    tt_product_limit.plim_max_product_position_on as max_product_position_on,
    tt_product_limit.plim_max_product_position as max_product_position,
    tt_product_limit.plim_max_outright_position_on as max_outright_position_on,
    tt_product_limit.plim_max_outright_position as max_outright_position,
    tt_product_limit.plim_max_product_long_short_on as max_product_long_short_on,
    tt_product_limit.plim_max_product_long_short as max_product_long_short,
    tt_product_limit.plim_outright_price_rsn_on as outright_price_rsn_on,
    tt_product_limit.plim_outright_price_rsn as outright_price_rsn,
    tt_product_limit.plim_outright_wholesale_price_rsn_on as outright_wholesale_price_rsn_on,
    tt_product_limit.plim_outright_wholesale_price_rsn as outright_wholesale_price_rsn,
    tt_product_limit.plim_outright_price_rsn_into_market_on as outright_price_rsn_into_market_on,
    tt_product_limit.plim_spread_price_rsn_on as spread_price_rsn_on,
    tt_product_limit.plim_spread_price_rsn as spread_price_rsn,
    tt_product_limit.plim_spread_wholesale_price_rsn_on as spread_wholesale_price_rsn_on,
    tt_product_limit.plim_spread_wholesale_price_rsn as spread_wholesale_price_rsn,
    tt_product_limit.plim_spread_price_rsn_into_market_on as spread_price_rsn_into_market_on,
    tt_product_limit.plim_tradeout_only_on as tradeout_only_on,
    tt_product_limit.plim_tradeout_only_days as tradeout_only_days,
    tt_product_limit.plim_additional_outright_margin_pct as addl_outright_margin_pct,
    tt_product_limit.plim_additional_spread_margin_pct as addl_spread_margin_pct,
    tt_product_limit.plim_wholesale_overrides_on as wholesale_overrides_on,
    tt_product_limit.plim_outright_apply_during_non_matching_states_on as outright_apply_during_non_matching_states_on,
    tt_product_limit.plim_spread_apply_during_non_matching_states_on as spread_apply_during_non_matching_states_on,
    tt_product_limit.plim_outright_reject_orders_when_no_market_data_on as outright_reject_orders_when_no_market_data_on,
    tt_product_limit.plim_spread_reject_orders_when_no_market_data_on as spread_reject_orders_when_no_market_data_on
FROM tt_product_limit
INNER JOIN tt_account_group ON tt_product_limit.plim_account_group_id = tt_account_group.ag_id
ORDER BY tt_product_limit.plim_product_type DESC

--$private_get_contract_limits_all
SELECT
    'A' as [action],
    tt_account_group.ag_id as [account_group_id],
    tt_account_group.ag_comp_id as [broker_id],
    tt_product_limit.plim_product_limit_id as [product_limit_id],
    tt_product_limit.plim_gateway_id as [exchange_id],
    tt_contract_limit.clim_contract_limit_id as [contract_limit_id],
    tt_contract_limit.clim_name as [name],
    tt_contract_limit.clim_series_key as [series_key],
    tt_contract_limit.clim_expiration as [expiration],
    tt_contract_limit.clim_allow_trading as [allow_trading],
    tt_contract_limit.clim_max_order_size_on as [max_order_size_on],
    tt_contract_limit.clim_max_order_size as [max_order_size],
    tt_contract_limit.clim_max_position_on as [max_position_on],
    tt_contract_limit.clim_max_position as [max_position],
    tt_contract_limit.clim_price_rsn_on as [price_rsn_on],
    tt_contract_limit.clim_price_rsn as [price_rsn]
FROM ( tt_product_limit
INNER JOIN tt_account_group ON tt_product_limit.plim_account_group_id = tt_account_group.ag_id )
INNER JOIN tt_contract_limit ON tt_product_limit.plim_product_limit_id = tt_contract_limit.clim_product_limit_id

--$private_get_account_groups_and_margin_limits_all
SELECT
    'A' as [action],
    tt_account_group.ag_id as account_group_id,
    tt_margin_limit.mlim_margin_limit_id as margin_limit_id,
    tt_margin_limit.mlim_gateway_id as gateway_id,
    tt_account_group.ag_comp_id as broker_id,
    tt_margin_limit.mlim_margin_limit as [margin_limit],
    tt_currency.crn_abbrev as [currency]
FROM ( tt_margin_limit
INNER JOIN tt_account_group ON tt_margin_limit.mlim_account_group_id = tt_account_group.ag_id )
INNER JOIN tt_currency ON tt_margin_limit.mlim_currency_id = tt_currency.crn_currency_id
WHERE tt_margin_limit.mlim_margin_limit_enabled = 1

--$private_get_account_groups_and_prevent_dup_orders_all
SELECT
    'A' as [action],
    tt_account_group.ag_id as account_group_id,
    tt_margin_limit.mlim_margin_limit_id as id,
    tt_margin_limit.mlim_gateway_id as gateway_id,
    tt_account_group.ag_comp_id as broker_id,
    tt_margin_limit.mlim_order_threshold as order_threshold
FROM ( tt_margin_limit
INNER JOIN tt_account_group ON tt_margin_limit.mlim_account_group_id = tt_account_group.ag_id )
WHERE tt_margin_limit.mlim_prevent_dup_orders_enabled=1

--$private_get_margin_all
SELECT
    'A' as [action],
    tt_company_market_product.cmkp_comp_market_product_id as margin_id,
    tt_company_market_product.cmkp_comp_id as broker_comp_id,
    tt_company_market_product.cmkp_product as product, 
    tt_company_market_product.cmkp_product_type as product_type, 
    tt_company_market_product.cmkp_margin_times_100 as [margin_times_100],
    tt_company_market_product.cmkp_market_id as market_id
FROM tt_company_market_product
WHERE tt_company_market_product.cmkp_margin_times_100 <> 0

------------------------------------------------------------------------------------------


--$get_operator_ids_by_user_id_restricted,2
SELECT DISTINCT
    tt_user_gmgt.uxg_operator_id
FROM ( tt_user 
INNER JOIN tt_user_group_permission ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id )
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE tt_user.user_id = ? AND tt_user_group_permission.ugp_user_id = ? AND tt_user_gmgt.uxg_operator_id <> ''
ORDER BY tt_user_gmgt.uxg_operator_id

--$get_operator_ids_by_user_id_bycompany,2
SELECT distinct tt_user_gmgt.uxg_operator_id
FROM ( tt_mgt
INNER JOIN tt_gmgt ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader )
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
WHERE tt_user_gmgt.uxg_user_id = ? and ( tt_mgt.mgt_comp_id = ? OR tt_mgt.mgt_comp_id = 0 ) and uxg_operator_id <> ''
ORDER BY tt_user_gmgt.uxg_operator_id

--$get_operator_ids_by_user_id_unrestricted
SELECT DISTINCT uxg_operator_id
FROM tt_user_gmgt
WHERE uxg_user_id = ? and uxg_operator_id <> ''
order by uxg_operator_id


-----------------------------------------------------------------------
-- "get"s used by client end here
-----------------------------------------------------------------------


-----------------------------------------------------------------------
--
-- Insert sql.  The "InsertWhatever" method in the User Setup server
-- handles these sql statements.   The method expects all the
-- variables passed to be in the same order as the table column
-- order as defined in the database

-- The names of these statements must match the names of
-- their "rep" counterparts.   That is
-- if there is "insert_mgt", there must also be "rep_insert_mgt"
-- and the question marks in both must be in the same order
-- as the columns in the "create table" statements.
-- The difference between "insert_mgt" and "rep_insert_mgt"
-- is that the first one lets Access assign the id via its "counter"
-- mechanism while the second one lets the login server assign
-- the id.   We want to be sure the ids in the replicated slave db 
-- exactly match the master db.
-----------------------------------------------------------------------

--$insert_epg_subscription_agreement
INSERT INTO tt_user_mpg_sub_agreement
    ( umsa_created_datetime, umsa_created_user_id, umsa_last_updated_datetime, umsa_last_updated_user_id,
      umsa_user_id, umsa_market_product_group_id )
VALUES
(
?,?,?,?,
?,?
)

--$insert_currency

insert into tt_currency
(
crn_created_datetime,
crn_created_user_id,
crn_last_updated_datetime,
crn_last_updated_user_id,
crn_abbrev
)
values
(
?,?,?,?,
?
)

--$insert_currency_exchange_rate
insert into tt_currency_exchange_rate
(
cex_created_datetime,
cex_created_user_id,
cex_last_updated_datetime,
cex_last_updated_user_id,
cex_from_currency_id,
cex_to_currency_id,
cex_rate_times_10000
)
values
(
?,?,?,?,
?,?,?
)

--$insert_gmgt

insert into tt_gmgt
(
gm_created_datetime,
gm_created_user_id,
gm_last_updated_datetime,
gm_last_updated_user_id,

gm_gateway_id,
gm_member,
gm_group,
gm_trader,

gm_gateway_mgt_key)

values
(
?,?,?,?,
?,?,?,?,
?
)

--$insert_margin_limit
insert into tt_margin_limit
(
mlim_created_datetime,
mlim_created_user_id,
mlim_last_updated_datetime,
mlim_last_updated_user_id,

mlim_account_group_id,
mlim_gateway_id,
mlim_currency_id,
mlim_margin_limit,

mlim_margin_limit_enabled,
mlim_prevent_dup_orders_enabled,
mlim_order_threshold
)
values
(
?,?,?,?,
?,?,?,?,
?,?,?
)

--$insert_contract_limit
insert into tt_contract_limit
(
clim_created_datetime,
clim_created_user_id,
clim_last_updated_datetime,
clim_last_updated_user_id,

clim_product_limit_id,
clim_name,
clim_series_key,
clim_expiration,

clim_allow_trading,
clim_max_order_size_on,
clim_max_order_size,
clim_max_position_on,

clim_max_position,
clim_price_rsn_on,
clim_price_rsn
)
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?
)

--$insert_product_limit
insert into tt_product_limit
(
plim_created_datetime,
plim_created_user_id,
plim_last_updated_datetime,
plim_last_updated_user_id,

plim_gateway_id,
plim_product,
plim_product_type,
plim_additional_margin_pct,

plim_max_order_qty,
plim_max_position,
plim_allow_tradeout,
plim_max_long_short,

plim_product_in_hex,
plim_mgt_id,
plim_for_simulation,
plim_account_group_id,

plim_addl_margin_pct_on, 
plim_max_order_qty_on, 
plim_max_position_on, 
plim_max_long_short_on,

plim_prevent_orders_based_on_price_ticks,
plim_prevent_orders_price_ticks,
plim_enforce_price_limit_on_buysell_only,
plim_allow_trading_outrights_on,

plim_allow_trading_spreads_on,
plim_max_outright_order_size_on,
plim_max_outright_order_size,
plim_max_spread_order_size_on,

plim_max_spread_order_size,
plim_max_product_position_on,
plim_max_product_position,
plim_max_outright_position_on,

plim_max_outright_position,
plim_max_product_long_short_on,
plim_max_product_long_short,
plim_outright_price_rsn_on,

plim_outright_price_rsn,
plim_outright_price_rsn_into_market_on,
plim_spread_price_rsn_on,
plim_spread_price_rsn,

plim_spread_price_rsn_into_market_on,
plim_tradeout_only_on,
plim_tradeout_only_days,
plim_additional_outright_margin_pct,

plim_additional_spread_margin_pct,
plim_max_outright_wholesale_order_size_on,
plim_max_outright_wholesale_order_size,
plim_max_spread_wholesale_order_size_on,

plim_max_spread_wholesale_order_size,
plim_outright_wholesale_price_rsn_on,
plim_outright_wholesale_price_rsn,
plim_spread_wholesale_price_rsn_on,

plim_spread_wholesale_price_rsn,
plim_wholesale_overrides_on,
plim_outright_apply_during_non_matching_states_on,
plim_spread_apply_during_non_matching_states_on,

plim_outright_reject_orders_when_no_market_data_on,
plim_spread_reject_orders_when_no_market_data_on,

plim_allow_trading
)
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?
)

--$insert_mxg
insert into tt_mgt_gmgt
(
mxg_created_datetime,
mxg_created_user_id,
mxg_last_updated_datetime,
mxg_last_updated_user_id,

mxg_mgt_id,
mxg_gmgt_id
)
values
(
?,?,?,?,
?,?
)



--$insert_mgt

insert into tt_mgt
(
mgt_created_datetime,
mgt_created_user_id,
mgt_last_updated_datetime,
mgt_last_updated_user_id,

mgt_member,
mgt_group,
mgt_trader,
mgt_description,

mgt_credit,
mgt_currency,
mgt_allow_trading,
mgt_ignore_pl,

mgt_risk_on,
mgt_publish_to_guardian,
mgt_mgt_key,
mgt_password,

mgt_can_associate_with_user_directly,
mgt_comp_id,
mgt_enable_sods,
mgt_use_simulation_credit,
mgt_simulation_credit,
mgt_type
)

values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?
)

--$insert_user

insert into tt_user
(

--1 // just for correlating fields and question marks
user_created_datetime,
user_created_user_id,
user_last_updated_datetime,
user_last_updated_user_id,

--2
user_group_id,
user_login,
user_display_name,
user_password,

--3
user_city,
user_postal_code,
user_state_id,
user_country_id,

--4
user_status,
user_password_never_expires,
user_must_change_password_next_login,
user_most_recent_password_change_datetime,

--5
user_most_recent_login_datetime,
-- hard-coded
user_failed_login_attempts_count,
user_def1,
user_def2,

--6
user_def3,
user_enforce_ip_login_limit,
user_ip_login_limit,
user_email,

--7
user_restrict_customer_default_editing,
user_address,
user_phone,
user_def4,

--8
user_def5,
user_def6,
user_x_trader_mode,
--hardcoded
user_login_attempt_key,

--9
user_fix_adapter_enable_order_logging,
user_fix_adapter_enable_price_logging,
user_fix_adapter_default_editing_allowed,
user_xrisk_sods_allowed,

--10
user_xrisk_manual_fills_allowed,
user_xrisk_prices_allowed,     
user_xrisk_instant_messages_allowed,
user_cross_orders_allowed,

--11
user_user_setup_user_type,
user_smtp_host,
user_smtp_port,
user_smtp_requires_authentication,

--12
user_smtp_login_user,
user_smtp_login_password,
user_smtp_use_ssl,
user_smtp_from_address,

--13
user_smtp_subject,
user_smtp_body,
user_smtp_include_username_in_message,
user_smtp_enable_settings,

--14
user_quoting_allowed,
user_wholesale_trades_allowed,
user_fmds_allowed,
user_credit,

--15
user_currency,
user_allow_trading,
--hardcoded
user_force_logoff_switch,
user_fix_adapter_role,

--16
user_cross_orders_cancel_resting,
user_fmds_primary_ip,
user_fmds_primary_port,
user_fmds_primary_service,

--17
user_fmds_primary_timeout_in_secs,
user_fmds_secondary_ip,
user_fmds_secondary_port,
user_fmds_secondary_service,

--18
user_fmds_secondary_timeout_in_secs,
user_gui_view_type,
user_use_user_level_fmds_settings,
--hardcoded
user_most_recent_failed_login_attempt_datetime,

--19
user_marked_for_deletion_datetime,
user_ttapi_allowed,
user_mgt_generation_method,
user_staged_order_creation_allowed,

--20
user_staged_order_claiming_allowed,
user_dma_order_creation_allowed,
user_fix_staged_order_creation_allowed,
--user_fix_staged_order_claiming_allowed,

--21
user_fix_dma_order_creation_allowed,
user_use_pl_risk_algo,
user_xrisk_update_trading_allowed_allowed,
user_ttapi_admin_edition_allowed,

--22
user_most_recent_login_datetime_for_inactivity,
user_use_simulation_credit,
user_simulation_credit,
user_on_behalf_of_allowed,

--23
user_mgt_generation_method_member,
user_mgt_generation_method_group,
user_non_simulation_allowed,
user_organization,

--24
user_simulation_allowed,
user_machine_gun_orders_allowed,
user_persist_orders_on_eurex,
user_prevent_orders_based_on_price_ticks,

--25
int_user_prevent_orders_price_ticks,
user_enforce_price_limit_on_buysell_only,
user_prevent_orders_based_on_rate,
int_user_prevent_orders_rate,

--26
user_gtc_orders_allowed,
user_undefined_accounts_allowed,
user_account_changes_allowed,
user_no_sod_user_group_restrictions,

--27
user_liquidate_exceeding_position_limits_allowed, 
user_billing1,
user_billing2,
user_billing3,

--28
user_never_locked_by_inactivity,
user_most_recent_login_ip,
user_most_recent_xt_version,
user_most_recent_fa_version,

--29
user_most_recent_xr_version,
user_algo_deployment_allowed,
user_algo_sharing_allowed,
user_individually_select_admin_logins,

--30
user_ignore_pl,
user_ignore_margin,
user_claim_own_staged_orders_allowed,
user_wholesale_orders_with_undefined_accounts_allowed,

--31
user_account_permissions_enabled,
user_can_submit_market_orders,
user_xrisk_allowed,
user_2fa_required,

--32
user_xtapi_allowed,
user_autotrader_allowed,
user_autospreader_allowed,
user_can_submit_iceberg_orders,

--33
user_can_submit_time_sliced_orders,
user_can_submit_volume_sliced_orders,
user_can_submit_time_duration_orders,
user_can_submit_volume_duration_orders,

--34
user_sms_number,
user_gf_cbot,
user_gf_cme,
user_gf_cme_europe,

--35
user_gf_comex,
user_gf_nymex,
user_gf_dme,
user_netting_cbot,

--36
user_netting_cme,
user_netting_cme_europe,
user_netting_comex,
user_netting_nymex,

--37
user_netting_dme,
user_netting_organization_id,
user_fa_category_id,
user_2fa_required_mode,

--38
user_fix_subscribers_cbot,
user_fix_subscribers_cme,
user_fix_subscribers_cme_europe,
user_fix_subscribers_comex,

--39
user_fix_subscribers_nymex,
user_fix_subscribers_dme,
user_mgt_auto_login,
user_sw_ice_fut_can,

--40
user_sw_ice_phy_env,
user_sw_ice_ifus_gas,
user_sw_ice_ifeu_oil,
user_sw_ice_ifus_pwr,

--41
user_sw_ice_ifeu_com,
user_sw_ice_fut_us,
user_sw_ice_ifeu_fin,
user_sw_ice_endex,

--42
user_sw_ice_fut_sg,
user_aggregator_allowed,
user_sniper_orders_allowed,
user_eu_config_1_allowed,

--43
user_eu_config_1,
user_eu_config_2_allowed,
user_eu_config_2
)

values
(
--1
?,?,?,?,
?,?,?,?,
?,?,?,?,

--4
?,?,?,?,
?,0,?,?,
?,?,?,?,

--7
?,?,?,?,
?,?,?,0,
?,?,?,?,

--10
?,?,?,?,
?,?,?,?,
?,?,?,?,

--13
?,?,?,?,
?,?,?,?,
?,?,0,?,

--16
?,?,?,?,
?,?,?,?,
?,?,?,#1970-01-02 00:00:00#,

--19
#1970-01-02 00:00:00#,?,?,?,
?,?,?,
?,?,?,?,

--22
#1970-01-02 00:00:00#,?,?,?,
?,?,?,?,
?,?,?,?,

--25
?,?,?,?,
?,?,?,?,
?,?,?,?,

--28
?,'','','',
'',?,?,?,
?,?,?,?,

--31
?,?,?,?,
?,?,?,?,
?,?,?,?,

--34
?,?,?,?,
?,?,?,?,
?,?,?,?,

--37
?,?,?,?,
?,?,?,?,
?,?,?,?,

--40
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?

)

--$insert_user_group

insert into tt_user_group
(
ugrp_created_datetime,
ugrp_created_user_id,
ugrp_last_updated_datetime,
ugrp_last_updated_user_id,
ugrp_name,
ugrp_comp_id,
ugrp_order_passing_allowed,
ugrp_allow_order_passing_to_all_user_groups,
ugrp_show_accounts_on_passed_orders
)

values
(
?,?,?,?,
?,?,?,?,
?
)


--$insert_user_gmgt

insert into tt_user_gmgt
(
uxg_created_datetime,
uxg_created_user_id,
uxg_last_updated_datetime,
uxg_last_updated_user_id,

uxg_user_id,
uxg_gmgt_id,
uxg_automatically_login,
uxg_preferred_ip,

uxg_clearing_member,
uxg_default_account,
uxg_available_to_user,
uxg_available_to_fix_adapter_user,

uxg_mandatory_login,
uxg_operator_id,
uxg_max_orders_per_second,
uxg_max_orders_per_second_on,

uxg_exchange_data1,
uxg_exchange_data2,
uxg_exchange_data3,
uxg_exchange_data4,

uxg_exchange_data5,
uxg_exchange_data6,
uxg_market_orders
)

values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?
)

--$insert_customer_default
insert into tt_customer_default
(
cusd_created_datetime,
cusd_created_user_id,
cusd_last_updated_datetime,
cusd_last_updated_user_id,
cusd_user_id,
cusd_customer,
cusd_selected,
cusd_market_id,
cusd_product,
cusd_product_type,
cusd_account_id,
cusd_account_type,
cusd_give_up,
cusd_fft2,
cusd_fft3,
cusd_first_default,
cusd_product_in_hex,
cusd_gateway_id,
cusd_max_order_qty,
cusd_open_close,
cusd_order_type,
cusd_restriction,
cusd_time_in_force,
cusd_use_max_order_qty,
cusd_comp_id,
cusd_on_behalf_of_mgt_id,
cusd_on_behalf_of_user_id,
cusd_on_behalf_of_account_id,
cusd_default_gmgt_id,
cusd_fft4,
cusd_fft5,
cusd_fft6,
cusd_investment_decision,
cusd_execution_decision,
cusd_client,
cusd_dea,
cusd_trading_capacity,
cusd_liquidity_provision,
cusd_cdi,
cusd_al_algo_id
)

values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?
)

--$insert_account_default
insert into tt_account_default
(
acctd_created_datetime,
acctd_created_user_id,
acctd_last_updated_datetime,
acctd_last_updated_user_id,

acctd_user_id,
acctd_account_id,
acctd_market_id,
acctd_product_type,

acctd_account_type,
acctd_give_up,
acctd_fft2,
acctd_fft3,

acctd_sequence_number,
acctd_gateway_id,
acctd_comp_id,
acctd_fft4,
acctd_fft5,
acctd_fft6,
acctd_investment_decision,
acctd_execution_decision,
acctd_client,
acctd_dea,
acctd_trading_capacity,
acctd_liquidity_provision,
acctd_cdi,
acctd_al_algo_id)

values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?
)



--$insert_account
insert into tt_account
(
acct_created_datetime,
acct_created_user_id,
acct_last_updated_datetime,
acct_last_updated_user_id,

acct_name,
acct_name_in_hex,
acct_description,
acct_mgt_id, 

acct_comp_id,
acct_include_in_auto_sods,
acct_account_group_id
)
values
(
?,?,?,?,
?,?,?,?,
?,?,?
)

--$insert_account_group
insert into tt_account_group
(
ag_created_datetime,
ag_created_user_id,
ag_last_updated_datetime,
ag_last_updated_user_id,

ag_name,
ag_name_in_hex,
ag_description,
ag_comp_id, 

ag_is_auto_assigned,
ag_risk_enabled,
ag_trading_allowed,
ag_risk_enabled_for_wholesale_trades,

ag_avoid_orders_that_cross,
ag_credit,
ag_credit_currency_abbrev, 
ag_apply_margin,

ag_apply_pl
)
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?
)

--$insert_ip_address_version
insert into tt_ip_address_version
(
ipv_created_datetime,
ipv_created_user_id,
ipv_last_updated_datetime,
ipv_last_updated_user_id,

ipv_ip_address,
ipv_version,
ipv_tt_product_id,
ipv_user_login,

ipv_exe_path,
ipv_tt_product_name,
ipv_update_count,
ipv_gateway_id,

ipv_lang_id
)
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?
)

--$insert_user_group_permission
insert into tt_user_group_permission
(
ugp_created_datetime,
ugp_created_user_id,
ugp_last_updated_datetime,
ugp_last_updated_user_id,
ugp_user_id,
ugp_group_id,
ugp_automatically_add
) 
values
(
?,?,?,?,
?,?,?
)

--$insert_user_group_sod_permission
insert into tt_user_group_sod_permission
(
ugps_created_datetime,
ugps_created_user_id,
ugps_last_updated_datetime,
ugps_last_updated_user_id,
ugps_user_id,
ugps_group_id
) 
values
(
?,?,?,?,
?,?
)

--$insert_user_company
insert into tt_user_company_permission
(
ucp_created_datetime,
ucp_created_user_id,
ucp_last_updated_datetime,
ucp_last_updated_user_id,
ucp_user_id,
ucp_comp_id,
ucp_customer_default_editing_allowed,
ucp_billing1,
ucp_billing2,
ucp_billing3,
ucp_fix_adapter_default_editing_allowed,
ucp_cross_orders_allowed,
ucp_wholesale_trades_allowed,
ucp_persist_orders_on_eurex,
ucp_prevent_orders_based_on_price_ticks,
ucp_prevent_orders_price_ticks,
ucp_enforce_price_limit_on_buysell_only,
ucp_prevent_orders_based_on_rate,
ucp_prevent_orders_rate,
ucp_dma_order_creation_allowed,
ucp_fix_dma_order_creation_allowed,
ucp_gtc_orders_allowed,
ucp_cross_orders_cancel_resting,
ucp_organization,
ucp_xrisk_sods_allowed,
ucp_xrisk_manual_fills_allowed,
ucp_allow_trading,
ucp_ttapi_allowed,
ucp_undefined_accounts_allowed,
ucp_account_changes_allowed,
ucp_wholesale_orders_with_undefined_accounts_allowed,
ucp_account_permissions_enabled,
ucp_can_submit_market_orders,
ucp_quoting_allowed,
ucp_2fa_required,
ucp_xtapi_allowed,
ucp_autotrader_allowed,
ucp_autospreader_allowed,
ucp_can_manage_trader_based_product_limits,
ucp_ob_passing_group_id,
ucp_can_submit_iceberg_orders,
ucp_can_submit_time_sliced_orders,
ucp_can_submit_volume_sliced_orders,
ucp_can_submit_time_duration_orders,
ucp_can_submit_volume_duration_orders,
ucp_machine_gun_orders_allowed,
ucp_gf_cbot,
ucp_gf_cme,
ucp_gf_cme_europe,
ucp_gf_comex,
ucp_gf_nymex,
ucp_gf_dme,
ucp_2fa_required_mode,
ucp_aggregator_allowed,
ucp_sniper_orders_allowed,
ucp_eu_config_1_allowed,
ucp_eu_config_1,
ucp_eu_config_2_allowed,
ucp_eu_config_2
) 
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?
)

--$insert_user_account
insert into tt_user_account
(
uxa_created_datetime,
uxa_created_user_id,
uxa_last_updated_datetime,
uxa_last_updated_user_id,
uxa_user_id,
uxa_account_id,
uxa_order_routing,
uxa_adl_order_routing
) 
values
(
?,?,?,?,
?,?,?,?
)

--$insert_ob_passing_group
insert into tt_ob_passing_group
(
obpg_created_datetime,
obpg_created_user_id,
obpg_last_updated_datetime,
obpg_last_updated_user_id,
obpg_group_name,
obpg_owning_comp_id,
obpg_assigned_comp_id,
obpg_allow_ob_passing_to_all,
obpg_show_accounts_on_passed_orders
) 
values
(
?,?,?,?,
?,?,?,?,
?
)

--$insert_netting_organization
insert into tt_netting_organization
(
no_created_datetime,
no_created_user_id,
no_last_updated_datetime,
no_last_updated_user_id,
no_comp_id,
no_name,
no_tt_approved,
no_notes
) 
values
(
?,?,?,?,
?,?,?,?

)

--$insert_algo_type
insert into tt_algo_type
(
al_created_datetime,
al_created_user_id,
al_last_updated_datetime,
al_last_updated_user_id,
al_algo_name,
al_comp_id,
al_editable
)
values
(
?,?,?,?,
?,?,?
)

--$insert_account_group_permission
insert into tt_account_group_permission
(
agp_created_datetime,
agp_created_user_id,
agp_last_updated_datetime,
agp_last_updated_user_id,
agp_account_id,
agp_group_id
) 
values
(
?,?,?,?,
?,?
)

--$insert_account_group_group_permission
insert into tt_account_group_group_permission
(
aggp_created_datetime,
aggp_created_user_id,
aggp_last_updated_datetime,
aggp_last_updated_user_id,
aggp_account_group_id,
aggp_group_id
) 
values
(
?,?,?,?,
?,?
)

--$insert_company_company_permission
insert into tt_company_company_permission
(
ccp_created_datetime,
ccp_created_user_id,
ccp_last_updated_datetime,
ccp_last_updated_user_id,
ccp_broker_comp_id,
ccp_buyside_comp_id
) 
values
(
?,?,?,?,
?,?
)

--$insert_mgt_group_permission
insert into tt_mgt_group_permission
(
mgp_created_datetime,
mgp_created_user_id,
mgp_last_updated_datetime,
mgp_last_updated_user_id,
mgp_mgt_id,
mgp_group_id
) 
values
(
?,?,?,?,
?,?
)



--$insert_company
insert into tt_company
(
comp_created_datetime,
comp_created_user_id,
comp_last_updated_datetime,
comp_last_updated_user_id,
comp_name,
comp_is_broker,
comp_abbrev,
comp_smtp_body,
comp_trading_enabled,
comp_trading_enabled_last_updated_user_id,
comp_trading_kill_switch_allowed,
comp_requires_cme_mda,
comp_password_rules_override_on,
comp_2fa_trust_days,
comp_enforce_password_expiration,
comp_expiration_period_days,
comp_requires_ice_mda,
comp_requires_bvmf_mda,
comp_requires_sfe_mda
) 
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?
)

--$insert_user_user_relationship
insert into tt_user_user_relationship
(
uur_created_datetime,
uur_created_user_id,
uur_last_updated_datetime,
uur_last_updated_user_id,

uur_user_id1,
uur_user_id2,
uur_relationship_type
) 
values
(
?,?,?,?,
?,?,?
)

--$insert_app_version_rule
insert into tt_app_version_rule
(
avr_created_datetime,
avr_created_user_id,
avr_last_updated_datetime,
avr_last_updated_user_id,

avr_tt_app_id,
avr_user_id,
avr_comparison_operator,
avr_version,
avr_error,
avr_additional_message,
avr_min_version_from_license,
avr_generated_from_license,
avr_user_group_id
) 
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?
)

--$insert_work_item
insert into tt_work_item
(
wi_created_datetime,
wi_created_user_id,
wi_last_updated_datetime,
wi_last_updated_user_id,
wi_created_by_comp_id,
wi_assigned_to_comp_id,
wi_attention_comp_id,
wi_related_to_user_login,
wi_title,
wi_comments
)
values
(
?,?,?,?,
?,?,?,?,
?,?
)


--$insert_company_market_product
insert into tt_company_market_product
(
cmkp_created_datetime,
cmkp_created_user_id,
cmkp_last_updated_datetime,
cmkp_last_updated_user_id,
cmkp_comp_id,
cmkp_market_id,
cmkp_product_type,
cmkp_product,
cmkp_product_in_hex,
cmkp_margin_times_100
)
values
(
?,?,?,?,
?,?,?,?,
?,?
)


--$insert_user_product_group
insert into tt_user_product_group
(
upg_created_datetime,
upg_created_user_id,
upg_last_updated_datetime,
upg_last_updated_user_id,
upg_user_id,
upg_comp_id,
upg_market_product_group_id
) 
values
(
?,?,?,
?,?,?,?
)

--$insert_order_passing
insert into tt_ob_passing
(
ob_created_datetime,
ob_created_user_id,
ob_last_updated_datetime,
ob_last_updated_user_id,
ob_user_group_id,
ob_user_group_id_allowed
) 
values
(
?,?,?,?,
?,?
)


--$insert_order_passing_mb
insert into tt_ob_passing_mb
(
ob_created_datetime,
ob_created_user_id,
ob_last_updated_datetime,
ob_last_updated_user_id,
ob_obpg_id,
ob_obpg_id_allowed
) 
values
(
?,?,?,?,
?,?
)

--$insert_algo_type
insert into tt_algos
(
al_created_datetime,
al_created_user_id,
al_last_updated_datetime,
al_last_updated_user_id,
al_algo_name,
al_comp_id,
al_editable
)
values
(
?,?,?,?,
?,?,?
)

-----------------------------------------------------------------------
-- inserts for InsertWhatever end here
-----------------------------------------------------------------------


-----------------------------------------------------------------------
-- Update sql, handled by the "UpdateWhatever" method in the login server
-----------------------------------------------------------------------

--$update_primary_currency
update tt_login_server_settings set
lss_last_updated_datetime = ?,
lss_last_updated_user_id = ?,
lss_primary_currency_abbrev = ?

--$update_mgt_password
update tt_mgt set
mgt_last_updated_datetime = ?,
mgt_last_updated_user_id = ?,
mgt_password = ?
where mgt_member = ? 
and mgt_group = ?
and mgt_trader = ?
 

--$update_user_password_skip_rules
update tt_user set
user_last_updated_datetime = ?,
user_last_updated_user_id = ?,

user_password = ?,
user_most_recent_password_change_datetime = ?,
user_failed_login_attempts_count = ?,
user_must_change_password_next_login = ?

where user_id = ?




-----------------------------------------------------------------------
-- Update sql ends here
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- delete sql, handled by the "DeleteWhatever" method in the login server
-----------------------------------------------------------------------

--$delete_epg_subscription_agreement
DELETE FROM tt_user_mpg_sub_agreement
WHERE umsa_user_id = ?
    AND umsa_market_product_group_id = ?

--$delete_currency
delete from tt_currency where crn_currency_id = ?

--$delete_currency_exchange_rate
delete from tt_currency_exchange_rate where cex_exchange_rate_id = ?

--$update_currency_exchange_rate
update tt_currency_exchange_rate set 
cex_last_updated_datetime = ?,
cex_last_updated_user_id = ?,
cex_rate_times_10000 = ?
where cex_exchange_rate_id = ?

--$update_company_market_product
update tt_company_market_product set 
cmkp_last_updated_datetime = ?,
cmkp_last_updated_user_id = ?,
cmkp_margin_times_100 = ?
where cmkp_comp_market_product_id = ?

--for import
--$delete_mxg_by_gateway
delete from tt_mgt_gmgt
where mxg_id in (
select mxg_id from tt_mgt_gmgt
inner join tt_gmgt on tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt.gm_id
where tt_mgt_gmgt.mxg_mgt_id = ?
and tt_gmgt.gm_gateway_id = ?)


--$delete_user_gmgt
delete from tt_user_gmgt where uxg_user_gmgt_id = ?

--$delete_user_gmgt_by_mgt
DELETE FROM tt_user_gmgt
WHERE tt_user_gmgt.uxg_gmgt_id 
IN (
    SELECT gm_id
    FROM tt_gmgt 
    WHERE tt_gmgt.gm_member = ?
      AND tt_gmgt.gm_group = ?
      AND tt_gmgt.gm_trader = ?
   )
AND tt_user_gmgt.uxg_user_id = ?
      
--$delete_algo_type
delete from tt_algos where al_algo_id = ?;

--$delete_order_book_passing
delete from tt_ob_passing where ob_id = ?;

--$delete_order_book_passing_mb
delete from tt_ob_passing_mb where ob_id = ?;

--$delete_all_order_book_passing_mapping
delete from tt_ob_passing where ob_user_group_id = ?;

--$delete_all_order_book_passing_mapping_mb
delete from tt_ob_passing_mb where ob_obpg_id = ?;

--$delete_user_group
delete from tt_user_group where ugrp_group_id = ?;

--$delete_ob_passing_group
delete from tt_ob_passing_group where obpg_id = ?;

--$delete_netting_organization
delete from tt_netting_organization where no_id = ?;

--$delete_customer_default
delete from tt_customer_default where cusd_id = ?;

--$delete_user
delete from tt_user where user_id = ?;

--$delete_account_default
delete from tt_account_default where acctd_id = ?;

--$delete_mgt
delete from tt_mgt where mgt_id = ?;

--$delete_contract_limit
delete from tt_contract_limit where clim_contract_limit_id = ?;

--$delete_product_limit
delete from tt_product_limit where plim_product_limit_id = ?;

--$delete_margin_limit
delete from tt_margin_limit where mlim_margin_limit_id = ?;

--$delete_account
delete from tt_account where acct_id = ?;

--$delete_account_group
delete from tt_account_group where ag_id = ?;

--$delete_user_group_permission
delete from tt_user_group_permission 
where ugp_user_id = ? and ugp_group_id = ?

--$delete_user_group_sod_permission
delete from tt_user_group_sod_permission 
where ugps_user_id = ? and ugps_group_id = ?

--$delete_user_company
delete from tt_user_company_permission 
where ucp_user_id = ? and ucp_comp_id = ?

--$delete_user_account
delete from tt_user_account
where uxa_user_id = ? and uxa_account_id = ?

--$delete_mgt_group_permission
delete from tt_mgt_group_permission 
where mgp_mgt_id = ? and mgp_group_id = ?

--$delete_account_group_permission
delete from tt_account_group_permission 
where agp_account_id = ? and agp_group_id = ?

--$delete_account_group_group_permission
delete from tt_account_group_group_permission 
where aggp_account_group_id = ? and aggp_group_id = ?

--$delete_company_company_permission
delete from tt_company_company_permission 
where ccp_broker_comp_id = ? and ccp_buyside_comp_id = ?

--$delete_company
delete from tt_company where comp_id = ?;

--$delete_user_user_relationship
delete from tt_user_user_relationship where uur_id = ?;

--$delete_fix_clients_assigned_to_server_user
delete from tt_user_user_relationship 
where uur_user_id2 = ? 
and uur_relationship_type = 'fix'

--$delete_fix_servers_assigned_to_client_user
delete from tt_user_user_relationship 
where uur_user_id1 = ?
and uur_relationship_type = 'fix'

--$delete_work_item
delete from tt_work_item
where wi_id = ?

--$delete_app_version_rule
delete from tt_app_version_rule
where avr_id = ?

--$delete_company_market_product
delete from tt_company_market_product where cmkp_comp_market_product_id = ?


--$delete_user_product_group
delete from tt_user_product_group where upg_user_product_group_id = ?

--$delete_blob_by_key
delete from tt_blob where blb_key = ?
-----------------------------------------------------------------------
-- delete sql, handled by the "DeleteWhatever" method in the login server ends here
-----------------------------------------------------------------------







--------------------------------------------------------------------
-- for reports starts here
--------------------------------------------------------------------

--$get_report_users_and_their_accounts_restricted,1
SELECT 
[Username], [Display Name], [Status], [User Group], [All Accts], 
[Gateway Login Accts (XT 7_DOT_12)], [Customer Default Accts], [User Permissioned Accts], tt_company.comp_name as [Company],
IIF( CByte(1) = ag.ag_is_auto_assigned, '', ag.ag_name ) as [Account Group],
IIF( CByte(1) = ag.ag_trading_allowed, 'Yes', 'No' ) as [Trading Allowed],
IIF( CByte(1) = ag.ag_risk_enabled, 'Yes', 'No' ) as [Product Limits Applied],
IIF( CByte(1) = ag.ag_risk_enabled_for_wholesale_trades, 'Yes', 'No' ) as [Apply to Wholesale],
IIF( 2 = ag.ag_avoid_orders_that_cross, 'Yes - Reject new', 'No' ) as [Avoid Orders that Cross]
FROM (((((tt_view_users_and_their_accounts
INNER JOIN tt_user_group_permission ON tt_view_users_and_their_accounts.[User Group Id] = tt_user_group_permission.ugp_group_id)
INNER JOIN tt_user_group ON tt_view_users_and_their_accounts.[User Group Id] = tt_user_group.ugrp_group_id)
INNER JOIN tt_account ON tt_view_users_and_their_accounts.acct_id = tt_account.acct_id )
INNER JOIN tt_company ON tt_account.acct_comp_id = tt_company.comp_id )
INNER JOIN tt_account_group [ag] ON tt_account.acct_account_group_id = ag.ag_id )
WHERE tt_user_group_permission.ugp_user_id = ?
ORDER BY 1, 5;

--$get_report_users_and_their_accounts_bycompany,1
SELECT 
[Username], [Display Name], [Status], [User Group], [All Accts], 
[Gateway Login Accts (XT 7_DOT_12)], [Customer Default Accts], [User Permissioned Accts], tt_company.comp_name as [Company],
IIF( CByte(1) = ag.ag_is_auto_assigned, '', ag.ag_name ) as [Account Group],
IIF( CByte(1) = ag.ag_trading_allowed, 'Yes', 'No' ) as [Trading Allowed],
IIF( CByte(1) = ag.ag_risk_enabled, 'Yes', 'No' ) as [Product Limits Applied],
IIF( CByte(1) = ag.ag_risk_enabled_for_wholesale_trades, 'Yes', 'No' ) as [Apply to Wholesale],
IIF( 2 = ag.ag_avoid_orders_that_cross, 'Yes - Reject new', 'No' ) as [Avoid Orders that Cross]
FROM (((( tt_view_users_and_their_accounts
INNER JOIN tt_user_group ON tt_view_users_and_their_accounts.[User Group Id] = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
INNER JOIN tt_account ON tt_view_users_and_their_accounts.acct_id = tt_account.acct_id )
INNER JOIN tt_account_group [ag] ON tt_account.acct_account_group_id = ag.ag_id )
WHERE tt_account.acct_comp_id = ?
ORDER BY 1, 5;

--$get_report_users_and_their_accounts_unrestricted
SELECT 
[Username], [Display Name], [Status], [User Group], [All Accts], 
[Gateway Login Accts (XT 7_DOT_12)], [Customer Default Accts], [User Permissioned Accts], tt_company.comp_name as [Company],
IIF( CByte(1) = ag.ag_is_auto_assigned, '', ag.ag_name ) as [Account Group],
IIF( CByte(1) = ag.ag_trading_allowed, 'Yes', 'No' ) as [Trading Allowed],
IIF( CByte(1) = ag.ag_risk_enabled, 'Yes', 'No' ) as [Product Limits Applied],
IIF( CByte(1) = ag.ag_risk_enabled_for_wholesale_trades, 'Yes', 'No' ) as [Apply to Wholesale],
IIF( 2 = ag.ag_avoid_orders_that_cross, 'Yes - Reject new', 'No' ) as [Avoid Orders that Cross]
FROM (((( tt_view_users_and_their_accounts
INNER JOIN tt_user_group ON tt_view_users_and_their_accounts.[User Group Id] = tt_user_group.ugrp_group_id )
INNER JOIN tt_account ON tt_view_users_and_their_accounts.acct_id = tt_account.acct_id )
INNER JOIN tt_account_group [ag] ON tt_account.acct_account_group_id = ag.ag_id )
INNER JOIN tt_company ON tt_account.acct_comp_id = tt_company.comp_id )
ORDER BY 1, 5;

--$get_report_users_and_their_account_product_limits_mb_restricted,1
SELECT 
    tt_user.user_login AS [Username], tt_user.user_display_name AS [Display Name],
    IIF( tt_user.user_status = 1, 'Active', 'Inactive' ) AS Status,
    tt_company.comp_name as [Company],
    tt_user.user_def1 AS [User Def 1], tt_user.user_def2 AS [User Def 2], tt_user.user_def3 AS [User Def 3], tt_user.user_def4 AS [User Def 4],
    tt_user.user_def5 AS [User Def 5], tt_user.user_def6 AS [User Def 6], ucp.ucp_billing1 AS [Billing 1], ucp.ucp_billing2 AS [Billing 2], ucp.ucp_billing3 AS [Billing 3],
    tt_user.user_address AS [Address],
    tt_user.user_city AS [City],
    tt_us_state.state_long_name AS [State],
    tt_country.country_name AS [Country],
    tt_user.user_postal_code AS [Postal Code],
    tt_user.user_email AS [Email],
    [All Accts] AS [Account],
    [Customer Default Accts],
    [User Permissioned Accts],
    IIF( CByte(1) = ag.ag_is_auto_assigned, '', ag.ag_name ) as [Account Group],
    tt_market.market_name AS [Market],
    tt_gateway.gateway_name AS [Gateway],
    tt_product_limit.plim_product AS [Product],
    tt_product_type.product_description AS [Product Type],
    CStr( tt_product_limit.plim_additional_outright_margin_pct / 1000 ) AS [Addl Mrgn Outright],
    CStr( tt_product_limit.plim_additional_spread_margin_pct / 1000 ) AS [Addl Mrgn Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_order_size_on, CStr( tt_product_limit.plim_max_outright_order_size ), 'Unlimited' ) AS [Max Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_wholesale_order_size_on, CStr( tt_product_limit.plim_max_outright_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_order_size_on, CStr( tt_product_limit.plim_max_spread_order_size ), 'Unlimited' ) AS [Max Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_wholesale_order_size_on, CStr( tt_product_limit.plim_max_spread_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_product_position_on, CStr( tt_product_limit.plim_max_product_position ), 'Unlimited' ) AS [Max Pos Prod],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_position_on, CStr( tt_product_limit.plim_max_outright_position ), 'Unlimited' ) AS [Max Pos Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_product_long_short_on, CStr( tt_product_limit.plim_max_product_long_short ), 'Unlimited' ) AS [Max Long/Short],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_outrights_on, 'Yes', 'No' ) AS [Trading Outright],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_spreads_on, 'Yes', 'No' ) AS [Trading Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, 'Yes', 'No' ) AS [Price Check Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, CStr( tt_product_limit.plim_outright_price_rsn ), '' ) AS [Ticks Away Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, CStr( tt_product_limit.plim_outright_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Outright],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, 'Yes', 'No' ) AS [Price Check Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, CStr( tt_product_limit.plim_spread_price_rsn ), '' ) AS [Ticks Away Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, CStr( tt_product_limit.plim_spread_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Outright Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Outright w/o Market Data],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Sprd/Strat Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Sprd/Strat w/o Market Data],
    tt_product_limit.plim_last_updated_datetime AS [Product Limit Last Modified]
FROM ((((((((((((( tt_view_users_and_their_uxa_or_cusd_accounts
INNER JOIN tt_user ON tt_view_users_and_their_uxa_or_cusd_accounts.user_id = tt_user.user_id )
INNER JOIN tt_user_group_permission ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_account ON tt_view_users_and_their_uxa_or_cusd_accounts.acct_id = tt_account.acct_id )
INNER JOIN tt_account_group [ag] ON tt_account.acct_account_group_id = ag.ag_id )
INNER JOIN tt_company ON tt_account.acct_comp_id = tt_company.comp_id )
INNER JOIN tt_user_company_permission [ucp] ON ( tt_view_users_and_their_uxa_or_cusd_accounts.user_id = ucp.ucp_user_id ) AND ( tt_view_users_and_their_uxa_or_cusd_accounts.acct_comp_id = ucp.ucp_comp_id ) )
INNER JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
INNER JOIN tt_country ON tt_user.user_country_id = tt_country.country_id )
INNER JOIN tt_product_limit ON ag.ag_id = tt_product_limit.plim_account_group_id )
INNER JOIN tt_gateway ON tt_product_limit.plim_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id )
INNER JOIN tt_product_type ON tt_product_limit.plim_product_type = tt_product_type.product_id )
WHERE CByte(1) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
    AND tt_user_group_permission.ugp_user_id = ?
ORDER BY 1, 5

--$get_report_users_and_their_account_product_limits_mb_bycompany,1
SELECT 
    tt_user.user_login AS [Username], tt_user.user_display_name AS [Display Name],
    IIF( tt_user.user_status = 1, 'Active', 'Inactive' ) AS Status,
    tt_company.comp_name as [Company],
    tt_user.user_def1 AS [User Def 1], tt_user.user_def2 AS [User Def 2], tt_user.user_def3 AS [User Def 3], tt_user.user_def4 AS [User Def 4],
    tt_user.user_def5 AS [User Def 5], tt_user.user_def6 AS [User Def 6], ucp.ucp_billing1 AS [Billing 1], ucp.ucp_billing2 AS [Billing 2], ucp.ucp_billing3 AS [Billing 3],
    tt_user.user_address AS [Address],
    tt_user.user_city AS [City],
    tt_us_state.state_long_name AS [State],
    tt_country.country_name AS [Country],
    tt_user.user_postal_code AS [Postal Code],
    tt_user.user_email AS [Email],
    [All Accts] AS [Account],
    [Customer Default Accts],
    [User Permissioned Accts],
    IIF( CByte(1) = ag.ag_is_auto_assigned, '', ag.ag_name ) as [Account Group],
    tt_market.market_name AS [Market],
    tt_gateway.gateway_name AS [Gateway],
    tt_product_limit.plim_product AS [Product],
    tt_product_type.product_description AS [Product Type],
    CStr( tt_product_limit.plim_additional_outright_margin_pct / 1000 ) AS [Addl Mrgn Outright],
    CStr( tt_product_limit.plim_additional_spread_margin_pct / 1000 ) AS [Addl Mrgn Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_order_size_on, CStr( tt_product_limit.plim_max_outright_order_size ), 'Unlimited' ) AS [Max Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_wholesale_order_size_on, CStr( tt_product_limit.plim_max_outright_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_order_size_on, CStr( tt_product_limit.plim_max_spread_order_size ), 'Unlimited' ) AS [Max Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_wholesale_order_size_on, CStr( tt_product_limit.plim_max_spread_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_product_position_on, CStr( tt_product_limit.plim_max_product_position ), 'Unlimited' ) AS [Max Pos Prod],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_position_on, CStr( tt_product_limit.plim_max_outright_position ), 'Unlimited' ) AS [Max Pos Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_product_long_short_on, CStr( tt_product_limit.plim_max_product_long_short ), 'Unlimited' ) AS [Max Long/Short],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_outrights_on, 'Yes', 'No' ) AS [Trading Outright],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_spreads_on, 'Yes', 'No' ) AS [Trading Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, 'Yes', 'No' ) AS [Price Check Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, CStr( tt_product_limit.plim_outright_price_rsn ), '' ) AS [Ticks Away Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, CStr( tt_product_limit.plim_outright_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Outright],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, 'Yes', 'No' ) AS [Price Check Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, CStr( tt_product_limit.plim_spread_price_rsn ), '' ) AS [Ticks Away Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, CStr( tt_product_limit.plim_spread_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Outright Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Outright w/o Market Data],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Sprd/Strat Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Sprd/Strat w/o Market Data],
    tt_product_limit.plim_last_updated_datetime AS [Product Limit Last Modified]
FROM (((((((((((( tt_view_users_and_their_uxa_or_cusd_accounts
INNER JOIN tt_user ON tt_view_users_and_their_uxa_or_cusd_accounts.user_id = tt_user.user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_account ON tt_view_users_and_their_uxa_or_cusd_accounts.acct_id = tt_account.acct_id )
INNER JOIN tt_account_group [ag] ON tt_account.acct_account_group_id = ag.ag_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
INNER JOIN tt_user_company_permission [ucp] ON ( tt_view_users_and_their_uxa_or_cusd_accounts.user_id = ucp.ucp_user_id ) AND ( tt_view_users_and_their_uxa_or_cusd_accounts.acct_comp_id = ucp.ucp_comp_id ) )
INNER JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
INNER JOIN tt_country ON tt_user.user_country_id = tt_country.country_id )
INNER JOIN tt_product_limit ON ag.ag_id = tt_product_limit.plim_account_group_id )
INNER JOIN tt_gateway ON tt_product_limit.plim_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id )
INNER JOIN tt_product_type ON tt_product_limit.plim_product_type = tt_product_type.product_id )
WHERE CByte(1) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
    AND tt_account.acct_comp_id = ?
ORDER BY 1, 5

--$get_report_users_and_their_account_product_limits_mb_unrestricted
SELECT 
    tt_user.user_login AS [Username], tt_user.user_display_name AS [Display Name],
    IIF( tt_user.user_status = 1, 'Active', 'Inactive' ) AS Status,
    tt_company.comp_name as [Company],
    tt_user.user_def1 AS [User Def 1], tt_user.user_def2 AS [User Def 2], tt_user.user_def3 AS [User Def 3], tt_user.user_def4 AS [User Def 4],
    tt_user.user_def5 AS [User Def 5], tt_user.user_def6 AS [User Def 6], ucp.ucp_billing1 AS [Billing 1], ucp.ucp_billing2 AS [Billing 2], ucp.ucp_billing3 AS [Billing 3],
    tt_user.user_address AS [Address],
    tt_user.user_city AS [City],
    tt_us_state.state_long_name AS [State],
    tt_country.country_name AS [Country],
    tt_user.user_postal_code AS [Postal Code],
    tt_user.user_email AS [Email],
    [All Accts] AS [Account],
    [Customer Default Accts],
    [User Permissioned Accts],
    IIF( CByte(1) = ag.ag_is_auto_assigned, '', ag.ag_name ) as [Account Group],
    tt_market.market_name AS [Market],
    tt_gateway.gateway_name AS [Gateway],
    tt_product_limit.plim_product AS [Product],
    tt_product_type.product_description AS [Product Type],
    CStr( tt_product_limit.plim_additional_outright_margin_pct / 1000 ) AS [Addl Mrgn Outright],
    CStr( tt_product_limit.plim_additional_spread_margin_pct / 1000 ) AS [Addl Mrgn Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_order_size_on, CStr( tt_product_limit.plim_max_outright_order_size ), 'Unlimited' ) AS [Max Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_wholesale_order_size_on, CStr( tt_product_limit.plim_max_outright_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_order_size_on, CStr( tt_product_limit.plim_max_spread_order_size ), 'Unlimited' ) AS [Max Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_wholesale_order_size_on, CStr( tt_product_limit.plim_max_spread_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_product_position_on, CStr( tt_product_limit.plim_max_product_position ), 'Unlimited' ) AS [Max Pos Prod],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_position_on, CStr( tt_product_limit.plim_max_outright_position ), 'Unlimited' ) AS [Max Pos Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_product_long_short_on, CStr( tt_product_limit.plim_max_product_long_short ), 'Unlimited' ) AS [Max Long/Short],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_outrights_on, 'Yes', 'No' ) AS [Trading Outright],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_spreads_on, 'Yes', 'No' ) AS [Trading Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, 'Yes', 'No' ) AS [Price Check Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, CStr( tt_product_limit.plim_outright_price_rsn ), '' ) AS [Ticks Away Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, CStr( tt_product_limit.plim_outright_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Outright],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, 'Yes', 'No' ) AS [Price Check Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, CStr( tt_product_limit.plim_spread_price_rsn ), '' ) AS [Ticks Away Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, CStr( tt_product_limit.plim_spread_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Outright Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Outright w/o Market Data],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Sprd/Strat Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Sprd/Strat w/o Market Data],
    tt_product_limit.plim_last_updated_datetime AS [Product Limit Last Modified]
FROM (((((((((((( tt_view_users_and_their_uxa_or_cusd_accounts
INNER JOIN tt_user ON tt_view_users_and_their_uxa_or_cusd_accounts.user_id = tt_user.user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_account ON tt_view_users_and_their_uxa_or_cusd_accounts.acct_id = tt_account.acct_id )
INNER JOIN tt_account_group [ag] ON tt_account.acct_account_group_id = ag.ag_id )
INNER JOIN tt_company ON tt_account.acct_comp_id = tt_company.comp_id )
INNER JOIN tt_user_company_permission [ucp] ON ( tt_view_users_and_their_uxa_or_cusd_accounts.user_id = ucp.ucp_user_id ) AND ( tt_view_users_and_their_uxa_or_cusd_accounts.acct_comp_id = ucp.ucp_comp_id ) )
INNER JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
INNER JOIN tt_country ON tt_user.user_country_id = tt_country.country_id )
INNER JOIN tt_product_limit ON ag.ag_id = tt_product_limit.plim_account_group_id )
INNER JOIN tt_gateway ON tt_product_limit.plim_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id )
INNER JOIN tt_product_type ON tt_product_limit.plim_product_type = tt_product_type.product_id )
WHERE CByte(1) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
ORDER BY 1, 5


--$get_report_users_and_their_account_product_limits_nonmb_restricted,1
SELECT 
    tt_user.user_login AS [Username], tt_user.user_display_name AS [Display Name],
    IIF( tt_user.user_status = 1, 'Active', 'Inactive' ) AS Status,
    tt_user_group.ugrp_name AS [User Group],
    tt_user.user_def1 AS [User Def 1], tt_user.user_def2 AS [User Def 2], tt_user.user_def3 AS [User Def 3], tt_user.user_def4 AS [User Def 4],
    tt_user.user_def5 AS [User Def 5], tt_user.user_def6 AS [User Def 6],
    tt_user.user_address AS [Address],
    tt_user.user_city AS [City],
    tt_us_state.state_long_name AS [State],
    tt_country.country_name AS [Country],
    tt_user.user_postal_code AS [Postal Code],
    tt_user.user_email AS [Email],
    [All Accts] AS [Account],
    [Customer Default Accts],
    [User Permissioned Accts],
    IIF( CByte(1) = ag.ag_is_auto_assigned, '', ag.ag_name ) as [Account Group],
    tt_market.market_name AS [Market],
    tt_gateway.gateway_name AS [Gateway],
    tt_product_limit.plim_product AS [Product],
    tt_product_type.product_description AS [Product Type],
    CStr( tt_product_limit.plim_additional_outright_margin_pct / 1000 ) AS [Addl Mrgn Outright],
    CStr( tt_product_limit.plim_additional_spread_margin_pct / 1000 ) AS [Addl Mrgn Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_order_size_on, CStr( tt_product_limit.plim_max_outright_order_size ), 'Unlimited' ) AS [Max Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_wholesale_order_size_on, CStr( tt_product_limit.plim_max_outright_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_order_size_on, CStr( tt_product_limit.plim_max_spread_order_size ), 'Unlimited' ) AS [Max Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_wholesale_order_size_on, CStr( tt_product_limit.plim_max_spread_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_product_position_on, CStr( tt_product_limit.plim_max_product_position ), 'Unlimited' ) AS [Max Pos Prod],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_position_on, CStr( tt_product_limit.plim_max_outright_position ), 'Unlimited' ) AS [Max Pos Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_product_long_short_on, CStr( tt_product_limit.plim_max_product_long_short ), 'Unlimited' ) AS [Max Long/Short],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_outrights_on, 'Yes', 'No' ) AS [Trading Outright],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_spreads_on, 'Yes', 'No' ) AS [Trading Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, 'Yes', 'No' ) AS [Price Check Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, CStr( tt_product_limit.plim_outright_price_rsn ), '' ) AS [Ticks Away Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, CStr( tt_product_limit.plim_outright_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Outright],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, 'Yes', 'No' ) AS [Price Check Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, CStr( tt_product_limit.plim_spread_price_rsn ), '' ) AS [Ticks Away Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, CStr( tt_product_limit.plim_spread_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Outright Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Outright w/o Market Data],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Sprd/Strat Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Sprd/Strat w/o Market Data],
    tt_product_limit.plim_last_updated_datetime AS [Product Limit Last Modified]
FROM (((((((((((( tt_view_users_and_their_uxa_or_cusd_accounts
INNER JOIN tt_user ON tt_view_users_and_their_uxa_or_cusd_accounts.user_id = tt_user.user_id )
INNER JOIN tt_user_group_permission ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_account ON tt_view_users_and_their_uxa_or_cusd_accounts.acct_id = tt_account.acct_id )
INNER JOIN tt_account_group [ag] ON tt_account.acct_account_group_id = ag.ag_id )
INNER JOIN tt_company ON tt_account.acct_comp_id = tt_company.comp_id )
INNER JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
INNER JOIN tt_country ON tt_user.user_country_id = tt_country.country_id )
INNER JOIN tt_product_limit ON ag.ag_id = tt_product_limit.plim_account_group_id )
INNER JOIN tt_gateway ON tt_product_limit.plim_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id )
INNER JOIN tt_product_type ON tt_product_limit.plim_product_type = tt_product_type.product_id )
WHERE CByte(0) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
    AND tt_user_group_permission.ugp_user_id = ?
ORDER BY 1, 5;

--$get_report_users_and_their_account_product_limits_nonmb_bycompany,1
SELECT 1

--$get_report_users_and_their_account_product_limits_nonmb_unrestricted
SELECT 
    tt_user.user_login AS [Username], tt_user.user_display_name AS [Display Name],
    IIF( tt_user.user_status = 1, 'Active', 'Inactive' ) AS Status,
    tt_user_group.ugrp_name AS [User Group],
    tt_user.user_def1 AS [User Def 1], tt_user.user_def2 AS [User Def 2], tt_user.user_def3 AS [User Def 3], tt_user.user_def4 AS [User Def 4],
    tt_user.user_def5 AS [User Def 5], tt_user.user_def6 AS [User Def 6],
    tt_user.user_address AS [Address],
    tt_user.user_city AS [City],
    tt_us_state.state_long_name AS [State],
    tt_country.country_name AS [Country],
    tt_user.user_postal_code AS [Postal Code],
    tt_user.user_email AS [Email],
    [All Accts] AS [Account],
    [Customer Default Accts],
    [User Permissioned Accts],
    IIF( CByte(1) = ag.ag_is_auto_assigned, '', ag.ag_name ) as [Account Group],
    tt_market.market_name AS [Market],
    tt_gateway.gateway_name AS [Gateway],
    tt_product_limit.plim_product AS [Product],
    tt_product_type.product_description AS [Product Type],
    CStr( tt_product_limit.plim_additional_outright_margin_pct / 1000 ) AS [Addl Mrgn Outright],
    CStr( tt_product_limit.plim_additional_spread_margin_pct / 1000 ) AS [Addl Mrgn Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_order_size_on, CStr( tt_product_limit.plim_max_outright_order_size ), 'Unlimited' ) AS [Max Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_wholesale_order_size_on, CStr( tt_product_limit.plim_max_outright_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_order_size_on, CStr( tt_product_limit.plim_max_spread_order_size ), 'Unlimited' ) AS [Max Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_spread_wholesale_order_size_on, CStr( tt_product_limit.plim_max_spread_wholesale_order_size ), 'Unlimited' ) AS [Max Wholesale Ord Qty Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_max_product_position_on, CStr( tt_product_limit.plim_max_product_position ), 'Unlimited' ) AS [Max Pos Prod],
    IIF( CByte(1) = tt_product_limit.plim_max_outright_position_on, CStr( tt_product_limit.plim_max_outright_position ), 'Unlimited' ) AS [Max Pos Outright],
    IIF( CByte(1) = tt_product_limit.plim_max_product_long_short_on, CStr( tt_product_limit.plim_max_product_long_short ), 'Unlimited' ) AS [Max Long/Short],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_outrights_on, 'Yes', 'No' ) AS [Trading Outright],
    IIF( CByte(1) = tt_product_limit.plim_allow_trading_spreads_on, 'Yes', 'No' ) AS [Trading Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, 'Yes', 'No' ) AS [Price Check Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, CStr( tt_product_limit.plim_outright_price_rsn ), '' ) AS [Ticks Away Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_wholesale_price_rsn_on, CStr( tt_product_limit.plim_outright_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Outright],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Outright],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, 'Yes', 'No' ) AS [Price Check Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, CStr( tt_product_limit.plim_spread_price_rsn ), '' ) AS [Ticks Away Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, 'Yes', 'No' ) AS [Price Check Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_wholesale_price_rsn_on, CStr( tt_product_limit.plim_spread_wholesale_price_rsn ), '' ) AS [Ticks Away Wholesale Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_into_market_on, 'Yes', 'No' ), '' ) AS [Into Mkt Sprd/Strat],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Outright Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_outright_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_outright_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Outright w/o Market Data],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_apply_during_non_matching_states_on, 'Yes', 'No' ), '' ) AS [Price Check Sprd/Strat Non-matching],
    IIF( CByte(1) = tt_product_limit.plim_spread_price_rsn_on, IIF( CByte(1) = tt_product_limit.plim_spread_reject_orders_when_no_market_data_on, 'Yes', 'No' ), '' ) AS [Reject Sprd/Strat w/o Market Data],
    tt_product_limit.plim_last_updated_datetime AS [Product Limit Last Modified]
FROM ((((((((((( tt_view_users_and_their_uxa_or_cusd_accounts
INNER JOIN tt_user ON tt_view_users_and_their_uxa_or_cusd_accounts.user_id = tt_user.user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_account ON tt_view_users_and_their_uxa_or_cusd_accounts.acct_id = tt_account.acct_id )
INNER JOIN tt_account_group [ag] ON tt_account.acct_account_group_id = ag.ag_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
INNER JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
INNER JOIN tt_country ON tt_user.user_country_id = tt_country.country_id )
INNER JOIN tt_product_limit ON ag.ag_id = tt_product_limit.plim_account_group_id )
INNER JOIN tt_gateway ON tt_product_limit.plim_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id )
INNER JOIN tt_product_type ON tt_product_limit.plim_product_type = tt_product_type.product_id )
WHERE CByte(0) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
ORDER BY 1, 5;

--$get_fix_adapters_and_their_fix_clients_restricted,1:2
SELECT DISTINCT
    server_company.comp_name AS [Company],
    server_user_group.ugrp_name AS [User Group],
    server_user.user_login AS [FIX Server User],
    server_user.user_display_name AS [FIX Server Display Name],
    tt_fix_adapter_role.far_description as [FIX Server Role],
    client_user.user_login AS [FIX Client User],
    client_user.user_display_name AS [FIX Client Display Name]
FROM (((((( tt_user AS [client_user]
INNER JOIN tt_user_user_relationship AS [uur] ON client_user.user_id = uur.uur_user_id1 )
INNER JOIN tt_user AS [server_user] ON uur.uur_user_id2 = server_user.user_id )
INNER JOIN tt_user_group AS [server_user_group] ON server_user.user_group_id = server_user_group.ugrp_group_id )
INNER JOIN tt_company AS [server_company] ON server_user_group.ugrp_comp_id = server_company.comp_id )
INNER JOIN tt_fix_adapter_role ON server_user.user_fix_adapter_role = tt_fix_adapter_role.far_role_id )
INNER JOIN tt_user_group_permission AS [client_ugp] ON client_user.user_group_id = client_ugp.ugp_group_id )
LEFT JOIN tt_user_group_permission AS [server_ugp] ON server_user.user_group_id = server_ugp.ugp_group_id
WHERE uur.uur_relationship_type = 'fix'
    AND ( client_ugp.ugp_user_id = ? AND server_ugp.ugp_user_id = ? )
ORDER BY
    server_company.comp_name,
    server_user_group.ugrp_name,
    server_user.user_login,
    client_user.user_login;

--$get_fix_adapters_and_their_fix_clients_bycompany,1
SELECT
    server_company.comp_name AS [Company],
    server_user_group.ugrp_name AS [User Group],
    server_user.user_login AS [FIX Server User],
    server_user.user_display_name AS [FIX Server Display Name],
    tt_fix_adapter_role.far_description as [FIX Server Role],
    client_user.user_login AS [FIX Client User],
    client_user.user_display_name AS [FIX Client Display Name]
FROM (((( tt_user AS [client_user]
INNER JOIN tt_user_user_relationship AS [uur] ON client_user.user_id = uur.uur_user_id1 )
INNER JOIN tt_user AS [server_user] ON uur.uur_user_id2 = server_user.user_id )
INNER JOIN tt_user_group AS [server_user_group] ON server_user.user_group_id = server_user_group.ugrp_group_id )
INNER JOIN tt_company AS [server_company] ON server_user_group.ugrp_comp_id = server_company.comp_id )
INNER JOIN tt_fix_adapter_role ON server_user.user_fix_adapter_role = tt_fix_adapter_role.far_role_id
WHERE uur.uur_relationship_type = 'fix'
    AND server_company.comp_id = ?
ORDER BY
    server_company.comp_name,
    server_user_group.ugrp_name,
    server_user.user_login,
    client_user.user_login;

--$get_fix_adapters_and_their_fix_clients_unrestricted
SELECT
    server_company.comp_name AS [Company],
    server_user_group.ugrp_name AS [User Group],
    server_user.user_login AS [FIX Server User],
    server_user.user_display_name AS [FIX Server Display Name],
    tt_fix_adapter_role.far_description as [FIX Server Role],
    client_user.user_login AS [FIX Client User],
    client_user.user_display_name AS [FIX Client Display Name]
FROM (((( tt_user AS [client_user]
INNER JOIN tt_user_user_relationship AS [uur] ON client_user.user_id = uur.uur_user_id1 )
INNER JOIN tt_user AS [server_user] ON uur.uur_user_id2 = server_user.user_id )
INNER JOIN tt_user_group AS [server_user_group] ON server_user.user_group_id = server_user_group.ugrp_group_id )
INNER JOIN tt_company AS [server_company] ON server_user_group.ugrp_comp_id = server_company.comp_id )
INNER JOIN tt_fix_adapter_role ON server_user.user_fix_adapter_role = tt_fix_adapter_role.far_role_id
WHERE uur.uur_relationship_type = 'fix'
ORDER BY
    server_company.comp_name,
    server_user_group.ugrp_name,
    server_user.user_login,
    client_user.user_login;


-- This SQL is here for reference only, but it is not used.
-- It's not used because of very poor performance in big dbs, even out-of-memory crashes.
-- Instead of this SQL, the server uses tt_view_users_and_their_mgts1 to fetch users and their mgts, and
-- tt_view_users_and_their_mgts2 to fetch mgts and their exchange traders, and then "joins" them in C++.

--$get_report_users_and_their_gateway_logins
SELECT
tt_user.user_login as [Username],
tt_mgt.mgt_member as [Member],
tt_mgt.mgt_group as [Group],
tt_mgt.mgt_trader as [Trader],
tt_gateway.gateway_name as [Gateway],
tt_gmgt_1.gm_member as [Exch Member],
tt_gmgt_1.gm_group as [Exch Group],
tt_gmgt_1.gm_trader as [Exch Trader],
tt_user.user_display_name as [Display Name],
IIF(tt_user.user_status=1,"Active","Inactive") As [Status],
tt_user_group.ugrp_name as [User Group],
tt_mgt.mgt_description as [Alias],
tt_mgt.mgt_risk_on as [Risk Check],
tt_mgt.mgt_allow_trading as [Allow Trading],
tt_mgt.mgt_credit as [Credit],
tt_market.market_name as [Market],
tt_user_gmgt.uxg_automatically_login as [Auto Login],
tt_user_gmgt.uxg_available_to_user as [Available to User],
tt_user_gmgt.uxg_available_to_fix_adapter_user as [Available to FA User],
tt_fix_adapter_role.far_description as [FA Role]
FROM (tt_user_group 
INNER JOIN (tt_user 
INNER JOIN ((((tt_market 
INNER JOIN tt_gateway ON tt_market.market_id = tt_gateway.gateway_market_id) 
INNER JOIN (tt_mgt 
INNER JOIN tt_gmgt ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) 
INNER JOIN (tt_gmgt AS tt_gmgt_1 
INNER JOIN tt_mgt_gmgt ON tt_gmgt_1.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
INNER JOIN tt_fix_adapter_role ON tt_user.user_fix_adapter_role = tt_fix_adapter_role.far_role_id
WHERE (((tt_gmgt.gm_gateway_id)=[tt_gmgt_1].[gm_gateway_id]))
ORDER BY 1, 2, 3, 4, 5, 6, 7, 8;




--$get_report_mgts_and_product_limit_counts_and_sizes_restricted,1

SELECT 
tt_mgt.mgt_member as [Member],
tt_mgt.mgt_group as [Group],
tt_mgt.mgt_trader as [Trader],
count(1) as [Product Limits],
CLNG((count(1) * (50 + 11)) + sum(len(tt_product_limit.plim_product))) as [Bytes]
FROM ((tt_mgt 
INNER JOIN tt_product_limit 
ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id)
INNER JOIN tt_view_mgt_group_permission_all ON tt_view_mgt_group_permission_all.mgp_mgt_id = tt_mgt.mgt_id)
INNER JOIN tt_user_group_permission ON tt_user_group_permission.ugp_group_id = tt_view_mgt_group_permission_all.mgp_group_id
WHERE tt_product_limit.plim_for_simulation = 0 AND tt_mgt.mgt_id <> 0 AND tt_user_group_permission.ugp_user_id = ? 
GROUP BY 
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader
order by 5 desc;

--$get_report_mgts_and_product_limit_counts_and_sizes_bycompany,1

SELECT 
tt_mgt.mgt_member as [Member],
tt_mgt.mgt_group as [Group],
tt_mgt.mgt_trader as [Trader],
count(1) as [Product Limits],
CLNG((count(1) * (50 + 11)) + sum(len(tt_product_limit.plim_product))) as [Bytes]
FROM tt_mgt 
INNER JOIN tt_product_limit 
ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id
WHERE tt_product_limit.plim_for_simulation = 0 AND tt_mgt.mgt_id <> 0 AND tt_mgt.mgt_comp_id = ?
GROUP BY 
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader
order by 5 desc;

--$get_report_mgts_and_product_limit_counts_and_sizes_unrestricted

SELECT 
tt_mgt.mgt_member as [Member],
tt_mgt.mgt_group as [Group],
tt_mgt.mgt_trader as [Trader],
count(1) as [Product Limits],
CLNG((count(1) * (50 + 11)) + sum(len(tt_product_limit.plim_product))) as [Bytes]
FROM tt_mgt 
INNER JOIN tt_product_limit 
ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id
WHERE tt_product_limit.plim_for_simulation = 0 AND tt_mgt.mgt_id <> 0
GROUP BY 
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader
order by 5 desc;

--$get_report_users_mgt_counts_restricted,1

SELECT Username,[Display Name],[User Group],
(select count(1) from tt_user_gmgt where uxg_user_id = user_id group by uxg_user_id ) AS [Totals Count], 
(select count(1) from tt_user_gmgt where uxg_user_id = user_id and uxg_available_to_user = 1 group by uxg_user_id ) AS [Available to User Count]
FROM (tt_view_users_mgt_counts
INNER JOIN tt_user_group_permission 
ON tt_view_users_mgt_counts.[User Group Id] = tt_user_group_permission.ugp_group_id)
WHERE tt_user_group_permission.ugp_user_id = ?
ORDER BY 1;

--$get_report_users_mgt_counts_bycompany,1

SELECT Username,[Display Name],[User Group],
(select count(1) from tt_user_gmgt where uxg_user_id = user_id group by uxg_user_id ) AS [Totals Count], 
(select count(1) from tt_user_gmgt where uxg_user_id = user_id and uxg_available_to_user = 1 group by uxg_user_id ) AS [Available to User Count]
FROM (((tt_mgt
INNER JOIN tt_gmgt ON (tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader)) 
INNER JOIN tt_user_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id) 
INNER JOIN tt_view_users_mgt_counts ON tt_user_gmgt.uxg_user_id = tt_view_users_mgt_counts.user_id)
WHERE tt_mgt.mgt_comp_id = ?
ORDER BY 1;

--$get_report_users_mgt_counts_unrestricted

SELECT Username,[Display Name],[User Group],
(select count(1) from tt_user_gmgt where uxg_user_id = user_id group by uxg_user_id ) AS [Totals Count], 
(select count(1) from tt_user_gmgt where uxg_user_id = user_id and uxg_available_to_user = 1 group by uxg_user_id ) AS [Available to User Count]
FROM tt_view_users_mgt_counts
ORDER BY 1;

--$get_report_ip_address_version_restricted,1
SELECT 
tt_view_users_with_blank_row.[Username], 
tt_view_users_with_blank_row.[Display Name], 
tt_view_users_with_blank_row.[User Group], 
tt_view_users_with_blank_row.[Company],
tt_view_users_with_blank_row.[Status],
tt_view_users_with_blank_row.[Email], 
tt_view_users_with_blank_row.[Phone],
tt_view_max_ipv_date2.ipv_ip_address as [IP Address],
tt_view_max_ipv_date2.ipv_tt_product_name as [TT Product],
tt_view_max_ipv_date2.ipv_version as [Version],
IIf((tt_view_max_ipv_date2.ipv_lang_id <> 1033 AND tt_view_max_ipv_date2.ipv_lang_id <> 0 AND tt_view_max_ipv_date2.ipv_lang_id <> 9), 'Yes', 'No') as [Is Localized],
tt_view_max_ipv_date2.ipv_last_updated_datetime as [Last Recorded],
tt_view_max_ipv_date2.[User's Most Recent Version Record],
tt_view_max_ipv_date2.ipv_created_datetime as [First Recorded],
tt_view_max_ipv_date2.ipv_update_count as [Number of Recordings],
tt_view_max_ipv_date2.ipv_exe_path as [File Location],
tt_view_users_with_blank_row.[Most Recent Login] as [Most Recently Recorded Login Date/Time for this Username]
FROM (( tt_view_users_with_blank_row 
INNER JOIN tt_user_group_permission ON tt_view_users_with_blank_row.ugrp_group_id = tt_user_group_permission.ugp_group_id)
INNER JOIN tt_view_max_ipv_date2 ON tt_view_users_with_blank_row.Username = tt_view_max_ipv_date2.ipv_user_login )
WHERE tt_user_group_permission.ugp_user_id = ?
group by
tt_view_users_with_blank_row.[Username], 
tt_view_users_with_blank_row.[Display Name], 
tt_view_users_with_blank_row.[User Group], 
tt_view_users_with_blank_row.[Company],
tt_view_users_with_blank_row.[Status],
tt_view_users_with_blank_row.[Email], 
tt_view_users_with_blank_row.[Phone],
tt_view_max_ipv_date2.ipv_ip_address,
tt_view_max_ipv_date2.ipv_tt_product_name,
tt_view_max_ipv_date2.ipv_version,
IIf((tt_view_max_ipv_date2.ipv_lang_id <> 1033 AND tt_view_max_ipv_date2.ipv_lang_id <> 0 AND tt_view_max_ipv_date2.ipv_lang_id <> 9), 'Yes', 'No'),
tt_view_max_ipv_date2.ipv_last_updated_datetime,
tt_view_max_ipv_date2.[User's Most Recent Version Record],
tt_view_max_ipv_date2.ipv_created_datetime,
tt_view_max_ipv_date2.ipv_update_count,
tt_view_max_ipv_date2.ipv_exe_path,
tt_view_users_with_blank_row.[Most Recent Login]
order by username, tt_view_max_ipv_date2.ipv_last_updated_datetime desc;

--$get_report_ip_address_version_bycompany,1
SELECT 
tt_view_users_with_blank_row.[Username], 
tt_view_users_with_blank_row.[Display Name], 
tt_view_users_with_blank_row.[User Group], 
tt_view_users_with_blank_row.[Company],
tt_view_users_with_blank_row.[Status],
tt_view_users_with_blank_row.[Email], 
tt_view_users_with_blank_row.[Phone],
tt_view_max_ipv_date2.ipv_ip_address as [IP Address],
tt_view_max_ipv_date2.ipv_tt_product_name as [TT Product],
tt_view_max_ipv_date2.ipv_version as [Version],
IIf((tt_view_max_ipv_date2.ipv_lang_id <> 1033 AND tt_view_max_ipv_date2.ipv_lang_id <> 0 AND tt_view_max_ipv_date2.ipv_lang_id <> 9), 'Yes', 'No') as [Is Localized],
tt_view_max_ipv_date2.ipv_last_updated_datetime as [Last Recorded],
tt_view_max_ipv_date2.[User's Most Recent Version Record],
tt_view_max_ipv_date2.ipv_created_datetime as [First Recorded],
tt_view_max_ipv_date2.ipv_update_count as [Number of Recordings],
tt_view_max_ipv_date2.ipv_exe_path as [File Location],
tt_view_users_with_blank_row.[Most Recent Login] as [Most Recently Recorded Login Date/Time for this Username]
FROM tt_view_users_with_blank_row 
INNER JOIN tt_view_max_ipv_date2 ON tt_view_users_with_blank_row.Username = tt_view_max_ipv_date2.ipv_user_login
where broker_comp_id = ?
group by
tt_view_users_with_blank_row.[Username], 
tt_view_users_with_blank_row.[Display Name], 
tt_view_users_with_blank_row.[User Group], 
tt_view_users_with_blank_row.[Company],
tt_view_users_with_blank_row.[Status],
tt_view_users_with_blank_row.[Email], 
tt_view_users_with_blank_row.[Phone],
tt_view_max_ipv_date2.ipv_ip_address,
tt_view_max_ipv_date2.ipv_tt_product_name,
tt_view_max_ipv_date2.ipv_version,
IIf((tt_view_max_ipv_date2.ipv_lang_id <> 1033 AND tt_view_max_ipv_date2.ipv_lang_id <> 0 AND tt_view_max_ipv_date2.ipv_lang_id <> 9), 'Yes', 'No'),
tt_view_max_ipv_date2.ipv_last_updated_datetime,
tt_view_max_ipv_date2.[User's Most Recent Version Record],
tt_view_max_ipv_date2.ipv_created_datetime,
tt_view_max_ipv_date2.ipv_update_count,
tt_view_max_ipv_date2.ipv_exe_path,
tt_view_users_with_blank_row.[Most Recent Login]
order by username, tt_view_max_ipv_date2.ipv_last_updated_datetime desc

--$get_report_ip_address_version_unrestricted
SELECT 
tt_view_users_with_blank_row.[Username], 
tt_view_users_with_blank_row.[Display Name], 
tt_view_users_with_blank_row.[User Group], 
tt_view_users_with_blank_row.[Company],
tt_view_users_with_blank_row.[Status],
tt_view_users_with_blank_row.[Email], 
tt_view_users_with_blank_row.[Phone],
tt_view_max_ipv_date2.ipv_ip_address as [IP Address],
tt_view_max_ipv_date2.ipv_tt_product_name as [TT Product],
tt_view_max_ipv_date2.ipv_version as [Version],
IIf((tt_view_max_ipv_date2.ipv_lang_id <> 1033 AND tt_view_max_ipv_date2.ipv_lang_id <> 0 AND tt_view_max_ipv_date2.ipv_lang_id <> 9), 'Yes', 'No') as [Is Localized],
tt_view_max_ipv_date2.ipv_last_updated_datetime as [Last Recorded],
tt_view_max_ipv_date2.[User's Most Recent Version Record],
tt_view_max_ipv_date2.ipv_created_datetime as [First Recorded],
tt_view_max_ipv_date2.ipv_update_count as [Number of Recordings],
tt_view_max_ipv_date2.ipv_exe_path as [File Location],
tt_view_users_with_blank_row.[Most Recent Login] as [Most Recently Recorded Login Date/Time for this Username]
FROM tt_view_users_with_blank_row 
INNER JOIN tt_view_max_ipv_date2 ON tt_view_users_with_blank_row.Username = tt_view_max_ipv_date2.ipv_user_login
group by
tt_view_users_with_blank_row.[Username], 
tt_view_users_with_blank_row.[Display Name], 
tt_view_users_with_blank_row.[User Group], 
tt_view_users_with_blank_row.[Company],
tt_view_users_with_blank_row.[Status],
tt_view_users_with_blank_row.[Email], 
tt_view_users_with_blank_row.[Phone],
tt_view_max_ipv_date2.ipv_ip_address,
tt_view_max_ipv_date2.ipv_tt_product_name,
tt_view_max_ipv_date2.ipv_version,
IIf((tt_view_max_ipv_date2.ipv_lang_id <> 1033 AND tt_view_max_ipv_date2.ipv_lang_id <> 0 AND tt_view_max_ipv_date2.ipv_lang_id <> 9), 'Yes', 'No'),
tt_view_max_ipv_date2.ipv_last_updated_datetime,
tt_view_max_ipv_date2.[User's Most Recent Version Record],
tt_view_max_ipv_date2.ipv_created_datetime,
tt_view_max_ipv_date2.ipv_update_count,
tt_view_max_ipv_date2.ipv_exe_path,
tt_view_users_with_blank_row.[Most Recent Login]
order by username, tt_view_max_ipv_date2.ipv_last_updated_datetime desc





-- ' for syntax coloring in Notepad++

--$get_report_ip_address_version_for_gateways

SELECT
tt_market.market_name as [Market],  
tt_gateway.gateway_name as [Gateway],
ip1.ipv_tt_product_name as [TT Product], 
ip1.ipv_version as [Version],
ip1.ipv_ip_address as [IP Address] ,
ip1.ipv_last_updated_datetime as [Last Recorded]
FROM (( tt_ip_address_version as ip1
inner join
(
  SELECT ipv_tt_product_name, tt_ip_address_version.ipv_ip_address, tt_ip_address_version.ipv_gateway_id,  max( ipv_last_updated_datetime) as max_date
  FROM tt_ip_address_version
  WHERE ipv_gateway_id <> 0
  group by  ipv_tt_product_name, ipv_ip_address, ipv_gateway_id
) ip2 ON ip1.ipv_tt_product_name = ip2.ipv_tt_product_name AND ip1.ipv_ip_address = ip2.ipv_ip_address AND ip1.ipv_gateway_id = ip2.ipv_gateway_id AND ip1.ipv_last_updated_datetime = ip2.max_date )
INNER JOIN tt_gateway ON ip2.ipv_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_market.market_id = tt_gateway.gateway_market_id
WHERE ip1.ipv_gateway_id <> 0


--$get_report_most_recent_x_trader_version_restricted,1
SELECT 
usr1.user_login as [Username], 
usr1.user_display_name as [Display Name], 
tt_user_group.ugrp_name as [User Group],
tt_company.comp_name as [Company],
IIF(usr1.user_status=1,"Active","Inactive") AS [Status], 
usr1.user_email as [Email], 
usr1.user_phone as [Phone], 
tt_view_max_x_trader_user_date2.ipv_last_datetime as [Most recent XT Date], 
tt_view_max_x_trader_user_date2.ipv_ip_address as [Most recent XT IP], 
tt_view_max_x_trader_user_date2.ipv_version as [Most recent XT version],
IIf((tt_view_max_x_trader_user_date2.ipv_lang_id <> 1033 AND tt_view_max_x_trader_user_date2.ipv_lang_id <> 0 AND tt_view_max_x_trader_user_date2.ipv_lang_id <> 9), 'Yes', 'No') as [Is Localized],
usr1.user_most_recent_login_datetime as [Most recent login], 
IIF (usr1.user_most_recent_login_datetime > tt_view_max_x_trader_user_date2.ipv_last_datetime,'Y', '') as [Login date more recent than XT date]
FROM ((( tt_user as usr1
INNER JOIN tt_user_group_permission ON usr1.user_group_id = tt_user_group_permission.ugp_group_id )
INNER JOIN tt_user_group ON usr1.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
LEFT JOIN tt_view_max_x_trader_user_date2 ON usr1.user_login = tt_view_max_x_trader_user_date2.ipv_user_login
WHERE tt_user_group_permission.ugp_user_id = ?
ORDER BY usr1.user_login, tt_view_max_x_trader_user_date2.ipv_last_datetime desc;

--$get_report_most_recent_x_trader_version_bycompany,1
SELECT 
tt_user.user_login as [Username], 
tt_user.user_display_name as [Display Name], 
tt_user_group.ugrp_name as [User Group],
tt_company.comp_name as [Company],
IIF(tt_user.user_status=1,"Active","Inactive") AS [Status], 
tt_user.user_email as [Email], 
tt_user.user_phone as [Phone], 
tt_view_max_x_trader_user_date2.ipv_last_datetime as [Most recent XT Date], 
tt_view_max_x_trader_user_date2.ipv_ip_address as [Most recent XT IP], 
tt_view_max_x_trader_user_date2.ipv_version as [Most recent XT version],
IIf((tt_view_max_x_trader_user_date2.ipv_lang_id <> 1033 AND tt_view_max_x_trader_user_date2.ipv_lang_id <> 0 AND tt_view_max_x_trader_user_date2.ipv_lang_id <> 9), 'Yes', 'No') as [Is Localized],
tt_user.user_most_recent_login_datetime as [Most recent login], 
IIF (tt_user.user_most_recent_login_datetime > tt_view_max_x_trader_user_date2.ipv_last_datetime,'Y', '') as [Login date more recent than XT date]
FROM ((( tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id ) 
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
INNER JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id )
LEFT JOIN tt_view_max_x_trader_user_date2 ON tt_user.user_login = tt_view_max_x_trader_user_date2.ipv_user_login
where tt_user_company_permission.ucp_comp_id = ?
order by tt_user.user_login, tt_view_max_x_trader_user_date2.ipv_last_datetime desc;

--$get_report_most_recent_x_trader_version_unrestricted
SELECT 
tt_user.user_login as [Username], 
tt_user.user_display_name as [Display Name], 
tt_user_group.ugrp_name as [User Group],
tt_company.comp_name as [Company],
IIF(tt_user.user_status=1,"Active","Inactive") AS [Status], 
tt_user.user_email as [Email], 
tt_user.user_phone as [Phone], 
tt_view_max_x_trader_user_date2.ipv_last_datetime as [Most recent XT Date], 
tt_view_max_x_trader_user_date2.ipv_ip_address as [Most recent XT IP], 
tt_view_max_x_trader_user_date2.ipv_version as [Most recent XT version],
IIf((tt_view_max_x_trader_user_date2.ipv_lang_id <> 1033 AND tt_view_max_x_trader_user_date2.ipv_lang_id <> 0 AND tt_view_max_x_trader_user_date2.ipv_lang_id <> 9), 'Yes', 'No') as [Is Localized],
tt_user.user_most_recent_login_datetime as [Most recent login], 
IIF (tt_user.user_most_recent_login_datetime > tt_view_max_x_trader_user_date2.ipv_last_datetime,'Y', '') as [Login date more recent than XT date]
FROM ((tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
LEFT JOIN tt_view_max_x_trader_user_date2 ON tt_user.user_login = tt_view_max_x_trader_user_date2.ipv_user_login
order by tt_user.user_login, tt_view_max_x_trader_user_date2.ipv_last_datetime desc;


-- only used from reports, not diagnostics

--$get_report_mgts_with_same_mg_mismatched_credit_restricted,1
SELECT DISTINCT
[Member],[Group],[Trader],[Currency],[Credit]
FROM ((tt_mgt 
INNER JOIN tt_view_mgt_group_permission_all ON tt_mgt.mgt_id = tt_view_mgt_group_permission_all.mgp_mgt_id) 
INNER JOIN tt_user_group_permission ON tt_view_mgt_group_permission_all.mgp_group_id = tt_user_group_permission.ugp_group_id) 
INNER JOIN tt_view_mg_combos_with_mismatched_credit_ex ON (tt_mgt.mgt_group = tt_view_mg_combos_with_mismatched_credit_ex.[Group]) 
AND (tt_mgt.mgt_member = tt_view_mg_combos_with_mismatched_credit_ex.[Member])
WHERE tt_user_group_permission.ugp_user_id = ?
ORDER BY 1, 2, 3, 4, 5;

--$get_report_mgts_with_same_mg_mismatched_credit_bycompany,1
SELECT 
[Member],[Group],[Trader],[Currency],[Credit]
FROM tt_view_mg_combos_with_mismatched_credit_ex
WHERE mgt_comp_id = ?
ORDER BY 1, 2, 3, 4, 5;

--$get_report_mgts_with_same_mg_mismatched_credit_unrestricted
SELECT 
[Member],[Group],[Trader],[Currency],[Credit]
FROM tt_view_mg_combos_with_mismatched_credit_ex
ORDER BY 1, 2, 3, 4, 5;

--------------------------------------------------------------------
-- sql for reports ends here
--------------------------------------------------------------------










-----------------------------------------------------------------------
-- diagnostics start here.   Some of these are used for reports too.
-----------------------------------------------------------------------


-----------------------------------------------------------------------

--$get_report_user_gmgts_without_corresponding_product_limits_restricted,1
SELECT DISTINCT Username, [Display Name], Member, Group, Trader, Gateway
FROM (((tt_mgt 
INNER JOIN tt_view_mgt_group_permission_all ON tt_mgt.mgt_id = tt_view_mgt_group_permission_all.mgp_mgt_id) 
INNER JOIN tt_user_group_permission ON tt_view_mgt_group_permission_all.mgp_group_id = tt_user_group_permission.ugp_group_id) 
INNER JOIN tt_view_user_gmgts_without_corresponding_product_limits ON tt_mgt.mgt_id = tt_view_user_gmgts_without_corresponding_product_limits.mgt_id)
INNER JOIN tt_user on tt_view_user_gmgts_without_corresponding_product_limits.Username = tt_user.user_login and tt_user_group_permission.ugp_group_id = tt_user.user_group_id
WHERE tt_user_group_permission.ugp_user_id = ?
ORDER BY 1, 2, 3, 4, 5

--$get_report_user_gmgts_without_corresponding_product_limits_unrestricted
SELECT DISTINCT Username, [Display Name], Member, Group, Trader, Gateway from tt_view_user_gmgts_without_corresponding_product_limits
order by 1, 2, 3, 4, 5


-----------------------------------------------------------------------
-- diagnostic G

--$get_report_cusd_markets_without_corresponding_mgt_markets_restricted,1
SELECT Username, [Display Name], Market
FROM tt_view_cusd_markets_without_corresponding_mgt_markets 
INNER JOIN tt_user_group_permission ON tt_view_cusd_markets_without_corresponding_mgt_markets.ugrp_group_id = tt_user_group_permission.ugp_group_id
where tt_user_group_permission.ugp_user_id = ?
order by 1, 2, 3

--$get_report_cusd_markets_without_corresponding_mgt_markets_unrestricted
SELECT Username, [Display Name], Market from tt_view_cusd_markets_without_corresponding_mgt_markets
order by 1, 2, 3



-----------------------------------------------------------------------
-- diagnostic H

--$get_mgt_accts_without_cusd_accts_restricted,1
SELECT [Username], [Display Name], [Member], [Group], [Trader], [Account #]
FROM tt_view_mgt_accts_without_cusd_accts 
INNER JOIN tt_user_group_permission ON tt_view_mgt_accts_without_cusd_accts.user_group_id = tt_user_group_permission.ugp_group_id
where tt_user_group_permission.ugp_user_id = ?
order by 1,2,3,4,5,6

--$get_mgt_accts_without_cusd_accts_unrestricted
SELECT [Username], [Display Name], [Member], [Group], [Trader], [Account #] 
from tt_view_mgt_accts_without_cusd_accts
order by 1,2,3,4,5,6


-----------------------------------------------------------------------
-- diagnostic I

--$get_cusd_accts_without_mgt_accts_restricted,1
SELECT [Username], [Display Name], [Account #]
FROM tt_view_cusd_accts_without_mgt_accts 
INNER JOIN tt_user_group_permission ON  tt_view_cusd_accts_without_mgt_accts.user_group_id = tt_user_group_permission.ugp_group_id
where tt_user_group_permission.ugp_user_id = ?
order by 1, 2, 3

--$get_cusd_accts_without_mgt_accts_unrestricted
SELECT [Username], [Display Name], [Account #] from tt_view_cusd_accts_without_mgt_accts
order by 1, 2, 3


-----------------------------------------------------------------------
-- diagnostic J

--$get_report_accts_associated_with_multiple_order_books_restricted,1
select  
[Account #], 
[Customer Default Username], 
[User Company], 
[Member], 
[Group], 
[Trader], 
[Exch Member], 
[Exch Group], 
[Exch Trader], 
[Gateway],
[Gateway Login Company]
from tt_view_accts_associated_with_multiple_order_books
INNER JOIN tt_user_group_permission ON tt_view_accts_associated_with_multiple_order_books.user_group_id = tt_user_group_permission.ugp_group_id
where tt_user_group_permission.ugp_user_id = ?
order by 1, 2, 3, 4, 5, 6

--$get_report_accts_associated_with_multiple_order_books_unrestricted
select  
[Account #], 
[Customer Default Username], 
[User Company], 
[Member], 
[Group], 
[Trader], 
[Exch Member], 
[Exch Group], 
[Exch Trader], 
[Gateway],
[Gateway Login Company]
from tt_view_accts_associated_with_multiple_order_books
order by 1, 2, 3, 4, 5, 6

-----------------------------------------------------------------------
-- diagnostic L

--$get_fix_clients_with_gateways_missing_from_server_restricted,1
select [Client Username], [Client Display Name], [Server Username], [Server Display Name], [Gateway]
from tt_view_fix_clients_with_gateways_missing_from_server
INNER JOIN tt_user_group_permission ON tt_view_fix_clients_with_gateways_missing_from_server.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
order by 1, 3, 5

--$get_fix_clients_with_gateways_missing_from_server_unrestricted
select [Client Username], [Client Display Name], [Server Username], [Server Display Name], [Gateway]
from tt_view_fix_clients_with_gateways_missing_from_server
order by 1, 3, 5

-----------------------------------------------------------------------
-- diagnostic M

--$get_fix_clients_with_orderbooks_server_cant_see_restricted,1
select [Client Username], [Client Display Name], [Server Username], [Server Display Name], [Gateway], 
[Client Member], [Client Group], [Client Trader],
[Server Member], [Server Group], [Server Trader]
from tt_view_fix_clients_with_orderbooks_server_cant_see
INNER JOIN tt_user_group_permission ON tt_view_fix_clients_with_orderbooks_server_cant_see.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
order by 1, 3, 5, 6,7,8

--$get_fix_clients_with_orderbooks_server_cant_see_unrestricted
select [Client Username], [Client Display Name], [Server Username], [Server Display Name], [Gateway], 
[Client Member], [Client Group], [Client Trader],
[Server Member], [Server Group], [Server Trader]
from tt_view_fix_clients_with_orderbooks_server_cant_see
order by 1, 3, 5, 6,7,8


-----------------------------------------------------------------------
-- diagnostic K

--$get_users_with_multiple_available_to_user_gateways_restricted,1
select [Username], [Display Name], [Gateway] 
from tt_view_users_with_multiple_available_to_user_gateways
INNER JOIN tt_user_group_permission ON tt_view_users_with_multiple_available_to_user_gateways.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
order by 1, 3

--$get_users_with_multiple_available_to_user_gateways_unrestricted
select [Username], [Display Name], [Gateway] 
from tt_view_users_with_multiple_available_to_user_gateways
order by 1, 3

-----------------------------------------------------------------------
-- diagnostic N

--$get_users_with_multiple_available_to_fix_user_gateways_restricted,1
select distinct [Username], [Display Name], [Gateway] 
from tt_view_users_with_multiple_available_to_fix_user_gateways
INNER JOIN tt_user_group_permission ON tt_view_users_with_multiple_available_to_fix_user_gateways.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
order by 1, 3

--$get_users_with_multiple_available_to_fix_user_gateways_unrestricted
select distinct [Username], [Display Name], [Gateway] 
from tt_view_users_with_multiple_available_to_fix_user_gateways
order by 1, 3

-----------------------------------------------------------------------
-- diagnostic P

--$get_report_same_mg_diff_exch_mg_restricted,1
SELECT DISTINCT 
[Username], 
[Display Name], 
[Gateway], 
[Direct Trader Member], 
[Direct Trader Group], 
[TTORD Member], 
[TTORD Group] 
FROM tt_view_same_mg_diff_exch_mg3
INNER JOIN tt_user_group_permission ON tt_view_same_mg_diff_exch_mg3.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
order by 1, 2, 3

--$get_report_same_mg_diff_exch_mg_unrestricted
SELECT DISTINCT 
[Username], 
[Display Name], 
[Gateway], 
[Direct Trader Member], 
[Direct Trader Group], 
[TTORD Member], 
[TTORD Group] 
from tt_view_same_mg_diff_exch_mg3
order by 1, 2, 3


-----------------------------------------------------------------------
-- diagnostic R


--$get_users_missing_location_info_restricted,1
select [Username], [Display Name]
from tt_view_users_missing_location_info
INNER JOIN tt_user_group_permission ON tt_view_users_missing_location_info.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
order by 1, 2

--$get_users_missing_location_info_unrestricted
select [Username], [Display Name]
from tt_view_users_missing_location_info
order by 1, 2


-----------------------------------------------------------------------
-- diagnostic S

--$get_broker_mgs_shared_by_buyside_companies_restricted,1
select Member, `Group`, count(*) as `Companies` from
(
  select
    tt_gmgt.gm_member as Member,
    tt_gmgt.gm_group as `Group`,
    tt_company.comp_id as `Company ID`
  from (((((( tt_gmgt
    inner join tt_user_gmgt on tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
    inner join tt_mgt on tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader )
    inner join tt_user on tt_user.user_id = tt_user_gmgt.uxg_user_id )
    inner join tt_user_group on tt_user.user_group_id = tt_user_group.ugrp_group_id )
    inner join tt_company on tt_user_group.ugrp_comp_id = tt_company.comp_id )
    inner join tt_user_group as broker_ugrp on tt_mgt.mgt_comp_id = broker_ugrp.ugrp_comp_id )
    inner join tt_user as broker_user on broker_ugrp.ugrp_group_id = broker_user.user_group_id
  where broker_user.user_id = ? and ((tt_gmgt.gm_member <> "TTADM" and tt_gmgt.gm_member <> "TTORD") or tt_gmgt.gm_group <> "XXX")
  group by tt_gmgt.gm_member, tt_gmgt.gm_group, tt_company.comp_id
)
  group by Member, `Group`
  having count(*) > 1

--$get_broker_mgs_shared_by_buyside_companies_unrestricted
select Member, `Group`, count(*) as `Companies` from
(
  select
    tt_gmgt.gm_member as Member,
    tt_gmgt.gm_group as `Group`,
    tt_company.comp_id as `Company ID`
  from (((( tt_gmgt
    inner join tt_user_gmgt on tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
    inner join tt_mgt on tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader )
    inner join tt_user on tt_user.user_id = tt_user_gmgt.uxg_user_id )
    inner join tt_user_group on tt_user.user_group_id = tt_user_group.ugrp_group_id )
    inner join tt_company on tt_user_group.ugrp_comp_id = tt_company.comp_id
  where (tt_gmgt.gm_member <> "TTADM" and tt_gmgt.gm_member <> "TTORD") or tt_gmgt.gm_group <> "XXX"
  group by tt_gmgt.gm_member, tt_gmgt.gm_group, tt_company.comp_id
)
  group by Member, `Group`
  having count(*) > 1




-----------------------------------------------------------------------
-- diagnostics end here
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- real-time diagnostics begin
-----------------------------------------------------------------------

--$val_is_gmgt_mg_in_use_by_other_companies
select iif( count(*) > 0, 'A Gateway Login of Member ''' & tt_gmgt.gm_member & ''' and Group ''' & tt_gmgt.gm_group & ''' has already been assigned to a user in another company. Please remove that assignment or consider assigning another Gateway Login to this user.', '' ) as [error_msg]
  from ((((( tt_gmgt
    inner join tt_user_gmgt on tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
    inner join tt_user on tt_user.user_id = tt_user_gmgt.uxg_user_id )
    inner join tt_user_group on tt_user.user_group_id = tt_user_group.ugrp_group_id )
    inner join tt_company on tt_user_group.ugrp_comp_id = tt_company.comp_id )
    inner join tt_gmgt as tt_gmgt_1 on tt_gmgt.gm_member = tt_gmgt_1.gm_member and tt_gmgt.gm_group = tt_gmgt_1.gm_group )
    inner join tt_gateway on tt_gmgt.gm_gateway_id = tt_gateway.gateway_id
  where ((tt_gmgt.gm_member <> "TTADM" and tt_gmgt.gm_member <> "TTORD") or tt_gmgt.gm_group <> "XXX")
    and tt_gmgt_1.gm_id = ?
    and ( tt_gateway.gateway_market_id not in ( 84, 85, 88 ) OR left( tt_gmgt.gm_member, 5 ) = 'TTORD' )
    and tt_user_group.ugrp_comp_id <>
      ( select tt_user_group.ugrp_comp_id
        from tt_user
        inner join tt_user_group on tt_user.user_group_id = tt_user_group.ugrp_group_id
        where tt_user.user_id = ? )
    group by tt_gmgt.gm_member, tt_gmgt.gm_group

--$val_does_enabling_fa_avail_to_user_for_user_gmgt_invalidate_db
SELECT IIF( SUM( directs ) > 0 AND SUM( total ) > 1, 'User ' & user_login & ' already has a ' & gateway_name & ' Gateway Login marked as Available to FIX Client. Please deselect the option for all of ' & user_login & '''s ' & gateway_name & ' Gateway Logins, click Save, and then select Available to FIX Client for one ' & gateway_name & ' Gateway Login to continue.', '' ) as error_msg
FROM
(
  SELECT
      0 as nothing,
      tt_user_1.user_login,
      tt_gateway.gateway_name,
      sum(iif (left(tt_gmgt.gm_member,5) <> 'TTORD', 1, 0)) as [directs],
      count(*) as [total]
  FROM ((((((( tt_user AS tt_user_1
  INNER JOIN tt_user_group ON tt_user_group.ugrp_group_id = tt_user_1.user_group_id )
  INNER JOIN tt_user_gmgt ON tt_user_gmgt.uxg_user_id = tt_user_1.user_id )
  INNER JOIN tt_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
  INNER JOIN tt_gateway ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id )
  INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader )
  INNER JOIN tt_user_gmgt AS tt_user_gmgt_1 ON tt_user_1.user_id = tt_user_gmgt_1.uxg_user_id )
  INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_user_gmgt_1.uxg_gmgt_id = tt_gmgt_1.gm_id )
  INNER JOIN tt_mgt AS tt_mgt_1 ON tt_gmgt_1.gm_member = tt_mgt_1.mgt_member and tt_gmgt_1.gm_group = tt_mgt_1.mgt_group and tt_gmgt_1.gm_trader = tt_mgt_1.mgt_trader
  WHERE tt_user_1.user_status = 1
      AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1
      AND tt_user_gmgt_1.uxg_user_gmgt_id in ?
      AND tt_mgt.mgt_comp_id = tt_mgt_1.mgt_comp_id
      AND tt_gmgt_1.gm_gateway_id = tt_gateway.gateway_id
      AND tt_user_1.user_id IN
          ( SELECT tt_user_user_relationship.uur_user_id1
            FROM tt_user_user_relationship
            INNER JOIN tt_user ON tt_user_user_relationship.uur_user_id2 = tt_user.user_id
            WHERE tt_user.user_status = 1 AND tt_user.user_fix_adapter_role in ( 2, 4 )
          )
  GROUP BY tt_user_1.user_login, tt_gateway.gateway_name
UNION
  SELECT
      1 as nothing,
      tt_user.user_login,
      tt_gateway.gateway_name,
      iif (left(tt_gmgt.gm_member,5) <> 'TTORD', 1, 0) as [directs],
      1 as [total]
  FROM (( tt_gmgt
  INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
  INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
  INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id
  WHERE tt_user_gmgt.uxg_user_gmgt_id in ?
      AND tt_user.user_status = 1
)
GROUP BY gateway_name, user_login
HAVING sum( directs ) > 0 AND sum( total ) > 1

--$val_does_inserting_user_gmgt_with_fa_avail_to_user_invalidate_db
SELECT IIF( SUM( directs ) > 0 AND SUM( total ) > 1, 'User ' & user_login & ' already has a ' & gateway_name & ' Gateway Login marked as Available to FIX Client. Please deselect the option for all of ' & user_login & '''s ' & gateway_name & ' Gateway Logins, click Save, and then select Available to FIX Client for one ' & gateway_name & ' Gateway Login to continue.', '' ) as error_msg
FROM
(
  SELECT
      0 as nothing,
      tt_user_1.user_login,
      tt_gateway.gateway_name,
      sum(iif (left(tt_gmgt_1.gm_member,5) <> 'TTORD', 1, 0)) as [directs],
      count(*) as [total]
  FROM tt_gmgt, tt_mgt AS tt_mgt_1, (((( tt_user AS tt_user_1
  INNER JOIN tt_user_group ON tt_user_group.ugrp_group_id = tt_user_1.user_group_id )
  INNER JOIN tt_user_gmgt ON tt_user_gmgt.uxg_user_id = tt_user_1.user_id )
  INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_gmgt_1.gm_id = tt_user_gmgt.uxg_gmgt_id )
  INNER JOIN tt_gateway ON tt_gateway.gateway_id = tt_gmgt_1.gm_gateway_id )
  INNER JOIN tt_mgt ON tt_gmgt_1.gm_member = tt_mgt.mgt_member and tt_gmgt_1.gm_group = tt_mgt.mgt_group and tt_gmgt_1.gm_trader = tt_mgt.mgt_trader
  WHERE tt_user_1.user_status = 1
      AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1
      AND tt_gmgt.gm_id = ? AND tt_user_1.user_id = ?
      AND tt_mgt.mgt_comp_id = tt_mgt_1.mgt_comp_id
      AND tt_gmgt.gm_member = tt_mgt_1.mgt_member and tt_gmgt.gm_group = tt_mgt_1.mgt_group and tt_gmgt.gm_trader = tt_mgt_1.mgt_trader
      AND tt_gmgt.gm_gateway_id = tt_gateway.gateway_id
      AND tt_user_1.user_id IN
          ( SELECT tt_user_user_relationship.uur_user_id1
            FROM tt_user_user_relationship
            INNER JOIN tt_user ON tt_user_user_relationship.uur_user_id2 = tt_user.user_id
            WHERE tt_user.user_status = 1 AND tt_user.user_fix_adapter_role in ( 2, 4 )
          )
  GROUP BY tt_user_1.user_login, tt_gateway.gateway_name
UNION
  SELECT
      1 as nothing,
      tt_user.user_login,
      tt_gateway.gateway_name,
      iif (left(tt_gmgt.gm_member,5) <> 'TTORD', 1, 0) as [directs],
      1 as [total]
  FROM tt_user, ( tt_gmgt
  INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
  WHERE tt_gmgt.gm_id = ? AND tt_user.user_id = ?
      AND tt_user.user_status = 1
)
GROUP BY gateway_name, user_login
HAVING sum( directs ) > 0 AND sum( total ) > 1

-----------------------------------------------------------------------
-- real-time diagnostics end here
-----------------------------------------------------------------------

--$get_environment_gateways_and_their_version
SELECT
    a.ipv_gateway_id as [gateway_id],
    max( left( a.ipv_version, instr( 3, a.ipv_version, "." ) -1 ) ) as [version]
FROM tt_ip_address_version a
INNER JOIN 
(
  SELECT
      ipv_gateway_id as [gateway_id],
      max( ipv_last_updated_datetime ) as [last_update_time]
  FROM tt_ip_address_version
  WHERE
      ipv_tt_product_id in ( 1, 2, 5, 20 ) and ipv_gateway_id <> 0 and ipv_version <> ''
  GROUP BY
      ipv_gateway_id
) b ON a.ipv_gateway_id = b.gateway_id AND a.ipv_last_updated_datetime = b.last_update_time
WHERE
    a.ipv_tt_product_id in ( 1, 2, 5, 20 ) and a.ipv_gateway_id <> 0 and a.ipv_version <> ''
GROUP BY
    a.ipv_gateway_id

--$get_related_users_by_user_login
SELECT DISTINCT * FROM
(
  SELECT
      admin_user.user_login as request_user_login,
      target_user.user_id as related_user_id,
      target_user.user_login as related_user_login,
      target_user_group.ugrp_comp_id as related_user_comp_id
  FROM (
      tt_user AS admin_user
      INNER JOIN tt_user AS target_user ON admin_user.user_group_id = target_user.user_group_id )
      INNER JOIN tt_user_group AS target_user_group ON target_user.user_group_id = target_user_group.ugrp_group_id
  WHERE
      admin_user.user_login in ('??')
UNION
  SELECT
      admin_user.user_login as request_user_login,
      target_user.user_id as related_user_id,
      target_user.user_login as related_user_login,
      target_user_group.ugrp_comp_id as related_user_comp_id
  FROM ((
      tt_user AS admin_user
      INNER JOIN tt_user_group_permission ON admin_user.user_id = tt_user_group_permission.ugp_user_id )
      INNER JOIN tt_user AS target_user ON tt_user_group_permission.ugp_group_id = target_user.user_group_id )
      INNER JOIN tt_user_group AS target_user_group ON target_user.user_group_id = target_user_group.ugrp_group_id
  WHERE
      ( CByte(0) = ( select lss_multibroker_mode from tt_login_server_settings ) )
      AND admin_user.user_login in ('??')
      AND admin_user.user_user_setup_user_type in ( 2, 3, 7, 11 )
UNION
  SELECT
      admin_user.user_login as request_user_login,
      target_user.user_id as related_user_id,
      target_user.user_login as related_user_login,
      target_user_group.ugrp_comp_id as related_user_comp_id
  FROM (((
      tt_user AS admin_user
      INNER JOIN tt_user_group as admin_user_group ON admin_user.user_group_id = admin_user_group.ugrp_group_id )
      INNER JOIN tt_user_company_permission ON admin_user_group.ugrp_comp_id = tt_user_company_permission.ucp_comp_id )
      INNER JOIN tt_user AS target_user ON tt_user_company_permission.ucp_user_id = target_user.user_id )
      INNER JOIN tt_user_group AS target_user_group ON target_user.user_group_id = target_user_group.ugrp_group_id
  WHERE
      ( CByte(1) = ( select lss_multibroker_mode from tt_login_server_settings ) )
      AND admin_user.user_login in ('??')
      AND ( admin_user.user_user_setup_user_type in ( 2, 3, 7, 11 ) or admin_user.user_mgt_generation_method <> 0 )
UNION
  SELECT
      admin_user.user_login as request_user_login,
      target_user.user_id as related_user_id,
      target_user.user_login as related_user_login,
      target_user_group.ugrp_comp_id as related_user_comp_id
  FROM
      tt_user AS admin_user,
      tt_user AS target_user
      INNER JOIN tt_user_group AS target_user_group ON target_user.user_group_id = target_user_group.ugrp_group_id
  WHERE
      admin_user.user_login in ('??') and admin_user.user_user_setup_user_type = 1
)
ORDER BY
    request_user_login,
    related_user_login

--$get_guardian_traders_and_exchange_traders_unrestricted
SELECT 
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader, 
tt_gateway.gateway_name, 
tt_gmgt.gm_member, 
tt_gmgt.gm_group, 
tt_gmgt.gm_trader
FROM tt_gateway 
INNER JOIN (tt_gmgt 
INNER JOIN (tt_mgt 
INNER JOIN tt_mgt_gmgt 
ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) 
ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id
where tt_mgt.mgt_publish_to_guardian = 1
and Left(tt_mgt.mgt_member,5) = 'TTORD' 
and tt_mgt.mgt_group <> 'XXX'
AND LEFT(tt_mgt.mgt_trader,4) <> 'VIEW' 
AND LEFT(tt_mgt.mgt_trader,3) <> 'MGR'
order by 1,2,3,4

--$get_all_user_account_permissions
SELECT *
FROM
(
  SELECT
      tt_user.user_login,
      tt_user_company_permission.ucp_comp_id as [broker_id],
      tt_account.acct_id as [account_id],
      tt_account.acct_name as [account_name],
      tt_user_account.uxa_order_routing as [order_routing],
      tt_user_account.uxa_adl_order_routing as [adl_order_routing],
      'A' as [action]
  FROM (( tt_user
  INNER JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id )
  INNER JOIN tt_user_account ON tt_user.user_id = tt_user_account.uxa_user_id )
  INNER JOIN tt_account ON tt_user_account.uxa_account_id = tt_account.acct_id
  WHERE tt_user.user_status = CByte(1)
      AND tt_account.acct_comp_id = tt_user_company_permission.ucp_comp_id
      AND tt_user_company_permission.ucp_account_permissions_enabled = CByte(1)
      AND ( select lss_multibroker_mode from tt_login_server_settings ) = CByte(1)
  UNION
  SELECT
      tt_user.user_login,
      tt_user_company_permission.ucp_comp_id as [broker_id],
      -1 as [account_id],
      '*' as [account_name],
      CByte(1) as [order_routing],
      CByte(1) as [adl_order_routing],
      'A' as [action]
  FROM tt_user
  INNER JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id
  WHERE tt_user.user_status = CByte(1)
      AND tt_user_company_permission.ucp_account_permissions_enabled = CByte(0)
      AND ( select lss_multibroker_mode from tt_login_server_settings ) = CByte(1)
  UNION
  SELECT
      tt_user.user_login,
      0 as [broker_id],
      tt_account.acct_id as [account_id],
      tt_account.acct_name as [account_name],
      tt_user_account.uxa_order_routing as [order_routing],
      tt_user_account.uxa_adl_order_routing as [adl_order_routing],
      'A' as [action]
  FROM ( tt_user
  INNER JOIN tt_user_account ON tt_user.user_id = tt_user_account.uxa_user_id )
  INNER JOIN tt_account ON tt_user_account.uxa_account_id = tt_account.acct_id
  WHERE tt_user.user_status = CByte(1)
      AND tt_user.user_account_permissions_enabled = CByte(1)
      AND ( select lss_multibroker_mode from tt_login_server_settings ) = CByte(0)
  UNION
  SELECT
      tt_user.user_login,
      0 as [broker_id],
      -1 as [account_id],
      '*' as [account_name],
      CByte(1) as [order_routing],
      CByte(1) as [adl_order_routing],
      'A' as [action]
  FROM tt_user
  WHERE tt_user.user_status = CByte(1)
      AND tt_user.user_account_permissions_enabled = CByte(0)
      AND ( select lss_multibroker_mode from tt_login_server_settings ) = CByte(0)
)
ORDER BY
    user_login,
    broker_id,
    account_name

--$get_exch_member_broker_relationships
SELECT
    'A' as [action],
    mgt_member as [member],
    mgt_comp_id as [broker_id]
FROM
    tt_mgt
WHERE
    tt_mgt.mgt_comp_id <> 0
    AND LEFT( mgt_member, 5 ) <> 'TTORD'
GROUP BY
    mgt_member,
    mgt_comp_id


-----------------------------------------------------------------------

--$get_mgt_gateway_product_limit_sum_restricted,1
SELECT
    tt_mgt.mgt_id,
    tt_gateway.gateway_id,
    count( tt_product_limit.plim_product_limit_id ) as [product_limits]
FROM ((( tt_mgt
INNER JOIN tt_view_mgt_group_permission_all ON tt_mgt.mgt_id = tt_view_mgt_group_permission_all.mgp_mgt_id )
INNER JOIN tt_user_group_permission ON tt_view_mgt_group_permission_all.mgp_group_id = tt_user_group_permission.ugp_group_id )
INNER JOIN tt_product_limit ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id )
INNER JOIN tt_gateway ON tt_product_limit.plim_gateway_id = tt_gateway.gateway_id
WHERE 0 < tt_product_limit.plim_mgt_id
    AND tt_user_group_permission.ugp_user_id = ?
GROUP BY
    tt_mgt.mgt_id,
    tt_gateway.gateway_id

--$get_mgt_gateway_product_limit_sum_bycompany,1
SELECT
    tt_mgt.mgt_id,
    tt_gateway.gateway_id,
    count( tt_product_limit.plim_product_limit_id ) as [product_limits]
FROM ( tt_mgt
INNER JOIN tt_product_limit ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id )
INNER JOIN tt_gateway ON tt_product_limit.plim_gateway_id = tt_gateway.gateway_id
WHERE 0 < tt_product_limit.plim_mgt_id
    AND tt_mgt.mgt_comp_id = ?
GROUP BY
    tt_mgt.mgt_id,
    tt_gateway.gateway_id

--$get_mgt_gateway_product_limit_sum_unrestricted
SELECT
    tt_mgt.mgt_id,
    tt_gateway.gateway_id,
    count( tt_product_limit.plim_product_limit_id ) as [product_limits]
FROM ( tt_mgt
INNER JOIN tt_product_limit ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id )
INNER JOIN tt_gateway ON tt_product_limit.plim_gateway_id = tt_gateway.gateway_id
WHERE 0 < tt_product_limit.plim_mgt_id
GROUP BY
    tt_mgt.mgt_id,
    tt_gateway.gateway_id

---------------------------------------------------------------------------
--$get_ob_passing_by_user_group_id_restricted,1
SELECT tt_ob_passing.ob_id,
       tt_ob_passing.ob_user_group_id_allowed
FROM tt_ob_passing
INNER JOIN tt_user_group_permission ON tt_ob_passing.ob_user_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?
  AND tt_ob_passing.ob_user_group_id = ?

--$get_ob_passing_by_user_group_id_bycompany,1
SELECT tt_ob_passing.ob_id, 
tt_ob_passing.ob_user_group_id_allowed
FROM tt_user_group 
INNER JOIN tt_ob_passing ON tt_user_group.ugrp_group_id = tt_ob_passing.ob_user_group_id_allowed
WHERE tt_user_group.ugrp_comp_id = ? AND tt_ob_passing.ob_user_group_id = ?

--$get_ob_passing_by_user_group_id_unrestricted
SELECT tt_ob_passing.ob_id, 
tt_ob_passing.ob_user_group_id_allowed
FROM tt_user_group 
INNER JOIN tt_ob_passing ON tt_user_group.ugrp_group_id = tt_ob_passing.ob_user_group_id
WHERE tt_ob_passing.ob_user_group_id = ?


--$get_ob_passing_user_groups_all_restricted,1:2
SELECT DISTINCT
     tt_ob_passing.ob_id as ob_id,
     tt_ob_passing.ob_user_group_id as ob_user_group_id, 
     tt_ob_passing.ob_user_group_id_allowed as ob_user_group_id_allowed
FROM (((( tt_ob_passing
INNER JOIN tt_user_group ug1 ON tt_ob_passing.ob_user_group_id = ug1.ugrp_group_id )
INNER JOIN tt_user_group ug2 ON tt_ob_passing.ob_user_group_id_allowed = ug2.ugrp_group_id )
INNER JOIN tt_user_group_permission AS ugp1 ON ug1.ugrp_group_id =ugp1.ugp_group_id )
INNER JOIN tt_user_group_permission AS ugp2 ON ug2.ugrp_group_id =ugp2.ugp_group_id )
WHERE ugp1.ugp_user_id = ? AND ugp1.ugp_user_id = ugp2.ugp_user_id
    AND ug1.ugrp_order_passing_allowed = CByte(1)
    AND ug1.ugrp_allow_order_passing_to_all_user_groups = CByte(0)

UNION

SELECT DISTINCT
    -1 as ob_id,
     group1.ugrp_group_id as ob_user_group_id,
     group2.ugrp_group_id as ob_user_group_id_allowed
FROM ( tt_user_group AS group1 INNER JOIN tt_user_group_permission AS p1 ON group1.ugrp_group_id = p1.ugp_group_id), 
     (tt_user_group AS group2 INNER JOIN tt_user_group_permission AS p2 ON group2.ugrp_group_id = p2.ugp_group_id)
WHERE p1.ugp_user_id = ?
     AND p1.ugp_user_id = p2.ugp_user_id
     AND group1.ugrp_order_passing_allowed = CByte(1) 
     AND group1.ugrp_allow_order_passing_to_all_user_groups = CByte(1) 

--$get_ob_passing_user_groups_all_bycompany,1:2
SELECT DISTINCT
     tt_ob_passing.ob_id as ob_id,
     tt_ob_passing.ob_user_group_id as ob_user_group_id, 
     tt_ob_passing.ob_user_group_id_allowed as ob_user_group_id_allowed
FROM (tt_user_group 
INNER JOIN tt_ob_passing ON tt_user_group.ugrp_group_id = tt_ob_passing.ob_user_group_id) 
WHERE  tt_user_group.ugrp_order_passing_allowed = CByte(1)
  AND  tt_user_group.ugrp_allow_order_passing_to_all_user_groups = CByte(0)
  AND  tt_user_group.ugrp_comp_id = ?

UNION

SELECT DISTINCT
     -1 as ob_id,
     group1.ugrp_group_id as ob_user_group_id,
     group2.ugrp_group_id as ob_user_group_id_allowed

FROM tt_user_group as group1, tt_user_group AS group2
WHERE  group1.ugrp_order_passing_allowed = CByte(1) AND group1.ugrp_allow_order_passing_to_all_user_groups = CByte(1) 
     AND group1.ugrp_comp_id = ?

--$get_ob_passing_user_groups_all_unrestricted
SELECT DISTINCT
     tt_ob_passing.ob_id as ob_id,
     tt_ob_passing.ob_user_group_id as ob_user_group_id, 
     tt_ob_passing.ob_user_group_id_allowed as ob_user_group_id_allowed
FROM (tt_user_group 
INNER JOIN tt_ob_passing ON tt_user_group.ugrp_group_id = tt_ob_passing.ob_user_group_id) 
WHERE  tt_user_group.ugrp_order_passing_allowed = CByte(1)
  AND  tt_user_group.ugrp_allow_order_passing_to_all_user_groups = CByte(0)

UNION

SELECT DISTINCT
     -1 as ob_id,
     group1.ugrp_group_id as ob_user_group_id,
     group2.ugrp_group_id as ob_user_group_id_allowed

FROM tt_user_group as group1, tt_user_group AS group2
WHERE  group1.ugrp_order_passing_allowed = CByte(1) AND group1.ugrp_allow_order_passing_to_all_user_groups = CByte(1) 


--$get_ob_passing_ob_passing_groups_all_restricted
SELECT 1

--$REAL_get_ob_passing_ob_passing_groups_all_restricted,1:2
SELECT DISTINCT
     tt_ob_passing_mb.ob_id as ob_id,
     tt_ob_passing_mb.ob_obpg_id, 
     tt_ob_passing_mb.ob_obpg_id_allowed
FROM (((( tt_ob_passing_mb
INNER JOIN tt_ob_passing_group AS grp1 ON tt_ob_passing_mb.ob_obpg_id = grp1.obpg_id )
INNER JOIN tt_ob_passing_group AS grp2 ON tt_ob_passing_mb.ob_obpg_id_allowed = grp2.obpg_id )
INNER JOIN tt_user_group AS ug1 ON grp1.obpg_assigned_comp_id = ug1.ugrp_comp_id )
INNER JOIN tt_user_group AS ug2 ON grp2.obpg_assigned_comp_id = ug2.ugrp_comp_id )
WHERE grp1.obpg_allow_ob_passing_to_all = CByte(0)
    AND grp2.obpg_allow_ob_passing_to_all = CByte(0)
    AND ( SELECT user_group_id FROM tt_user WHERE user_id = ? ) IN ( ug1.ugrp_group_id, ug2.ugrp_group_id )

UNION

SELECT DISTINCT
     -1 as ob_id,
     group1.obpg_id as ob_obpg_id,
     group2.obpg_id as ob_obpg_id_allowed
FROM (( tt_ob_passing_group AS group1
INNER JOIN tt_user_group ON group1.obpg_assigned_comp_id = tt_user_group.ugrp_comp_id )
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id ), tt_ob_passing_group AS group2
WHERE group2.obpg_allow_ob_passing_to_all = CByte(1)
    AND tt_user.user_id = ?


--$get_ob_passing_ob_passing_groups_all_bycompany,1:2
SELECT DISTINCT
     tt_ob_passing_mb.ob_id as ob_id,
     tt_ob_passing_mb.ob_obpg_id, 
     tt_ob_passing_mb.ob_obpg_id_allowed
FROM (tt_ob_passing_group
INNER JOIN tt_ob_passing_mb ON tt_ob_passing_group.obpg_id = tt_ob_passing_mb.ob_obpg_id) 
WHERE tt_ob_passing_group.obpg_allow_ob_passing_to_all = CByte(0)
    AND tt_ob_passing_group.obpg_owning_comp_id = ?

UNION

SELECT DISTINCT
     -1 as ob_id,
     group1.obpg_id as ob_user_group_id,
     group2.obpg_id as ob_user_group_id_allowed
FROM tt_ob_passing_group as group1, tt_ob_passing_group AS group2
WHERE group1.obpg_allow_ob_passing_to_all = CByte(1)
    AND group1.obpg_owning_comp_id = ?

--$get_ob_passing_ob_passing_groups_all_unrestricted
SELECT DISTINCT
     tt_ob_passing_mb.ob_id as ob_id,
     tt_ob_passing_mb.ob_obpg_id, 
     tt_ob_passing_mb.ob_obpg_id_allowed
FROM (tt_ob_passing_group
INNER JOIN tt_ob_passing_mb ON tt_ob_passing_group.obpg_id = tt_ob_passing_mb.ob_obpg_id) 
WHERE tt_ob_passing_group.obpg_allow_ob_passing_to_all = CByte(0)

UNION

SELECT DISTINCT
     -1 as ob_id,
     group1.obpg_id as ob_user_group_id,
     group2.obpg_id as ob_user_group_id_allowed
FROM tt_ob_passing_group as group1, tt_ob_passing_group AS group2
WHERE group1.obpg_allow_ob_passing_to_all = CByte(1)


--$get_ob_passing_by_obpg_id_restricted,1
SELECT 1

--$get_ob_passing_by_obpg_id_bycompany,1
SELECT tt_ob_passing_mb.ob_id, 
tt_ob_passing_mb.ob_obpg_id_allowed
FROM tt_ob_passing_group 
INNER JOIN tt_ob_passing_mb ON tt_ob_passing_group.obpg_id = tt_ob_passing_mb.ob_obpg_id_allowed
WHERE tt_ob_passing_group.obpg_owning_comp_id = ? AND tt_ob_passing_mb.ob_obpg_id = ?

--$get_ob_passing_by_obpg_id_unrestricted
SELECT tt_ob_passing_mb.ob_id, tt_ob_passing_mb.ob_obpg_id_allowed
FROM tt_ob_passing_mb
WHERE tt_ob_passing_mb.ob_obpg_id = ?

----------------------------------------------------------------------
-----------------------------------------------------------------------

--$get_user_mpg_sub_agreements_restricted,1
SELECT 
tt_user_mpg_sub_agreement.*,
tt_user.user_login, 
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_user_mpg_sub_agreement LEFT JOIN tt_user AS tt_user_last_updated 
       ON tt_user_mpg_sub_agreement.umsa_last_updated_user_id = tt_user_last_updated.user_id
      )INNER JOIN tt_user
	  ON tt_user_mpg_sub_agreement.umsa_user_id = tt_user.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?

--$get_user_mpg_sub_agreements_bycompany,1
SELECT
tt_user_mpg_sub_agreement.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((( tt_user_company_permission [ucp]
INNER JOIN tt_user_mpg_sub_agreement ON ucp.ucp_user_id = tt_user_mpg_sub_agreement.umsa_user_id )
INNER JOIN tt_user ON tt_user_mpg_sub_agreement.umsa_user_id = tt_user.user_id )
LEFT JOIN tt_user AS tt_user_last_updated ON tt_user_mpg_sub_agreement.umsa_last_updated_user_id = tt_user_last_updated.user_id )
WHERE ucp.ucp_comp_id = ?

--$get_user_mpg_sub_agreements_unrestricted
SELECT
tt_user_mpg_sub_agreement.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_user_mpg_sub_agreement LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_user_mpg_sub_agreement.umsa_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_user_mpg_sub_agreement.umsa_user_id = tt_user.user_id

-----------------------------------------------------------------------

--$get_user_mpg_sub_agreements_by_user_id_restricted,1
SELECT 
tt_user_mpg_sub_agreement.*,
tt_user.user_login, 
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((tt_user_mpg_sub_agreement LEFT JOIN tt_user AS tt_user_last_updated 
       ON tt_user_mpg_sub_agreement.umsa_last_updated_user_id = tt_user_last_updated.user_id
      )INNER JOIN tt_user
	  ON tt_user_mpg_sub_agreement.umsa_user_id = tt_user.user_id)
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id 
WHERE tt_user_group_permission.ugp_user_id = ?
AND tt_user.user_id = ?

--$get_user_mpg_sub_agreements_by_user_id_bycompany,1
SELECT
tt_user_mpg_sub_agreement.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM ((( tt_user_company_permission [ucp]
INNER JOIN tt_user_mpg_sub_agreement ON ucp.ucp_user_id = tt_user_mpg_sub_agreement.umsa_user_id )
INNER JOIN tt_user ON tt_user_mpg_sub_agreement.umsa_user_id = tt_user.user_id )
LEFT JOIN tt_user AS tt_user_last_updated ON tt_user_mpg_sub_agreement.umsa_last_updated_user_id = tt_user_last_updated.user_id )
WHERE ucp.ucp_comp_id = ?
and tt_user.user_id = ?

--$get_user_mpg_sub_agreements_by_user_id_unrestricted
SELECT
tt_user_mpg_sub_agreement.*,
tt_user.user_login,
tt_user_last_updated.user_login AS last_updated_user_login
FROM (tt_user_mpg_sub_agreement LEFT JOIN tt_user AS tt_user_last_updated 
      ON tt_user_mpg_sub_agreement.umsa_last_updated_user_id = tt_user_last_updated.user_id
     )INNER JOIN tt_user
     ON tt_user_mpg_sub_agreement.umsa_user_id = tt_user.user_id
WHERE tt_user.user_id = ?
