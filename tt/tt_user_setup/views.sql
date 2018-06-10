DROP VIEW tt_view_accounts_and_their_users
go
CREATE VIEW tt_view_accounts_and_their_users AS
SELECT DISTINCT * FROM (
SELECT DISTINCT tt_user.user_login,
tt_user.user_id,
tt_user.user_group_id,
tt_customer_default.cusd_account_id AS account_id
from tt_user 
INNER JOIN tt_customer_default ON tt_user.user_id = tt_customer_default.cusd_user_id 

UNION

SELECT DISTINCT tt_user.user_login,
tt_user.user_id,
tt_user.user_group_id,
tt_account_default.acctd_account_id AS account_id
from tt_user 
INNER JOIN tt_account_default ON tt_user.user_id = tt_account_default.acctd_user_id

UNION

SELECT DISTINCT tt_user.user_login,
tt_user.user_id,
tt_user.user_group_id,
tt_account.acct_id AS account_id
from ( tt_user 
INNER JOIN ( ( tt_gmgt 
INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader ) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id ) ON tt_user.user_id = tt_user_gmgt.uxg_user_id ) 
INNER JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id

UNION

SELECT DISTINCT tt_user.user_login,
tt_user.user_id,
tt_user.user_group_id,
tt_user_account.uxa_account_id AS account_id
from tt_user 
INNER JOIN tt_user_account ON tt_user.user_id = tt_user_account.uxa_user_id
)

go

DROP VIEW tt_view_accts_associated_with_multiple_order_books
go
CREATE VIEW tt_view_accts_associated_with_multiple_order_books AS
SELECT tt_account.acct_name AS [Account #],
tt_user.user_login AS [Customer Default Username],
tt_company.comp_name AS [User Company],
tt_user.user_group_id,
tt_user_group.ugrp_comp_id,
tt_mgt.mgt_member AS Member,
tt_mgt.mgt_group AS [Group],
tt_mgt.mgt_trader AS Trader,
tt_gmgt_1.gm_member AS [Exch Member],
tt_gmgt_1.gm_group AS [Exch Group],
tt_gmgt_1.gm_trader AS [Exch Trader],
tt_gateway.gateway_name AS Gateway,
tt_company_1.comp_name AS [Gateway Login Company]
FROM ((tt_company 
INNER JOIN tt_user_group ON tt_company.comp_id = tt_user_group.ugrp_comp_id) 
INNER JOIN ((tt_user 
INNER JOIN (tt_account 
INNER JOIN tt_customer_default ON tt_account.acct_id = tt_customer_default.cusd_account_id) ON tt_user.user_id = tt_customer_default.cusd_user_id) 
INNER JOIN (tt_gateway 
INNER JOIN (tt_gmgt 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
INNER JOIN (tt_account AS tt_account_1 
INNER JOIN ((tt_company AS tt_company_1 
INNER JOIN tt_mgt ON tt_company_1.comp_id = tt_mgt.mgt_comp_id) 
INNER JOIN (tt_gmgt AS tt_gmgt_1 
INNER JOIN tt_mgt_gmgt ON tt_gmgt_1.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON tt_account_1.acct_mgt_id = tt_mgt.mgt_id) ON tt_account.acct_name_in_hex = tt_account_1.acct_name_in_hex
WHERE tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id 
AND tt_user.user_status = 1 
AND tt_user_gmgt.uxg_available_to_user = 1 
AND tt_mgt.mgt_type = 1
AND (tt_gmgt.gm_member <> tt_gmgt_1.gm_member or tt_gmgt.gm_group <> tt_gmgt_1.gm_group) 
go

DROP VIEW tt_view_broker_count
go
CREATE VIEW tt_view_broker_count AS
SELECT count(1) AS broker_cnt
FROM tt_company
WHERE comp_is_broker = 1;
go

DROP VIEW tt_view_users_with_ttords
go
CREATE VIEW tt_view_users_with_ttords AS
SELECT DISTINCT tt_user_gmgt.uxg_user_id
FROM tt_gmgt 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id=tt_user_gmgt.uxg_gmgt_id
WHERE left(tt_gmgt.gm_member,5)='TTORD' 
and tt_gmgt.gm_group <> 'XXX' 
and tt_gmgt.gm_trader <> 'MGR' 
and tt_gmgt.gm_trader <> 'VIEW' 
and uxg_available_to_user = 1;
go


DROP VIEW tt_view_users_with_direct_traders
go
CREATE VIEW tt_view_users_with_direct_traders AS
SELECT DISTINCT tt_user_gmgt.uxg_user_id
FROM tt_gmgt 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
WHERE Left([gm_member],5) <> 'TTORD' 
and Left([gm_member],5)<> 'TTADM' 
and uxg_available_to_user = 1;
go

DROP VIEW tt_view_users_with_ttords_and_no_direct_traders
go
CREATE VIEW tt_view_users_with_ttords_and_no_direct_traders AS
SELECT [tt_view_users_with_ttords].uxg_user_id
FROM tt_view_users_with_ttords 
LEFT JOIN tt_view_users_with_direct_traders ON [tt_view_users_with_ttords].uxg_user_id=[tt_view_users_with_direct_traders].uxg_user_id
WHERE [tt_view_users_with_direct_traders].uxg_user_id Is Null;
go

DROP VIEW tt_view_users_with_one_customer_default
go
CREATE VIEW tt_view_users_with_one_customer_default AS
SELECT cusd_user_id
FROM tt_customer_default
GROUP BY cusd_user_id
HAVING count(1) = 1;
go

DROP VIEW tt_view_users_with_only_default_customer_default
go
CREATE VIEW tt_view_users_with_only_default_customer_default AS
SELECT tt_customer_default.cusd_user_id
FROM tt_customer_default 
INNER JOIN tt_view_users_with_one_customer_default ON tt_customer_default.cusd_user_id = tt_view_users_with_one_customer_default.cusd_user_id
WHERE cusd_customer = '<DEFAULT>' 
and cusd_selected = 1 
and cusd_market_id = -1 
and cusd_product = '*' 
and cusd_product_type = '*' 
and cusd_account_id = 1 
and cusd_time_in_force = 'GTD' 
and cusd_order_type = 'Limit' 
and cusd_open_close = 'Open' 
and cusd_restriction = '<None>' 
and cusd_use_max_order_qty = 0 
and cusd_max_order_qty = 1 
and cusd_give_up = '' 
and cusd_fft2 = ''
and cusd_fft3 = '';
go

DROP VIEW tt_view_users_with_beyond_default_customer_default
go
CREATE VIEW tt_view_users_with_beyond_default_customer_default AS
SELECT tt_user.user_id
FROM tt_user 
LEFT JOIN tt_view_users_with_only_default_customer_default ON tt_user.user_id = tt_view_users_with_only_default_customer_default.cusd_user_id
WHERE cusd_user_id is null;
go


DROP VIEW tt_view_user_mgt_acct_combos
go
CREATE VIEW tt_view_user_mgt_acct_combos AS
SELECT DISTINCT tt_account.acct_name_in_hex,
tt_account.acct_name,
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader,
tt_user_gmgt.uxg_user_id,
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_group_id
FROM tt_user 
INNER JOIN ((tt_mgt 
INNER JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id) 
INNER JOIN (tt_gmgt 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)) ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE tt_user_gmgt.uxg_available_to_user = 1 
and tt_user.user_status = 1 
and tt_mgt.mgt_type = 1;
go

DROP VIEW tt_view_user_cusd_acct_combos
go
CREATE VIEW tt_view_user_cusd_acct_combos AS
SELECT DISTINCT tt_user.user_id,
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_group_id,
tt_account.acct_name_in_hex,
tt_account.acct_name
FROM tt_user 
INNER JOIN (tt_account 
INNER JOIN tt_customer_default ON tt_account.acct_id = tt_customer_default.cusd_account_id) ON tt_user.user_id = tt_customer_default.cusd_user_id
WHERE tt_customer_default.cusd_account_id <> 1 
and tt_user.user_status = 1;
go

DROP VIEW tt_view_cusd_accts_without_mgt_accts
go
CREATE VIEW tt_view_cusd_accts_without_mgt_accts AS
SELECT tt_view_user_cusd_acct_combos.tt_account.acct_name AS [Account #],
tt_view_user_cusd_acct_combos.tt_user.user_id,
tt_view_user_cusd_acct_combos.tt_user.user_group_id,
tt_view_user_cusd_acct_combos.tt_user.user_login AS Username,
tt_view_user_cusd_acct_combos.tt_user.user_display_name AS [Display Name]
FROM ((tt_view_users_with_ttords_and_no_direct_traders 
INNER JOIN tt_view_users_with_beyond_default_customer_default ON tt_view_users_with_ttords_and_no_direct_traders.uxg_user_id = tt_view_users_with_beyond_default_customer_default.user_id) 
INNER JOIN tt_view_user_cusd_acct_combos ON tt_view_users_with_beyond_default_customer_default.user_id = tt_view_user_cusd_acct_combos.user_id) 
LEFT JOIN tt_view_user_mgt_acct_combos ON (tt_view_user_cusd_acct_combos.acct_name_in_hex = tt_view_user_mgt_acct_combos.acct_name_in_hex) AND (tt_view_user_cusd_acct_combos.user_id = tt_view_user_mgt_acct_combos.uxg_user_id)
WHERE tt_view_user_mgt_acct_combos.uxg_user_id is null;
go

DROP VIEW tt_view_user_cusd_market_combos
go
CREATE VIEW tt_view_user_cusd_market_combos AS
SELECT DISTINCT tt_customer_default.cusd_market_id,
tt_customer_default.cusd_user_id
FROM tt_user 
INNER JOIN tt_customer_default ON tt_user.user_id = tt_customer_default.cusd_user_id
WHERE tt_customer_default.[cusd_market_id] <> -1 
and tt_user.user_status = 1;
go


DROP VIEW tt_view_user_mgt_market_combos
go
CREATE VIEW tt_view_user_mgt_market_combos AS
SELECT tt_user_gmgt.uxg_user_id,
tt_gateway.gateway_market_id
FROM tt_user 
INNER JOIN ((tt_gateway 
INNER JOIN tt_gmgt ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE tt_user_gmgt.uxg_available_to_user = 1 
and tt_user.user_status = 1;
go

DROP VIEW tt_view_cusd_markets_without_corresponding_mgt_markets
go
CREATE VIEW tt_view_cusd_markets_without_corresponding_mgt_markets AS
SELECT tt_user.user_id,
tt_user.user_login AS Username,
tt_user.user_display_name AS [Display Name],
tt_market.market_name AS Market,
tt_user_group.ugrp_comp_id,
tt_user_group.ugrp_group_id
FROM tt_user_group 
INNER JOIN (tt_market 
INNER JOIN (tt_user 
INNER JOIN (tt_view_user_cusd_market_combos 
LEFT JOIN tt_view_user_mgt_market_combos ON (tt_view_user_cusd_market_combos.cusd_user_id = tt_view_user_mgt_market_combos.uxg_user_id) 
AND (tt_view_user_cusd_market_combos.cusd_market_id = tt_view_user_mgt_market_combos.gateway_market_id)) ON tt_user.user_id = tt_view_user_cusd_market_combos.cusd_user_id) ON tt_market.market_id = tt_view_user_cusd_market_combos.cusd_market_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id
WHERE tt_view_user_mgt_market_combos.uxg_user_id Is Null;
go

DROP VIEW tt_view_default_customer_defaults
go
CREATE VIEW tt_view_default_customer_defaults AS
SELECT DISTINCT tt_customer_default.cusd_user_id,
tt_customer_default.cusd_comp_id
FROM tt_customer_default
WHERE tt_customer_default.cusd_customer = "<DEFAULT>";
go

DROP VIEW tt_view_fix_client_server_mgt_dependencies
go
CREATE VIEW tt_view_fix_client_server_mgt_dependencies AS
SELECT tt_user.user_id AS server_user_id,
tt_user.user_login AS server_user_login,
tt_user_1.user_id AS client_user_id,
tt_user_1.user_login AS client_user_login,
tt_gmgt.gm_id AS server_gm_id,
tt_gmgt.gm_gateway_id AS server_gm_gateway_id,
tt_gmgt.gm_member AS server_gm_member,
tt_gmgt.gm_group AS server_gm_group,
tt_gmgt.gm_trader AS server_gm_trader,
tt_mgt.mgt_id AS server_mgt_id,
tt_gmgt_1.gm_id AS client_gm_id,
tt_gmgt_1.gm_member AS client_gm_member,
tt_gmgt_1.gm_group AS client_gm_group,
tt_gmgt_1.gm_trader AS client_gm_trader,
tt_mgt_1.mgt_id AS client_mgt_id
FROM ((((tt_user_gmgt AS tt_user_gmgt_1 
INNER JOIN (tt_user 
INNER JOIN (tt_user AS tt_user_1 
INNER JOIN tt_user_user_relationship ON tt_user_1.user_id = tt_user_user_relationship.uur_user_id1) ON tt_user.user_id = tt_user_user_relationship.uur_user_id2) ON tt_user_gmgt_1.uxg_user_id = tt_user_1.user_id) 
INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_user_gmgt_1.uxg_gmgt_id = tt_gmgt_1.gm_id) 
INNER JOIN (tt_gmgt 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
INNER JOIN tt_mgt ON (tt_gmgt.gm_member = tt_mgt.mgt_member) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_trader = tt_mgt.mgt_trader)) 
INNER JOIN tt_mgt AS tt_mgt_1 ON (tt_gmgt_1.gm_member = tt_mgt_1.mgt_member) AND (tt_gmgt_1.gm_group = tt_mgt_1.mgt_group) AND (tt_gmgt_1.gm_trader = tt_mgt_1.mgt_trader)
WHERE tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id 
and tt_user.user_fix_adapter_role in (2,3) 
and tt_user_1.user_fix_adapter_role = 1 
and tt_user_user_relationship.uur_relationship_type = 'fix' 
and tt_user_gmgt.uxg_available_to_user = 1 
and tt_user_gmgt_1.uxg_available_to_fix_adapter_user = 1 
and tt_gmgt.gm_id <> tt_gmgt_1.gm_id;
go

DROP VIEW tt_view_fix_clients_and_their_mgts_and_servers
go
CREATE VIEW tt_view_fix_clients_and_their_mgts_and_servers AS
SELECT tt_user.user_id,
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_group_id,
tt_user.user_status,
tt_user_group.ugrp_comp_id,
tt_gmgt.gm_gateway_id,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
tt_gmgt_1.gm_member AS exch_member,
tt_gmgt_1.gm_group AS exch_group,
tt_gmgt_1.gm_trader AS exch_trader,
tt_user_1.user_id AS server_user_id,
tt_user_1.user_login AS server_user_login,
tt_user_1.user_display_name AS server_user_display_name,
tt_user_1.user_status
FROM tt_user_group 
INNER JOIN (tt_user AS tt_user_1 
INNER JOIN (((tt_gmgt 
INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)) 
INNER JOIN (tt_mgt_gmgt 
INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt_1.gm_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
INNER JOIN (tt_user 
INNER JOIN (tt_user_user_relationship 
INNER JOIN tt_user_gmgt ON tt_user_user_relationship.uur_user_id1 = tt_user_gmgt.uxg_user_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user_1.user_id = tt_user_user_relationship.uur_user_id2) ON tt_user_group.ugrp_group_id = tt_user.user_group_id
WHERE tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id 
and tt_user_gmgt.uxg_available_to_fix_adapter_user = 1;
go

DROP VIEW tt_view_fix_servers_and_their_mgts
go
CREATE VIEW tt_view_fix_servers_and_their_mgts AS
SELECT tt_user.user_id,
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_group_id,
tt_user.user_status,
tt_gmgt.gm_gateway_id,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader
FROM tt_gmgt 
INNER JOIN (tt_user 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
WHERE tt_user.user_fix_adapter_role in (2,3) 
and tt_user_gmgt.uxg_available_to_user = 1;
go

DROP VIEW tt_view_fix_clients_with_gateways_missing_from_server
go
CREATE VIEW tt_view_fix_clients_with_gateways_missing_from_server AS
SELECT tt_view_fix_clients_and_their_mgts_and_servers.tt_user.user_id,
tt_view_fix_clients_and_their_mgts_and_servers.tt_user.user_login AS [Client Username],
tt_view_fix_clients_and_their_mgts_and_servers.user_display_name AS [Client Display Name],
tt_view_fix_clients_and_their_mgts_and_servers.user_group_id,
tt_view_fix_clients_and_their_mgts_and_servers.ugrp_comp_id,
tt_gateway.gateway_name AS Gateway,
tt_view_fix_clients_and_their_mgts_and_servers.server_user_login AS [Server Username],
tt_view_fix_clients_and_their_mgts_and_servers.server_user_display_name AS [Server Display Name]
FROM tt_gateway 
INNER JOIN (tt_view_fix_clients_and_their_mgts_and_servers 
LEFT JOIN tt_view_fix_servers_and_their_mgts 
ON (tt_view_fix_clients_and_their_mgts_and_servers.gm_gateway_id = tt_view_fix_servers_and_their_mgts.gm_gateway_id) 
AND (tt_view_fix_clients_and_their_mgts_and_servers.server_user_id = tt_view_fix_servers_and_their_mgts.user_id)) 
ON tt_gateway.gateway_id = tt_view_fix_clients_and_their_mgts_and_servers.gm_gateway_id
WHERE tt_view_fix_servers_and_their_mgts.gm_gateway_id Is Null 
and tt_view_fix_clients_and_their_mgts_and_servers.tt_user.user_status = 1;
go

DROP VIEW tt_view_fix_clients_with_orderbooks_server_cant_see
go
CREATE VIEW tt_view_fix_clients_with_orderbooks_server_cant_see AS

SELECT * FROM

(SELECT tt_user.user_id,
tt_user.user_login AS [Client Username],
tt_user.user_display_name AS [Client Display Name],
tt_user.user_group_id,
tt_user_group.ugrp_comp_id,
tt_gmgt.gm_member AS [Client Member],
tt_gmgt.gm_group AS [Client Group],
tt_gmgt.gm_trader AS [Client Trader],
tt_gateway.gateway_name AS Gateway,
tt_user_1.user_login AS [Server Username],
tt_user_1.user_display_name AS [Server Display Name],
tt_gmgt_1.gm_member AS [Server Member],
tt_gmgt_1.gm_group AS [Server Group],
tt_gmgt_1.gm_trader AS [Server Trader]
FROM tt_gateway 
INNER JOIN ((tt_user_gmgt AS tt_user_gmgt_1 
INNER JOIN ((tt_gmgt 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
INNER JOIN ((tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
INNER JOIN (tt_user AS tt_user_1 
INNER JOIN tt_user_user_relationship ON tt_user_1.user_id = tt_user_user_relationship.uur_user_id2) ON tt_user.user_id = tt_user_user_relationship.uur_user_id1) ON tt_user_gmgt.uxg_user_id = tt_user.user_id) ON tt_user_gmgt_1.uxg_user_id = tt_user_1.user_id) 
INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_user_gmgt_1.uxg_gmgt_id = tt_gmgt_1.gm_id) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id
WHERE tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id
and tt_user.user_status = 1
and tt_user_1.user_status = 1
and tt_user_gmgt.uxg_available_to_fix_adapter_user = 1
and tt_user_gmgt_1.uxg_available_to_user = 1
and tt_user_1.user_fix_adapter_role in (2,3)
and (
(tt_gmgt.gm_member <> tt_gmgt_1.gm_member and tt_gmgt_1.gm_member <> 'TTADM') 
or 
(tt_gmgt.gm_group <> tt_gmgt_1.gm_group and tt_gmgt_1.gm_group <> 'XXX'))

UNION

SELECT tt_user.user_id,
tt_user.user_login AS [Client Username],
tt_user.user_display_name AS [Client Display Name],
tt_user.user_group_id,
tt_user_group.ugrp_comp_id,
tt_gmgt.gm_member AS [Client Member],
tt_gmgt.gm_group AS [Client Group],
tt_gmgt.gm_trader AS [Client Trader],
tt_gateway.gateway_name AS Gateway,
tt_user_1.user_login AS [Server Username],
tt_user_1.user_display_name AS [Server Display Name],
'' AS [Server Member],
'' AS [Server Group],
'' AS [Server Trader]
FROM (tt_user_group INNER JOIN (tt_gateway INNER JOIN ((tt_gmgt INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id) INNER JOIN (tt_user AS tt_user_1 INNER JOIN tt_user_user_relationship ON tt_user_1.user_id = tt_user_user_relationship.uur_user_id2) ON tt_user.user_id = tt_user_user_relationship.uur_user_id1
WHERE tt_user.user_status = 1
and tt_user_gmgt.uxg_available_to_fix_adapter_user = 1
and tt_user_1.user_fix_adapter_role in (2,4)
and (tt_gmgt.gm_member = 'TTADM' or tt_gmgt.gm_group = 'XXX' or left(tt_gmgt.gm_trader,3) = 'MGR' or left(tt_gmgt.gm_trader,4) = 'VIEW')
)
go

DROP VIEW tt_view_get_recently_used_client_versions_for_gmfc
go
CREATE VIEW tt_view_get_recently_used_client_versions_for_gmfc AS
SELECT tt_ip_address_version.ipv_tt_product_name,
tt_ip_address_version.ipv_user_login,
tt_ip_address_version.ipv_ip_address,
tt_ip_address_version.ipv_lang_id,
Max(tt_ip_address_version.ipv_last_updated_datetime) AS last_seen_datetime
FROM tt_ip_address_version
WHERE ipv_gateway_id = 0 AND ipv_last_updated_datetime >DateAdd("d",-30,Now)
GROUP BY tt_ip_address_version.ipv_tt_product_name,
tt_ip_address_version.ipv_user_login,
tt_ip_address_version.ipv_ip_address,
tt_ip_address_version.ipv_lang_id;
go

DROP VIEW tt_view_get_recently_used_server_versions_for_gmfc
go
CREATE VIEW tt_view_get_recently_used_server_versions_for_gmfc AS
SELECT tt_ip_address_version.ipv_tt_product_name,
tt_ip_address_version.ipv_gateway_id,
tt_ip_address_version.ipv_ip_address,
tt_ip_address_version.ipv_lang_id,
MAX(tt_ip_address_version.ipv_last_updated_datetime) AS last_seen_datetime
FROM tt_ip_address_version
WHERE ipv_gateway_id <> 0 AND ipv_last_updated_datetime >DateAdd("d",-30,Now)
GROUP BY tt_ip_address_version.ipv_tt_product_name,
tt_ip_address_version.ipv_gateway_id,
tt_ip_address_version.ipv_ip_address,
tt_ip_address_version.ipv_lang_id;
go


DROP VIEW tt_view_get_report_accts_cusd
go
CREATE VIEW tt_view_get_report_accts_cusd AS
SELECT DISTINCT tt_user.user_id,
tt_account.acct_name,
tt_account.acct_comp_id
FROM tt_account 
INNER JOIN (tt_user 
INNER JOIN tt_customer_default ON (tt_user.user_id = tt_customer_default.cusd_user_id) AND (tt_customer_default.cusd_user_id = tt_user.user_id)) ON tt_account.acct_id = tt_customer_default.cusd_account_id
WHERE tt_customer_default.cusd_account_id > 1;
go

DROP VIEW tt_view_get_report_accts_mgt
go
CREATE VIEW tt_view_get_report_accts_mgt AS
SELECT DISTINCT tt_user.user_id,
tt_account.acct_name,
tt_mgt.mgt_comp_id
FROM tt_account 
INNER JOIN (tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN (tt_user 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)) ON tt_account.acct_mgt_id = tt_mgt.mgt_id;
go

DROP VIEW tt_view_get_report_accts_all
go
CREATE VIEW tt_view_get_report_accts_all AS
SELECT * FROM (
SELECT *
from tt_view_get_report_accts_cusd 

union 

SELECT *
from tt_view_get_report_accts_mgt
) 
go

DROP VIEW tt_view_gmgts_missing_passwords
go
CREATE VIEW tt_view_gmgts_missing_passwords AS
SELECT tt_mgt.mgt_id,
tt_mgt.mgt_comp_id,
tt_gateway.gateway_name AS Gateway,
tt_gmgt.gm_member AS Member,
tt_gmgt.gm_group AS [Group],
tt_gmgt.gm_trader AS Trader,
tt_market.market_name,
tt_mgt.mgt_password
FROM tt_mgt 
INNER JOIN (tt_market 
INNER JOIN (tt_gateway 
INNER JOIN tt_gmgt ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) ON tt_market.market_id = tt_gateway.gateway_market_id) ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)
WHERE (
tt_market.market_id = 2 	
or tt_market.market_id = 1 	
or tt_market.market_id = 10
or tt_market.market_id = 11 
or tt_market.market_id = 32
or (tt_market.market_id = 6 and tt_gateway.gateway_name like '%ecbot%')
or (tt_market.market_id = 3 and tt_gateway.gateway_name like 'liffe%') ) 
or tt_market.market_id = 98
and mgt_type = 0
and tt_mgt.mgt_member <> '<No'
and tt_mgt.mgt_password = '';
go

DROP VIEW tt_view_max_ipv_date
go
CREATE VIEW tt_view_max_ipv_date AS
SELECT tt_ip_address_version.ipv_user_login,
Max(tt_ip_address_version.ipv_last_updated_datetime) AS ipv_last_datetime
FROM tt_ip_address_version
WHERE (((tt_ip_address_version.ipv_user_login)<>''))
GROUP BY tt_ip_address_version.ipv_user_login;
go

DROP VIEW tt_view_max_ipv_date2
go
CREATE VIEW tt_view_max_ipv_date2 AS
SELECT tt_ip_address_version.*,
IIf(tt_view_max_ipv_date.ipv_user_login Is Not Null,'Y','') AS [User's Most Recent Version Record]
FROM tt_ip_address_version 
LEFT JOIN tt_view_max_ipv_date ON (tt_ip_address_version.ipv_user_login=tt_view_max_ipv_date.ipv_user_login) AND (tt_ip_address_version.ipv_last_updated_datetime = tt_view_max_ipv_date.ipv_last_datetime)
WHERE tt_ip_address_version.ipv_gateway_id = 0;
go

-- ' for syntax coloring Notepad++

DROP VIEW tt_view_max_x_trader_user_date
go
CREATE VIEW tt_view_max_x_trader_user_date AS
SELECT tt_ip_address_version.ipv_user_login,
Max(tt_ip_address_version.ipv_last_updated_datetime) AS ipv_last_datetime
FROM tt_ip_address_version
WHERE tt_ip_address_version.ipv_user_login <> '' 
and tt_ip_address_version.ipv_tt_product_id in (8,30) 
and tt_ip_address_version.ipv_gateway_id = 0
GROUP BY tt_ip_address_version.ipv_user_login;
go

DROP VIEW tt_view_max_x_trader_user_date2
go
CREATE VIEW tt_view_max_x_trader_user_date2 AS
SELECT tt_view_max_x_trader_user_date.ipv_user_login,
tt_view_max_x_trader_user_date.ipv_last_datetime,
tt_ip_address_version.ipv_ip_address,
tt_ip_address_version.ipv_version,
tt_ip_address_version.ipv_lang_id
FROM tt_view_max_x_trader_user_date 
INNER JOIN tt_ip_address_version ON (tt_view_max_x_trader_user_date.ipv_user_login = tt_ip_address_version.ipv_user_login) AND (tt_view_max_x_trader_user_date.ipv_last_datetime = tt_ip_address_version.ipv_last_updated_datetime)
GROUP BY tt_view_max_x_trader_user_date.ipv_user_login,
tt_view_max_x_trader_user_date.ipv_last_datetime,
tt_ip_address_version.ipv_ip_address,
tt_ip_address_version.ipv_version,
tt_ip_address_version.ipv_lang_id;
go

DROP VIEW tt_view_mg_combos_with_mismatched_credit
go
CREATE VIEW tt_view_mg_combos_with_mismatched_credit AS
SELECT tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_comp_id,
Max(tt_mgt.mgt_credit) AS [highest credit],
Min(tt_mgt.mgt_credit) AS [lowest credit]
FROM tt_mgt
WHERE tt_mgt.mgt_publish_to_guardian = 1 
and tt_mgt.mgt_risk_on = 1 
and tt_mgt.mgt_type <> 2
GROUP BY tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_comp_id
HAVING MAX(tt_mgt.mgt_credit) <> MIN(tt_mgt.mgt_credit) or MAX(tt_mgt.mgt_currency) <> MIN(tt_mgt.mgt_currency);
go

DROP VIEW tt_view_mg_combos_with_mismatched_credit_ex
go
CREATE VIEW tt_view_mg_combos_with_mismatched_credit_ex AS
SELECT tt_mgt.mgt_member AS Member,
tt_mgt.mgt_group AS [Group],
tt_mgt.mgt_trader AS Trader,
tt_mgt.mgt_currency AS [Currency],
tt_mgt.mgt_credit AS Credit,
tt_mgt.mgt_comp_id AS mgt_comp_id
FROM tt_mgt 
INNER JOIN tt_view_mg_combos_with_mismatched_credit ON (tt_view_mg_combos_with_mismatched_credit.mgt_group = tt_mgt.mgt_group) AND (tt_view_mg_combos_with_mismatched_credit.mgt_member = tt_mgt.mgt_member);
go

DROP VIEW tt_view_mg_combos_with_mismatched_max_position
go
CREATE VIEW tt_view_mg_combos_with_mismatched_max_position AS
SELECT tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_comp_id,
tt_gateway.gateway_name,
tt_product_type.product_description,
tt_product_limit.plim_product,
Max(tt_product_limit.plim_max_position) AS [highest max position],
Min(tt_product_limit.plim_max_position) AS [lowest max position],
Max(IIF(tt_product_type.should_ignore_max_long_short,
'',
tt_product_limit.plim_max_long_short)) AS [highest max long short],
Min(IIF(tt_product_type.should_ignore_max_long_short,
'',
tt_product_limit.plim_max_long_short)) AS [lowest max long short]
FROM (tt_gateway 
INNER JOIN (tt_mgt 
INNER JOIN tt_product_limit ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id) ON tt_gateway.gateway_id = tt_product_limit.plim_gateway_id) 
INNER JOIN tt_product_type ON tt_product_limit.plim_product_type = tt_product_type.product_id
WHERE tt_mgt.mgt_publish_to_guardian = 1 
and tt_product_limit.plim_for_simulation = 0 
and tt_mgt.mgt_risk_on = 1 
and tt_mgt.mgt_type <> 2
GROUP BY tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_comp_id,
tt_gateway.gateway_name,
tt_product_type.product_description,
tt_product_type.should_ignore_max_long_short,
tt_product_limit.plim_product
HAVING MAX(tt_product_limit.plim_max_position) <> MIN(tt_product_limit.plim_max_position) OR (tt_product_type.should_ignore_max_long_short = 0 AND MAX(tt_product_limit.plim_max_long_short) <> MIN(tt_product_limit.plim_max_long_short));
go

DROP VIEW tt_view_mg_exch_mg_gateway_combos
go
CREATE VIEW tt_view_mg_exch_mg_gateway_combos AS
SELECT DISTINCT tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_gateway_id,
tt_mgt.mgt_comp_id
FROM tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
WHERE tt_mgt.mgt_type <> 2
go

DROP VIEW tt_view_mgt_accts_without_cusd_accts
go
CREATE VIEW tt_view_mgt_accts_without_cusd_accts AS
SELECT tt_view_user_mgt_acct_combos.tt_account.acct_name AS [Account #],
tt_view_user_mgt_acct_combos.tt_mgt.mgt_member AS Member,
tt_view_user_mgt_acct_combos.tt_mgt.mgt_group AS [Group],
tt_view_user_mgt_acct_combos.tt_mgt.mgt_trader AS Trader,
tt_view_user_mgt_acct_combos.tt_user_gmgt.uxg_user_id,
tt_view_user_mgt_acct_combos.tt_user.user_group_id,
tt_view_user_mgt_acct_combos.tt_user.user_login AS Username,
tt_view_user_mgt_acct_combos.tt_user.user_display_name AS [Display Name]
FROM (tt_view_users_with_beyond_default_customer_default 
INNER JOIN tt_view_user_mgt_acct_combos ON tt_view_users_with_beyond_default_customer_default.user_id = tt_view_user_mgt_acct_combos.uxg_user_id) 
LEFT JOIN tt_view_user_cusd_acct_combos ON (tt_view_user_mgt_acct_combos.uxg_user_id = tt_view_user_cusd_acct_combos.user_id) AND (tt_view_user_mgt_acct_combos.acct_name_in_hex = tt_view_user_cusd_acct_combos.acct_name_in_hex)
WHERE tt_view_user_cusd_acct_combos.user_id is null;
go


DROP VIEW tt_view_users_and_their_assigned_mgts
go
CREATE VIEW tt_view_users_and_their_assigned_mgts AS
SELECT tt_user.*,
tt_user_gmgt.*,
tt_mgt.*
FROM ((tt_user 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id) 
INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member);
go

DROP VIEW tt_view_users_and_their_assigned_mgts_without_user_gmgts
go
CREATE VIEW tt_view_users_and_their_assigned_mgts_without_user_gmgts AS
SELECT
    tt_user.user_login,
    tt_user.user_display_name,
    tt_user.user_status,
    tt_user.user_group_id,
    tt_mgt.mgt_member,
    tt_mgt.mgt_group,
    tt_mgt.mgt_trader,
    tt_mgt.mgt_id
FROM (( tt_user
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_mgt ON (tt_gmgt.gm_member = tt_mgt.mgt_member) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_trader = tt_mgt.mgt_trader)
GROUP BY
    tt_user.user_login,
    tt_user.user_display_name,
    tt_user.user_status,
    tt_user.user_group_id,
    tt_mgt.mgt_member,
    tt_mgt.mgt_group,
    tt_mgt.mgt_trader,
    tt_mgt.mgt_id
go

DROP VIEW tt_view_mgt_group_permission_partial
go
CREATE VIEW tt_view_mgt_group_permission_partial AS
SELECT DISTINCT *
FROM (
select distinct 0 as type,
-99 as source_id,
mgp_id as id,
mgp_mgt_id,
mgp_group_id
from tt_mgt_group_permission
 
union 

select distinct 2 as type,
tt_user.user_id as source_id,
-99 as id,
tt_mgt.mgt_id as mgp_mgt_id,
tt_user.user_group_id as mgp_group_id
from tt_view_users_and_their_assigned_mgts ) 
go


DROP VIEW tt_view_proxy_mgts_and_their_assigned_exchange_mgts
go
CREATE VIEW tt_view_proxy_mgts_and_their_assigned_exchange_mgts AS
SELECT proxy_mgts.mgt_id AS proxy_mgt_id,
exchange_mgts.mgt_id AS exchange_mgt_id
FROM ((tt_mgt AS proxy_mgts 
INNER JOIN tt_mgt_gmgt ON proxy_mgts.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
INNER JOIN tt_gmgt ON tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt.gm_id) 
INNER JOIN tt_mgt AS exchange_mgts ON (tt_gmgt.gm_trader = exchange_mgts.mgt_trader) AND (tt_gmgt.gm_group = exchange_mgts.mgt_group) AND (tt_gmgt.gm_member = exchange_mgts.mgt_member)
WHERE proxy_mgts.mgt_type = 1
go

DROP VIEW tt_view_mgt_group_permission_all_verbose
go
CREATE VIEW tt_view_mgt_group_permission_all_verbose AS
SELECT DISTINCT * FROM (
select *
from tt_view_mgt_group_permission_partial 

union 

select distinct 1 as type,
t1.proxy_mgt_id as source_id,
-99 as id,
t1.exchange_mgt_id as mgp_mgt_id,
t2.mgp_group_id as mgp_group_id
from tt_view_proxy_mgts_and_their_assigned_exchange_mgts as t1 
INNER JOIN tt_view_mgt_group_permission_partial as t2 on t1.proxy_mgt_id = t2.mgp_mgt_id ) 
go

DROP VIEW tt_view_mgt_group_permission_all
go
CREATE VIEW tt_view_mgt_group_permission_all AS
SELECT MAX(id) AS mgp_id,
mgp_mgt_id,
mgp_group_id
FROM tt_view_mgt_group_permission_all_verbose
GROUP BY mgp_mgt_id,
mgp_group_id;
go

DROP VIEW tt_view_account_group_permission_all_verbose
go
CREATE VIEW tt_view_account_group_permission_all_verbose AS
SELECT DISTINCT *
FROM (
select distinct 0 as type,
-99 as source_id,
agp_id as id,
agp_account_id,
agp_group_id
from tt_account_group_permission

union 

select distinct 2 as type,
tt_user.user_id as source_id,
-99 as id,
tt_customer_default.cusd_account_id as agp_account_id,
tt_user.user_group_id as agp_group_id
from tt_customer_default 
INNER JOIN tt_user on tt_customer_default.cusd_user_id = tt_user.user_id

union

select distinct 2 as type,
tt_user.user_id as source_id,
-99 as id,
tt_account_default.acctd_account_id as agp_account_id,
tt_user.user_group_id as agp_group_id
from tt_account_default 
INNER JOIN tt_user on tt_account_default.acctd_user_id = tt_user.user_id

union

select distinct 2 as type, 
tt_user.user_id as source_id, 
-99 as id, 
tt_user_account.uxa_account_id as agp_account_id, 
tt_user.user_group_id as agp_group_id
from tt_user_account
INNER JOIN tt_user on tt_user_account.uxa_user_id = tt_user.user_id 

union

select distinct 1 as type,
tt_account.acct_mgt_id as source_id,
-99 as id,
tt_account.acct_id as agp_account_id,
tt_mgt_group_permission.mgp_group_id as agp_group_id
from tt_account 
INNER JOIN tt_view_mgt_group_permission_all on tt_account.acct_mgt_id = tt_view_mgt_group_permission_all.mgp_mgt_id ) 
go

DROP VIEW tt_view_account_group_permission_all
go
CREATE VIEW tt_view_account_group_permission_all AS
SELECT MAX(id) AS agp_id,
agp_account_id,
agp_group_id
FROM tt_view_account_group_permission_all_verbose
GROUP BY agp_account_id,
agp_group_id;
go


DROP VIEW tt_view_mgts_and_mxgs
go
CREATE VIEW tt_view_mgts_and_mxgs AS
SELECT tt_mgt.*,
tt_mgt_gmgt.*
FROM tt_mgt_gmgt RIGHT JOIN tt_mgt ON tt_mgt_gmgt.mxg_mgt_id = tt_mgt.mgt_id;
go

DROP VIEW tt_view_mgts_mapped_to_missing_gmgts
go
CREATE VIEW tt_view_mgts_mapped_to_missing_gmgts AS
SELECT tt_mgt.mgt_member AS Member,
tt_mgt.mgt_group AS [Group],
tt_mgt.mgt_trader AS Trader,
tt_gateway.gateway_name AS Gateway,
tt_mgt.mgt_id,
tt_mgt.mgt_comp_id
FROM tt_gateway 
INNER JOIN (tt_gmgt 
INNER JOIN (tt_mgt 
INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id
WHERE tt_mgt.mgt_type = 1
and tt_gmgt.gm_member = '<No';
go

DROP VIEW tt_view_mgts_with_passwords_for_revision_info
go
CREATE VIEW tt_view_mgts_with_passwords_for_revision_info AS
SELECT DISTINCT tt_gmgt.gm_gateway_id,
tt_mgt_1.mgt_member AS exch_member,
tt_mgt_1.mgt_group AS exch_group,
tt_mgt_1.mgt_trader AS exch_trader,
tt_mgt_1.mgt_last_updated_datetime AS last_updated_datetime
FROM (tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
INNER JOIN tt_mgt AS tt_mgt_1 ON (tt_gmgt.gm_member = tt_mgt_1.mgt_member) AND (tt_gmgt.gm_group = tt_mgt_1.mgt_group) AND (tt_gmgt.gm_trader = tt_mgt_1.mgt_trader)
WHERE tt_mgt.mgt_password <> '';
go


DROP VIEW tt_view_user_member_group_gateway_counts
go
CREATE VIEW tt_view_user_member_group_gateway_counts AS
SELECT tt_user_gmgt.uxg_user_id,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_mgt.mgt_comp_id,
Count(1) AS cnt
FROM tt_user 
INNER JOIN ((tt_gmgt 
INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE (tt_user_gmgt.uxg_available_to_user=1 
or (tt_user.user_fix_adapter_role = 1 
AND tt_user_gmgt.uxg_available_to_fix_adapter_user=1 )) 
AND tt_mgt.mgt_publish_to_guardian=1 
AND tt_user.user_status=1 
AND tt_mgt.mgt_type <> 2
GROUP BY tt_user_gmgt.uxg_user_id,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_mgt.mgt_comp_id;
go

DROP VIEW tt_view_mgts_with_same_mg_mismatched_gateways
go
CREATE VIEW tt_view_mgts_with_same_mg_mismatched_gateways AS
SELECT tt_view_user_member_group_gateway_counts.gm_member AS Member,
tt_view_user_member_group_gateway_counts.gm_group AS [Group],
tt_view_user_member_group_gateway_counts.mgt_comp_id,
min(tt_view_user_member_group_gateway_counts.cnt),
max(tt_view_user_member_group_gateway_counts.cnt)
FROM tt_view_user_member_group_gateway_counts
GROUP BY tt_view_user_member_group_gateway_counts.gm_member,
tt_view_user_member_group_gateway_counts.gm_group,
tt_view_user_member_group_gateway_counts.mgt_comp_id
HAVING min(tt_view_user_member_group_gateway_counts.cnt) <> max(tt_view_user_member_group_gateway_counts.cnt);
go

DROP VIEW tt_view_mgts_without_accounts
go
CREATE VIEW tt_view_mgts_without_accounts AS
SELECT tt_mgt.mgt_member AS Member,
tt_mgt.mgt_group AS [Group],
tt_mgt.mgt_trader AS Trader,
tt_mgt.mgt_risk_on AS [Risk Check],
tt_mgt.mgt_allow_trading AS [Allow Trading],
tt_mgt.mgt_id,
tt_mgt.mgt_comp_id
FROM tt_mgt 
LEFT JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id
WHERE tt_mgt.mgt_id <> 0 
and tt_account.acct_id is null 
and tt_mgt.mgt_publish_to_guardian = 1;
go

DROP VIEW tt_view_mgts_without_accounts2
go
CREATE VIEW tt_view_mgts_without_accounts2 AS
SELECT tt_mgt.mgt_member AS Member,
tt_mgt.mgt_group AS [Group],
tt_mgt.mgt_trader AS Trader,
tt_mgt.mgt_risk_on AS [Risk Check],
tt_mgt.mgt_allow_trading AS [Allow Trading],
tt_mgt.mgt_id,
tt_mgt.mgt_comp_id
FROM tt_mgt 
LEFT JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id
WHERE tt_mgt.mgt_id <> 0 
and tt_account.acct_id is null 
and tt_mgt.mgt_type = 1;
go

DROP VIEW tt_view_missing_uxgs_users_with_mgts
go
CREATE VIEW tt_view_missing_uxgs_users_with_mgts AS
SELECT DISTINCT tt_mgt.mgt_id,
tt_user_gmgt.uxg_user_id
FROM (tt_mgt 
INNER JOIN tt_gmgt ON (tt_mgt.mgt_trader=tt_gmgt.gm_trader) AND (tt_mgt.mgt_group=tt_gmgt.gm_group) AND (tt_mgt.mgt_member=tt_gmgt.gm_member)) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id=tt_user_gmgt.uxg_gmgt_id
WHERE tt_mgt.mgt_type = 1
go

DROP VIEW tt_view_missing_uxgs_what_users_have
go
CREATE VIEW tt_view_missing_uxgs_what_users_have AS
SELECT tt_mgt.mgt_id,
tt_user_gmgt.uxg_user_id,
tt_gmgt.gm_gateway_id
FROM (tt_mgt 
INNER JOIN tt_gmgt ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
--WHERE tt_mgt.mgt_type = 1 treat all mgts the same
go

DROP VIEW tt_view_missing_uxgs_what_users_should_have
go
CREATE VIEW tt_view_missing_uxgs_what_users_should_have AS
SELECT tt_mgt.mgt_id,
tt_view_missing_uxgs_users_with_mgts.uxg_user_id,
tt_gmgt_1.gm_id,
tt_gmgt_1.gm_gateway_id
FROM (tt_mgt 
INNER JOIN tt_view_missing_uxgs_users_with_mgts ON tt_mgt.mgt_id=tt_view_missing_uxgs_users_with_mgts.mgt_id) 
INNER JOIN tt_gmgt AS tt_gmgt_1 ON (tt_mgt.mgt_member=tt_gmgt_1.gm_member) AND (tt_mgt.mgt_group=tt_gmgt_1.gm_group) AND (tt_mgt.mgt_trader=tt_gmgt_1.gm_trader);
go


DROP VIEW tt_view_ttords_and_their_gateways
go
CREATE VIEW tt_view_ttords_and_their_gateways AS
SELECT tt_mgt.*,
tt_mgt_gmgt.*,
tt_gmgt.*,
tt_gateway.*,
tt_market.*
FROM tt_market 
INNER JOIN (tt_gateway 
INNER JOIN (tt_gmgt 
INNER JOIN (tt_mgt 
INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) ON tt_market.market_id = tt_gateway.gateway_market_id;
go

DROP VIEW tt_view_product_limits_and_mgts
go
CREATE VIEW tt_view_product_limits_and_mgts AS
SELECT *
FROM tt_gateway 
INNER JOIN (tt_mgt 
INNER JOIN tt_product_limit ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id) ON tt_gateway.gateway_id = tt_product_limit.plim_gateway_id;
go

DROP VIEW tt_view_mxgs_without_corresponding_product_limits
go
CREATE VIEW tt_view_mxgs_without_corresponding_product_limits AS
SELECT tt_view_ttords_and_their_gateways.mgt_member AS Member,
tt_view_ttords_and_their_gateways.mgt_group AS [Group],
tt_view_ttords_and_their_gateways.mgt_trader AS Trader,
tt_view_ttords_and_their_gateways.mgt_risk_on AS [Risk Check],
tt_view_ttords_and_their_gateways.mgt_allow_trading AS [Allow Trading],
tt_view_ttords_and_their_gateways.gateway_name AS Gateway,
tt_view_ttords_and_their_gateways.mgt_id,
tt_view_ttords_and_their_gateways.mgt_comp_id
FROM tt_view_ttords_and_their_gateways 
LEFT JOIN tt_view_product_limits_and_mgts ON (tt_view_ttords_and_their_gateways.gm_gateway_id = tt_view_product_limits_and_mgts.gateway_id) AND (tt_view_ttords_and_their_gateways.mgt_id = tt_view_product_limits_and_mgts.mgt_id)
WHERE tt_view_product_limits_and_mgts.plim_product_limit_id is null 
and tt_view_ttords_and_their_gateways.mgt_publish_to_guardian = 1 
and tt_view_ttords_and_their_gateways.mgt_risk_on = 1 
and tt_view_ttords_and_their_gateways.mgt_type <> 2 
AND tt_view_ttords_and_their_gateways.gateway_market_id not in (84,85,88);
go

DROP VIEW tt_view_No_MGT_Records
go
CREATE VIEW tt_view_No_MGT_Records AS
SELECT tt_gmgt.gm_id,
tt_gmgt.gm_gateway_id
FROM tt_gmgt
WHERE gm_member='<No' And gm_trader='Record>';
go

DROP VIEW tt_view_oldest_default_date_per_user
go
CREATE VIEW tt_view_oldest_default_date_per_user AS
SELECT cusd_user_id,
cusd_customer,
MIN(cusd_created_datetime) AS oldest_date
FROM tt_customer_default
WHERE cusd_customer = '<DEFAULT>'
GROUP BY tt_customer_default.cusd_user_id,
cusd_customer;
go

DROP VIEW tt_view_oldest_default_per_user
go
CREATE VIEW tt_view_oldest_default_per_user AS
SELECT MIN(b.cusd_id) AS oldest_default_per_user_cusd_id
FROM tt_view_oldest_default_date_per_user AS a 
INNER JOIN tt_customer_default AS b ON (a.oldest_date = b.cusd_created_datetime) AND (a.cusd_user_id = b.cusd_user_id)
GROUP BY b.cusd_user_id;
go


DROP VIEW tt_view_routing_keys_for_revision_info
go
CREATE VIEW tt_view_routing_keys_for_revision_info AS
SELECT * FROM (
SELECT str(tt_mgt.mgt_id) + ',' as routing_key,
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader,
tt_gmgt.gm_gateway_id,
tt_gmgt.gm_member as exch_member,
tt_gmgt.gm_group as exch_group,
tt_gmgt.gm_trader as exch_trader,
tt_mgt_gmgt.mxg_last_updated_datetime as last_updated_datetime
from tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
where tt_mgt.mgt_type = 1

union 

SELECT tt_account.acct_name,
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader,
tt_gmgt.gm_gateway_id,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
tt_account.acct_last_updated_datetime as last_updated_datetime
from tt_gmgt 
INNER JOIN ((tt_mgt 
INNER JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id) 
INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id
where tt_mgt.mgt_type = 1)
go

DROP VIEW tt_view_same_mg_diff_exch_mg
go
CREATE VIEW tt_view_same_mg_diff_exch_mg AS
SELECT tt_view_mg_exch_mg_gateway_combos.mgt_member,
tt_view_mg_exch_mg_gateway_combos.mgt_group,
tt_view_mg_exch_mg_gateway_combos.gm_gateway_id,
tt_view_mg_exch_mg_gateway_combos.mgt_comp_id
FROM tt_view_mg_exch_mg_gateway_combos
GROUP BY tt_view_mg_exch_mg_gateway_combos.mgt_member,
tt_view_mg_exch_mg_gateway_combos.mgt_group,
tt_view_mg_exch_mg_gateway_combos.gm_gateway_id,
tt_view_mg_exch_mg_gateway_combos.mgt_comp_id
HAVING count(1) > 1;
go

DROP VIEW tt_view_same_mg_diff_exch_mg2
go
CREATE VIEW tt_view_same_mg_diff_exch_mg2 AS
SELECT tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_view_same_mg_diff_exch_mg.gm_gateway_id,
tt_mgt.mgt_member,
tt_mgt.mgt_group
FROM (tt_gmgt 
INNER JOIN (tt_mgt 
INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) 
INNER JOIN tt_view_same_mg_diff_exch_mg ON (tt_mgt.mgt_member = tt_view_same_mg_diff_exch_mg.mgt_member) AND (tt_mgt.mgt_group = tt_view_same_mg_diff_exch_mg.mgt_group)
WHERE tt_mgt.mgt_type <> 2
go

DROP VIEW tt_view_same_mg_diff_exch_mg3
go
CREATE VIEW tt_view_same_mg_diff_exch_mg3 AS
SELECT tt_user.user_id,
tt_user.user_group_id,
tt_user.user_login AS Username,
tt_user.user_display_name AS [Display Name],
tt_gateway.gateway_name AS Gateway,
tt_gmgt.gm_member AS [Direct Trader Member],
tt_gmgt.gm_group AS [Direct Trader Group],
tt_view_same_mg_diff_exch_mg2.mgt_member AS [TTORD Member],
tt_view_same_mg_diff_exch_mg2.mgt_group AS [TTORD Group]
FROM tt_gateway 
INNER JOIN ((tt_gmgt 
INNER JOIN (tt_user 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
INNER JOIN tt_view_same_mg_diff_exch_mg2 ON (tt_gmgt.gm_gateway_id = tt_view_same_mg_diff_exch_mg2.gm_gateway_id) AND (tt_gmgt.gm_member = tt_view_same_mg_diff_exch_mg2.gm_member) AND (tt_gmgt.gm_group = tt_view_same_mg_diff_exch_mg2.gm_group)) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id
WHERE tt_user_gmgt.uxg_available_to_user = 1 or (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1);
go

DROP VIEW tt_view_users_and_their_gateways_and_mgs
go
CREATE VIEW tt_view_users_and_their_gateways_and_mgs AS
SELECT DISTINCT
    tt_user.user_id AS user_id,
    tt_user.user_login AS user_login,
    tt_gmgt.gm_member AS member,
    tt_gmgt.gm_group AS [group],
    tt_gmgt.gm_gateway_id AS gateway_id,
    tt_gmgt_1.gm_member AS exch_member,
    tt_gmgt_1.gm_group AS exch_group,
    tt_user_group.ugrp_comp_id AS user_comp_id
FROM ((((( tt_user
    INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
    INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
    INNER JOIN tt_mgt ON tt_gmgt.gm_trader = tt_mgt.mgt_trader AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_member = tt_mgt.mgt_member )
    INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id )
    INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt_1.gm_id AND tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id )
    INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id
WHERE ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
    AND tt_user.user_status = 1
go

DROP VIEW tt_view_synthesized_but_missing_mgt_gmgts
go
CREATE VIEW tt_view_synthesized_but_missing_mgt_gmgts AS
SELECT tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
tt_gmgt.gm_gateway_id
FROM tt_gmgt 
LEFT JOIN tt_view_ttords_and_their_gateways ON (tt_gmgt.gm_member = tt_view_ttords_and_their_gateways.mgt_member) AND (tt_gmgt.gm_group = tt_view_ttords_and_their_gateways.mgt_group) AND (tt_gmgt.gm_trader = tt_view_ttords_and_their_gateways.mgt_trader) AND (tt_gmgt.gm_gateway_id = tt_view_ttords_and_their_gateways.gm_gateway_id)
WHERE (((tt_view_ttords_and_their_gateways.mgt_id) Is Null));
go

DROP VIEW tt_view_used_markets
go
CREATE VIEW tt_view_used_markets AS
SELECT * FROM (
select gateway_market_id,
market_name as [market_id]
from tt_gateway 
INNER JOIN tt_market on tt_gateway.gateway_market_id = tt_market.market_id 
union 
select cusd_market_id,
market_name
from tt_customer_default 
INNER JOIN tt_market on tt_customer_default.cusd_market_id = tt_market.market_id 
union 
select acctd_market_id,
market_name
from tt_account_default 
INNER JOIN tt_market on tt_account_default.acctd_market_id = tt_market.market_id ) 
go

DROP VIEW tt_view_user_blacklist_counts
go
CREATE VIEW tt_view_user_blacklist_counts AS
SELECT tt_user_product_group.upg_user_id,
Count(1) AS cnt
FROM tt_market_product_group 
INNER JOIN tt_user_product_group ON tt_market_product_group.mkpg_market_product_group_id = tt_user_product_group.upg_market_product_group_id
WHERE mkpg_market_id = 32
GROUP BY tt_user_product_group.upg_user_id;
go

DROP VIEW tt_view_user_company_relationships
go
CREATE VIEW tt_view_user_company_relationships AS
SELECT * FROM (
select tt_user.user_id,
ugrp_comp_id
FROM tt_user 	
INNER JOIN tt_user_group on tt_user_group.ugrp_group_id = tt_user.user_group_id

union

SELECT tt_user.user_id,
ucp_comp_id
FROM tt_user 	
INNER JOIN tt_user_company_permission on tt_user_company_permission.ucp_user_id = tt_user.user_id ) 
go


DROP VIEW tt_view_user_cusdmarket_cusdacct_combos
go
CREATE VIEW tt_view_user_cusdmarket_cusdacct_combos AS
SELECT DISTINCT tt_customer_default.cusd_user_id,
tt_account.acct_name_in_hex,
tt_customer_default.cusd_market_id
FROM tt_account 
INNER JOIN tt_customer_default ON tt_account.acct_id = tt_customer_default.cusd_account_id
WHERE tt_customer_default.cusd_market_id <> -1 and tt_customer_default.cusd_account_id <> 1;
go

DROP VIEW tt_view_user_cusdmarket_cusdacct_combos2
go
CREATE VIEW tt_view_user_cusdmarket_cusdacct_combos2 AS
SELECT DISTINCT * FROM (
SELECT DISTINCT tt_customer_default.cusd_user_id,
tt_account.acct_name_in_hex,
tt_market.market_id
from (tt_account 
INNER JOIN tt_customer_default ON tt_account.acct_id = tt_customer_default.cusd_account_id) 
INNER JOIN tt_market ON tt_customer_default.cusd_market_id <> tt_market.market_id
where (((tt_customer_default.cusd_market_id)=-1) AND ((tt_customer_default.cusd_account_id)<>1)) 

union 

SELECT distinct tt_customer_default.cusd_user_id,
tt_account.acct_name_in_hex,
tt_customer_default.cusd_market_id
from tt_account 
INNER JOIN tt_customer_default ON tt_account.acct_id = tt_customer_default.cusd_account_id
where tt_customer_default.cusd_market_id <> -1 and tt_customer_default.cusd_account_id <> 1 ) 
go

DROP VIEW tt_view_user_gmgts_without_corresponding_product_limits
go
CREATE VIEW tt_view_user_gmgts_without_corresponding_product_limits AS
SELECT tt_user.user_login AS Username,
tt_user.user_display_name AS [Display Name],
tt_view_ttords_and_their_gateways.mgt_member AS Member,
tt_view_ttords_and_their_gateways.mgt_group AS [Group],
tt_view_ttords_and_their_gateways.mgt_trader AS Trader,
tt_view_ttords_and_their_gateways.gateway_name AS Gateway,
tt_view_ttords_and_their_gateways.mgt_id,
tt_view_ttords_and_their_gateways.mgt_comp_id
FROM (((tt_view_ttords_and_their_gateways 
LEFT JOIN tt_view_product_limits_and_mgts ON tt_view_ttords_and_their_gateways.mgt_id = tt_view_product_limits_and_mgts.mgt_id AND tt_view_ttords_and_their_gateways.gm_gateway_id = tt_view_product_limits_and_mgts.gateway_id) 
INNER JOIN tt_gmgt ON tt_view_ttords_and_their_gateways.mgt_trader = tt_gmgt.gm_trader AND tt_view_ttords_and_their_gateways.mgt_group = tt_gmgt.gm_group AND tt_view_ttords_and_their_gateways.mgt_member = tt_gmgt.gm_member) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
INNER JOIN tt_user ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE tt_view_product_limits_and_mgts.plim_product_limit_id is null 
AND tt_view_ttords_and_their_gateways.mgt_publish_to_guardian = 1 
AND tt_view_ttords_and_their_gateways.mgt_risk_on = 1 
AND tt_view_ttords_and_their_gateways.mgt_type <> 2 
AND tt_view_ttords_and_their_gateways.gateway_market_id not in (84,85,88) 
AND tt_user_gmgt.uxg_available_to_user = 1 
AND tt_user.user_status = 1 
AND tt_view_ttords_and_their_gateways.mgt_risk_on = 1 
AND tt_view_ttords_and_their_gateways.mgt_allow_trading = 1;
go

DROP VIEW tt_view_user_group_cartesian_join
go
CREATE VIEW tt_view_user_group_cartesian_join AS
SELECT tt_user.user_id,
tt_user_group.ugrp_group_id
FROM tt_user,
tt_user_group
WHERE tt_user.user_user_setup_user_type in (2,3);
go

DROP VIEW tt_view_user_group_company_relationships
go

DROP VIEW tt_view_companies_related_to_broker
go
CREATE VIEW tt_view_companies_related_to_broker AS
SELECT * FROM (
SELECT tt_user_group.ugrp_comp_id AS related_comp_id, tt_user_company_permission.ucp_comp_id AS broker_comp_id
FROM tt_user_group 
INNER JOIN (tt_user 
INNER JOIN (tt_company 
INNER JOIN tt_user_company_permission ON tt_company.comp_id = tt_user_company_permission.ucp_comp_id) ON tt_user.user_id = tt_user_company_permission.ucp_user_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id
union
select wi_created_by_comp_id, wi_assigned_to_comp_id from tt_work_item 
union
select wi_assigned_to_comp_id, wi_created_by_comp_id from tt_work_item 
)
go


DROP VIEW tt_view_user_mgt_combos
go
CREATE VIEW tt_view_user_mgt_combos AS
SELECT DISTINCT uxg_user_id,
mgt_id
FROM (tt_gmgt 
INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id;
go

DROP VIEW tt_view_user_mgtmarket_mgtacct_combos
go
CREATE VIEW tt_view_user_mgtmarket_mgtacct_combos AS
SELECT DISTINCT tt_user_gmgt.uxg_user_id,
tt_gateway.gateway_market_id,
tt_account.acct_name_in_hex
FROM tt_gateway 
INNER JOIN ((tt_gmgt 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
INNER JOIN (tt_mgt 
INNER JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id) ON (tt_gmgt.gm_member = tt_mgt.mgt_member) AND (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group)) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id;
go

DROP VIEW tt_view_user_product_group_blacklist_counts
go
CREATE VIEW tt_view_user_product_group_blacklist_counts AS
SELECT tt_user_product_group.upg_user_id,
tt_user_product_group.upg_market_product_group_id,
count(1) AS blacklist_cnt,
max(upg_last_updated_datetime) AS max_date
FROM tt_user_product_group
GROUP BY tt_user_product_group.upg_user_id,
tt_user_product_group.upg_market_product_group_id;
go

DROP VIEW tt_view_user_product_groups_for_cme_sub
go
CREATE VIEW tt_view_user_product_groups_for_cme_sub AS
SELECT tt_market_product_group.mkpg_product_group,
tt_user_product_group.upg_user_id,
tt_user_product_group.upg_comp_id
FROM tt_market_product_group 
INNER JOIN tt_user_product_group ON tt_market_product_group.mkpg_market_product_group_id = tt_user_product_group.upg_market_product_group_id
WHERE tt_market_product_group.mkpg_market_id = 7;
go

DROP VIEW tt_view_user_product_groups_for_cme
go
CREATE VIEW tt_view_user_product_groups_for_cme AS
SELECT
    sub1.mkpg_product_group,
    a.user_login,
    a.concurrent_logins,
    a.exch_member,
    a.user_display_name,
    a.user_address,
    a.user_city,
    a.user_id,
    a.user_postal_code,
    a.user_organization,
    a.user_def1,
    a.user_def2,
    a.user_def3,
    a.user_def4,
    a.user_def5,
    a.user_def6,
    a.user_status,
    a.ugrp_name,
    a.ugrp_group_id,
    a.country_code,
    a.country_name,
    a.state_abbrev,
    a.mgt_comp_id
FROM
(
    SELECT DISTINCT
        tt_user.user_login,
        IIF( CByte( 1 ) = ( SELECT lss_enforce_ip_login_limit FROM tt_login_server_settings ), IIF( CByte( 1 ) = tt_user.user_enforce_ip_login_limit, tt_user.user_ip_login_limit, -1 ), -1 ) AS [concurrent_logins],
        IIF (tt_mgt.mgt_type = 2 or tt_gmgt_1.gm_member = '<No','No Member ID (View Only)',tt_gmgt_1.gm_member) AS exch_member,
        tt_user.user_display_name,
        tt_user.user_address,
        tt_user.user_city,
        tt_user.user_id,
        tt_user.user_postal_code,
        tt_user.user_def1,
        tt_user.user_def2,
        tt_user.user_def3,
        tt_user.user_def4,
        tt_user.user_def5,
        tt_user.user_def6,
        tt_user.user_status,
        iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( tt_company.comp_id <> 0, tt_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ) as [user_organization],
        tt_user_group.ugrp_name,
        tt_user_group.ugrp_group_id,
        tt_country.country_code,
        tt_country.country_name,
        tt_us_state.state_abbrev,
        tt_mgt.mgt_comp_id
    FROM ((((((((((( tt_user
        INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
        INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
        INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
        INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
        INNER JOIN tt_country ON tt_user.user_country_id = tt_country.country_id )
        INNER JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
        INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
        INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member) )
        INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id )
        INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt_1.gm_id )
        INNER JOIN tt_gateway AS tt_gateway_1 ON tt_gmgt_1.gm_gateway_id = tt_gateway_1.gateway_id )
        LEFT JOIN tt_user_company_permission AS ucp ON tt_user.user_id = ucp.ucp_user_id
    WHERE
        tt_gateway.gateway_market_id = 7
        AND tt_gateway_1.gateway_market_id = 7
        AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))
        AND ( ucp.ucp_comp_id is null or ucp.ucp_comp_id = tt_mgt.mgt_comp_id )
) a
LEFT JOIN tt_view_user_product_groups_for_cme_sub AS sub1 ON a.user_id = sub1.upg_user_id AND a.mgt_comp_id = sub1.upg_comp_id
go

DROP VIEW tt_view_users_and_multibroker_blacklist
go
CREATE VIEW tt_view_users_and_multibroker_blacklist AS
SELECT tt_view_user_product_group_blacklist_counts.upg_user_id,
user_login,
tt_market_product_group.mkpg_market_id,
tt_market_product_group.mkpg_product_group_id,
tt_market_product_group.mkpg_market_product_group_id,
tt_view_user_product_group_blacklist_counts.max_date AS upg_last_updated_datetime
FROM tt_view_broker_count,
tt_user 
INNER JOIN (tt_market_product_group 
INNER JOIN tt_view_user_product_group_blacklist_counts ON tt_market_product_group.mkpg_market_product_group_id = tt_view_user_product_group_blacklist_counts.upg_market_product_group_id) ON tt_user.user_id = tt_view_user_product_group_blacklist_counts.upg_user_id
WHERE broker_cnt = blacklist_cnt;
go

DROP VIEW tt_view_users_and_their_accounts
go
CREATE VIEW tt_view_users_and_their_accounts AS
SELECT tt_user.user_login AS Username,
tt_user.user_display_name AS [Display Name],
IIF(tt_user.user_status=1,"Active","Inactive") AS Status,
tt_user_group.ugrp_name AS [User Group],
tt_user_group.ugrp_group_id AS [User Group Id],
tt_view_get_report_accts_all.acct_name AS [All Accts],
tt_view_get_report_accts_mgt.acct_name AS [Gateway Login Accts],
tt_view_get_report_accts_all.acct_comp_id AS comp_id,
tt_view_get_report_accts_cusd.acct_name AS [Customer Default Accts]
FROM tt_user_group 
INNER JOIN (((tt_view_get_report_accts_all 
LEFT JOIN tt_view_get_report_accts_cusd ON (tt_view_get_report_accts_all.user_id = tt_view_get_report_accts_cusd.user_id) AND (tt_view_get_report_accts_all.acct_name = tt_view_get_report_accts_cusd.acct_name)) 
LEFT JOIN tt_view_get_report_accts_mgt ON (tt_view_get_report_accts_all.user_id = tt_view_get_report_accts_mgt.user_id) AND (tt_view_get_report_accts_all.acct_name = tt_view_get_report_accts_mgt.acct_name)) 
INNER JOIN tt_user ON tt_view_get_report_accts_all.user_id = tt_user.user_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id;
go

DROP VIEW tt_view_users_and_their_mgts2
go
CREATE VIEW tt_view_users_and_their_mgts2 AS
SELECT tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
tt_mgt.mgt_id,
tt_mgt.mgt_comp_id,
tt_gmgt.gm_gateway_id
FROM tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
WHERE tt_mgt.mgt_type = 1
go

DROP VIEW tt_view_users_and_their_product_limits
go
CREATE VIEW tt_view_users_and_their_product_limits AS
SELECT DISTINCT tt_view_users_and_their_assigned_mgts_without_user_gmgts.user_login AS Username,
tt_view_users_and_their_assigned_mgts_without_user_gmgts.user_display_name AS [Display Name],
tt_user_group.ugrp_name AS [User Group],
tt_user_group.ugrp_group_id AS [User Group Id],
tt_product_limit.plim_mgt_id AS [MGT Id],
IIf(tt_view_users_and_their_assigned_mgts_without_user_gmgts.user_status=1,
"Active",
"Inactive") AS Status,
tt_view_users_and_their_assigned_mgts_without_user_gmgts.mgt_member AS Member,
tt_view_users_and_their_assigned_mgts_without_user_gmgts.mgt_group AS [Group],
tt_view_users_and_their_assigned_mgts_without_user_gmgts.mgt_trader AS Trader,
tt_market.market_name AS Market,
tt_gateway.gateway_name AS Gateway,
tt_product_limit.plim_product AS Product,
tt_product_type.product_description AS [Product Type],
iif(tt_product_limit.plim_for_simulation = 0,
'Prod',
'Sim') AS [Prod/Sim Mode],
iif(tt_product_limit.plim_addl_margin_pct_on=1,"Yes","No") AS [Addl Mrgn % On],
tt_product_limit.plim_additional_margin_pct/1000 AS [Addl Mrgn %],
iif(tt_product_limit.plim_max_order_qty_on=1,"Yes","No") AS [Max Ord Qty On],
tt_product_limit.plim_max_order_qty AS [Max Ord Qty],
iif(tt_product_limit.plim_max_position_on=1,"Yes","No") AS [Max Pos On],
tt_product_limit.plim_max_position AS [Max Pos],
tt_product_limit.plim_allow_tradeout AS [Allow Trade Out],
iif(tt_product_limit.plim_max_long_short_on=1,"Yes","No") AS [Max Long/Short On],
tt_product_limit.plim_max_long_short AS [Max Long/Short],
iif(tt_product_limit.plim_prevent_orders_based_on_price_ticks=1,"Yes","No") AS [Price Controls Enabled],
tt_product_limit.plim_prevent_orders_price_ticks AS [Ticks Away],
iif(tt_product_limit.plim_enforce_price_limit_on_buysell_only=1,"Yes","No") AS [Directional Price Range]
FROM tt_product_type 
INNER JOIN (((tt_market 
INNER JOIN tt_gateway ON tt_market.market_id = tt_gateway.gateway_market_id) 
INNER JOIN (tt_product_limit 
INNER JOIN tt_view_users_and_their_assigned_mgts_without_user_gmgts ON tt_product_limit.plim_mgt_id = tt_view_users_and_their_assigned_mgts_without_user_gmgts.mgt_id) ON tt_gateway.gateway_id = tt_product_limit.plim_gateway_id) 
INNER JOIN tt_user_group ON tt_view_users_and_their_assigned_mgts_without_user_gmgts.user_group_id = tt_user_group.ugrp_group_id) ON tt_product_type.product_id = tt_product_limit.plim_product_type;
go

DROP VIEW tt_view_users_and_their_risk_parameters_collapsed
go
CREATE VIEW tt_view_users_and_their_risk_parameters_collapsed AS
SELECT DISTINCT tt_view_users_and_their_assigned_mgts.user_login AS Username,
tt_view_users_and_their_assigned_mgts.user_display_name AS [Display Name],
tt_user_group.ugrp_name AS [User Group],
tt_user_group.ugrp_group_id AS [User Group Id],
IIF( tt_company.comp_name IS NOT NULL, tt_company.comp_name, '' ) AS [Company],
IIF(tt_view_users_and_their_assigned_mgts.user_status=1,"Active","Inactive") AS Status,
tt_view_users_and_their_assigned_mgts.mgt_member AS Member,
tt_view_users_and_their_assigned_mgts.mgt_group AS [Group],
tt_view_users_and_their_assigned_mgts.mgt_trader AS Trader,
tt_view_users_and_their_assigned_mgts.mgt_comp_id AS mgt_comp_id,
tt_view_users_and_their_assigned_mgts.mgt_description AS Alias,
tt_view_users_and_their_assigned_mgts.mgt_publish_to_guardian AS [Add to Guardian],
CBYTE(iif(tt_view_users_and_their_assigned_mgts.mgt_publish_to_guardian = 1,
	tt_view_users_and_their_assigned_mgts.mgt_risk_on,
	0)) AS [Risk Check],
tt_view_users_and_their_assigned_mgts.mgt_allow_trading AS [Allow Trading],
tt_view_users_and_their_assigned_mgts.mgt_ignore_pl AS [Ignore P&L],
tt_view_users_and_their_assigned_mgts.mgt_credit AS Credit,
tt_view_users_and_their_assigned_mgts.mgt_currency AS [Currency]
FROM ( tt_view_users_and_their_assigned_mgts 
INNER JOIN tt_user_group ON tt_view_users_and_their_assigned_mgts.user_group_id = tt_user_group.ugrp_group_id )
LEFT JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
go

DROP VIEW tt_view_users_and_their_risk_parameters_expanded
go
CREATE VIEW tt_view_users_and_their_risk_parameters_expanded AS
SELECT DISTINCT tt_view_users_and_their_assigned_mgts.user_login AS Username,
tt_view_users_and_their_assigned_mgts.user_display_name AS [Display Name],
tt_user_group.ugrp_name AS [User Group],
tt_user_group.ugrp_group_id AS [User Group Id],
IIF( tt_company.comp_name IS NOT NULL, tt_company.comp_name, '' ) AS [Company],
IIf(tt_view_users_and_their_assigned_mgts.user_status=1,
"Active",
"Inactive") AS Status,
tt_view_users_and_their_assigned_mgts.mgt_member AS Member,
tt_view_users_and_their_assigned_mgts.mgt_group AS [Group],
tt_view_users_and_their_assigned_mgts.mgt_trader AS Trader,
tt_view_users_and_their_assigned_mgts.mgt_comp_id AS mgt_comp_id,
tt_market.market_name AS Market,
tt_gateway.gateway_name AS Gateway,
tt_view_users_and_their_assigned_mgts.uxg_available_to_user AS [Available to User],
tt_view_users_and_their_assigned_mgts.uxg_available_to_fix_adapter_user AS [Available to FA User],
tt_view_users_and_their_assigned_mgts.uxg_automatically_login AS [Auto Login],
tt_view_users_and_their_assigned_mgts.uxg_preferred_ip AS [Preferred IP],
tt_view_users_and_their_assigned_mgts.mgt_description AS Alias,
tt_view_users_and_their_assigned_mgts.mgt_publish_to_guardian AS [Add to Guardian],
CBYTE(iif(tt_view_users_and_their_assigned_mgts.mgt_publish_to_guardian = 1,
	tt_view_users_and_their_assigned_mgts.mgt_risk_on,
	0)) AS [Risk Check],
tt_view_users_and_their_assigned_mgts.mgt_allow_trading AS [Allow Trading],
tt_view_users_and_their_assigned_mgts.mgt_ignore_pl AS [Ignore P&L],
tt_view_users_and_their_assigned_mgts.mgt_credit AS Credit,
tt_view_users_and_their_assigned_mgts.mgt_currency AS [Currency]
FROM (((( tt_view_users_and_their_assigned_mgts 
INNER JOIN tt_user_group ON tt_view_users_and_their_assigned_mgts.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_gmgt ON tt_view_users_and_their_assigned_mgts.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id )
LEFT JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
go

DROP VIEW tt_view_users_mgt_counts
go
CREATE VIEW tt_view_users_mgt_counts AS
SELECT tt_user.user_login AS Username,
tt_user.user_display_name AS [Display Name],
tt_user.user_group_id AS [User Group Id],
tt_user_group.ugrp_name AS [User Group],
tt_user.user_id AS user_id
FROM tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id;
go

DROP VIEW tt_view_users_missing_location_info
go
CREATE VIEW tt_view_users_missing_location_info AS

select DISTINCT * from (

SELECT DISTINCT tt_user.user_id,
tt_user.user_login AS Username,
tt_user.user_display_name AS [Display Name],
tt_user_group.ugrp_comp_id,
tt_user.user_group_id,
tt_user.user_country_id,
tt_user.user_postal_code
FROM tt_db_version,
tt_gateway 
INNER JOIN (tt_gmgt 
INNER JOIN ((tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id
WHERE user_status = 1 
AND (tt_user.user_country_id = 0 
or (tt_user.user_country_id = 227 
and len(tt_user.user_postal_code) < 5)) 
AND (tt_user_gmgt.uxg_available_to_user = 1 or (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1)) 
AND dbv_txn_billing = 1 

UNION

SELECT DISTINCT tt_user.user_id,
tt_user.user_login AS Username,
tt_user.user_display_name AS [Display Name],
tt_user_group.ugrp_comp_id,
tt_user.user_group_id,
tt_user.user_country_id,
tt_user.user_postal_code
FROM tt_gateway 
INNER JOIN (tt_gmgt 
INNER JOIN ((tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id
WHERE user_status = 1 
AND (tt_user.user_country_id = 0 
or (tt_user.user_country_id = 227 and tt_user.user_state_id = 0) 
or (tt_user.user_country_id = 39 and tt_user.user_state_id = 0) )
AND (tt_user_gmgt.uxg_available_to_user = 1 or (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1)) 
AND tt_gateway.gateway_market_id in (7)
)
go

DROP VIEW tt_view_users_with_blank_row
go
CREATE VIEW tt_view_users_with_blank_row AS
SELECT *
FROM
(
    SELECT tt_user.user_login AS [Username],
        tt_user.user_display_name AS [Display Name],
        tt_user_group.ugrp_name AS [User Group],
        tt_company.comp_name AS [Company],
        IIf(tt_user.user_status=1,"Active","Inactive") AS Status,
        tt_user.user_email AS Email, tt_user.user_phone AS Phone,
        tt_user.user_most_recent_login_datetime AS [Most Recent Login],
        tt_user_group.ugrp_group_id,
        tt_user_company_permission.ucp_comp_id as broker_comp_id        
    from (( tt_user 
        INNER JOIN tt_user_group ON tt_user_group.ugrp_group_id = tt_user.user_group_id )
        INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
        LEFT JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id
  UNION
    SELECT '','','','','','','',#1970-01-02 00:00:00#,-1,-1 from tt_user
);
go

DROP VIEW tt_view_users_with_multiple_available_to_fix_user_gateways
go
CREATE VIEW tt_view_users_with_multiple_available_to_fix_user_gateways AS
SELECT tt_user_1.user_login AS Username,
    tt_user.user_login AS [Server Username],
    tt_user_1.user_display_name AS [Display Name],
    tt_gateway.gateway_name AS Gateway,
    tt_user_1.user_group_id,
    tt_user_group.ugrp_comp_id,
    tt_mgt.mgt_comp_id
FROM (((((( tt_user
INNER JOIN tt_user_user_relationship ON tt_user.user_id = tt_user_user_relationship.uur_user_id2 )
INNER JOIN tt_user AS tt_user_1 ON tt_user_user_relationship.uur_user_id1 = tt_user_1.user_id )
INNER JOIN tt_user_group ON tt_user_group.ugrp_group_id = tt_user_1.user_group_id )
INNER JOIN tt_user_gmgt ON tt_user_gmgt.uxg_user_id = tt_user_1.user_id )
INNER JOIN tt_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
INNER JOIN tt_gateway ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id )
INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader
WHERE tt_user.user_status = 1  and tt_user.user_fix_adapter_role = 2  and tt_user_1.user_status = 1  and tt_user_gmgt.uxg_available_to_fix_adapter_user = 1
GROUP BY tt_user_1.user_login, tt_user.user_login, tt_user_1.user_display_name, tt_gateway.gateway_name, tt_user_1.user_group_id, tt_user_group.ugrp_comp_id, tt_mgt.mgt_comp_id
HAVING count(1) > 1 and sum(iif (left(tt_gmgt.gm_member,5) <> 'TTORD', 1, 0)) > 0;
go

DROP VIEW tt_view_users_with_multiple_available_to_user_gateways
go
CREATE VIEW tt_view_users_with_multiple_available_to_user_gateways AS
SELECT tt_user.user_id,
tt_user.user_login AS Username,
tt_user.user_display_name AS [Display Name],
tt_user.user_group_id,
tt_user_group.ugrp_comp_id,
tt_gmgt.gm_gateway_id,
tt_gateway.gateway_name AS Gateway,
tt_mgt.mgt_comp_id
FROM (tt_user_group 
INNER JOIN (tt_user 
INNER JOIN ((tt_gateway 
INNER JOIN tt_gmgt ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
INNER JOIN tt_mgt ON (tt_gmgt.gm_member = tt_mgt.mgt_member) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_trader = tt_mgt.mgt_trader)
WHERE tt_user_gmgt.uxg_available_to_user = 1 AND tt_user.user_status = 1
GROUP BY tt_user.user_id,
tt_user.user_login,
tt_user.user_display_name,
tt_user.user_group_id,
tt_user_group.ugrp_comp_id,
tt_gmgt.gm_gateway_id,
tt_gateway.gateway_name,
tt_mgt.mgt_comp_id
HAVING count(1) > 1;
go

DROP VIEW tt_view_xt_versions_in_past_week
go
CREATE VIEW tt_view_xt_versions_in_past_week AS
SELECT tt_ip_address_version.ipv_user_login,
tt_ip_address_version.ipv_ip_address,
Max(tt_ip_address_version.ipv_last_updated_datetime) AS last_seen_datetime
FROM tt_ip_address_version
WHERE ipv_gateway_id = 0 
AND ipv_last_updated_datetime >DateAdd("d",-7,Now) 
AND tt_ip_address_version.ipv_tt_product_name In ('X_TRADER','X_TRADER PRO') 
AND tt_ip_address_version.ipv_user_login <> ''
GROUP BY tt_ip_address_version.ipv_user_login,
tt_ip_address_version.ipv_ip_address;
go

DROP VIEW tt_view_user_pairs_and_blacklist
go

DROP VIEW tt_view_same_orderbook_diff_blacklist
go

-- users and all their mgs for the three markets with groups
DROP VIEW tt_view_users_and_their_gateways_and_mgs_for_product_groups
go
CREATE VIEW tt_view_users_and_their_gateways_and_mgs_for_product_groups AS
SELECT DISTINCT 
tt_user.user_id, 
tt_gmgt.gm_member, 
tt_gmgt.gm_group, 
tt_gmgt.gm_gateway_id, 
tt_gmgt_1.gm_member AS exch_member, 
tt_gmgt_1.gm_group AS exch_group,
gateway_market_id,
tt_mgt.mgt_comp_id
FROM tt_gateway 
INNER JOIN (tt_user 
INNER JOIN (((tt_gmgt 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
INNER JOIN tt_mgt ON (tt_gmgt.gm_member = tt_mgt.mgt_member) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_trader = tt_mgt.mgt_trader)) 
INNER JOIN (tt_gmgt AS tt_gmgt_1 
INNER JOIN tt_mgt_gmgt ON tt_gmgt_1.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id
WHERE gateway_market_id in (6, 7, 32)
AND tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id
AND tt_user.user_status = 1 
AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))
go

DROP VIEW tt_view_companies_with_ice_gw_assignments
go
CREATE VIEW tt_view_companies_with_ice_gw_assignments AS
SELECT
    tt_mgt.mgt_comp_id as [broker_comp_id],
    tt_user_group.ugrp_comp_id as [assigned_comp_id]
FROM (((( tt_user
    INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
    INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
    INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
    INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader )
    INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id
WHERE
    tt_gateway.gateway_market_id = 32
    AND ( 0 <> tt_mgt.mgt_comp_id OR 0 = ( select lss_multibroker_mode from tt_login_server_settings ) )
GROUP BY
    tt_mgt.mgt_comp_id,
    tt_user_group.ugrp_comp_id
GO

-- 7.4.8
drop view tt_view_account_group_group_permission_all_verbose
go
create view tt_view_account_group_group_permission_all_verbose as
select distinct *
FROM
(
  select distinct 
      0 as type, 
      -99 as source_id, 
      aggp_id as id,
      aggp_account_group_id, 
      aggp_group_id
  from tt_account_group_group_permission 
union
  select
      iif(tt_view_account_group_permission_all_verbose.type=0,3,tt_view_account_group_permission_all_verbose.type) as [type],
      source_id, 
      id,
      ag_id as aggp_account_group_id,
      agp_group_id as aggp_group_id
  from ( tt_account
  inner join tt_view_account_group_permission_all_verbose on tt_account.acct_id = tt_view_account_group_permission_all_verbose.agp_account_id )
  inner join tt_account_group on tt_account.acct_account_group_id = tt_account_group.ag_id
)
go

drop view tt_view_account_group_group_permission_all
go
create view tt_view_account_group_group_permission_all as
  select 
    MAX(id) as aggp_id, 
    aggp_account_group_id, 
    aggp_group_id
  from tt_view_account_group_group_permission_all_verbose
  group by aggp_account_group_id, aggp_group_id
go

update tt_db_version set
dbv_last_notification_sequence_number = 1
go

DROP VIEW tt_view_get_properties_xt
go

DROP VIEW tt_view_users_and_their_blacklist_company_counts
go

DROP VIEW tt_view_users_and_their_company_counts
go

