update tt_db_version set dbv_version = 'converting to 7.17.10'
go

update tt_x_trader_mode set x_trader_mode_name = '<Not Specified>' where x_trader_mode_id = 0
go

alter table tt_product_limit add plim_max_outright_wholesale_order_size_on byte not null
go
alter table tt_product_limit add plim_max_outright_wholesale_order_size int not null
go
alter table tt_product_limit add plim_max_spread_wholesale_order_size_on byte not null
go
alter table tt_product_limit add plim_max_spread_wholesale_order_size int not null
go
alter table tt_product_limit add plim_outright_wholesale_price_rsn_on byte not null
go
alter table tt_product_limit add plim_outright_wholesale_price_rsn int not null
go
alter table tt_product_limit add plim_spread_wholesale_price_rsn_on byte not null
go
alter table tt_product_limit add plim_spread_wholesale_price_rsn int not null
go
alter table tt_product_limit add plim_wholesale_overrides_on byte not null
go


UPDATE
    tt_product_limit
SET
    plim_max_outright_wholesale_order_size_on = 0,
    plim_max_outright_wholesale_order_size = 0,
    plim_max_spread_wholesale_order_size_on = 0,
    plim_max_spread_wholesale_order_size = 0,
    plim_outright_wholesale_price_rsn_on = 0,
    plim_outright_wholesale_price_rsn = 0,
    plim_spread_wholesale_price_rsn_on = 0,
    plim_spread_wholesale_price_rsn = 0,
    plim_wholesale_overrides_on = 0
go

UPDATE tt_account_group
SET ag_risk_enabled_for_wholesale_trades = CByte( 1 )
WHERE ag_id IN
(
    SELECT ag_id
    FROM tt_account_group
    LEFT JOIN tt_margin_limit ON tt_account_group.ag_id = tt_margin_limit.mlim_account_group_id
    WHERE ( tt_margin_limit.mlim_margin_limit_id is not null OR tt_account_group.ag_risk_enabled = CByte( 1 ) )
    GROUP BY ag_id, ag_name
)
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

ALTER TABLE tt_margin_limit ADD mlim_margin_limit int not null
go

ALTER TABLE tt_margin_limit ADD mlim_margin_limit_enabled_tmp byte not null
go

UPDATE tt_margin_limit
SET mlim_margin_limit = mlim_margin_limit_times_100 / 100,
    mlim_margin_limit_enabled_tmp = mlim_margin_limit_enabled
go

ALTER TABLE tt_margin_limit DROP COLUMN mlim_margin_limit_times_100
go

ALTER TABLE tt_margin_limit DROP COLUMN mlim_margin_limit_enabled
go

ALTER TABLE tt_margin_limit ADD mlim_margin_limit_enabled byte not null
go

UPDATE tt_margin_limit
SET mlim_margin_limit_enabled = mlim_margin_limit_enabled_tmp
go

ALTER TABLE tt_margin_limit DROP COLUMN mlim_margin_limit_enabled_tmp
go

ALTER TABLE tt_account_group ADD ag_avoid_orders_that_cross int NOT NULL
go

UPDATE tt_account_group SET ag_avoid_orders_that_cross = 0
go

alter table tt_user add user_can_submit_market_orders byte not null
go

update tt_user set user_can_submit_market_orders = CByte(1)
go

alter table tt_user_company_permission add ucp_can_submit_market_orders byte null
go

update tt_user_company_permission set ucp_can_submit_market_orders = CByte(1)
go

alter table tt_user add user_xrisk_allowed byte not null
go

update tt_user set user_xrisk_allowed = CByte(1)
go

update tt_mgt set mgt_publish_to_guardian = CByte(1) where left( mgt_member, 5 ) = 'TTORD'
go

UPDATE tt_user SET user_cross_orders_cancel_resting = CByte(0) WHERE user_cross_orders_allowed = CByte(1)
go

UPDATE tt_user_company_permission SET ucp_cross_orders_cancel_resting = CByte(0) WHERE ucp_cross_orders_allowed = CByte(1)
go

ALTER table tt_user ALTER COLUMN user_password VARCHAR(255) NOT NULL
go

ALTER table tt_password_history2 ALTER COLUMN password_history_password VARCHAR(255) NOT NULL
go

update tt_login_server_settings set lss_enable_diagnostics = CByte(0) where lss_multibroker_mode <> CByte(0)
go

drop index index_mgt_member_group_trader on tt_mgt
go

create index index_mgt_member_group_trader on tt_mgt (mgt_member, mgt_group, mgt_trader)
go

INSERT INTO tt_user_gmgt ( uxg_created_datetime, uxg_created_user_id, uxg_last_updated_datetime, uxg_last_updated_user_id, uxg_user_id, uxg_gmgt_id, uxg_automatically_login, uxg_preferred_ip, uxg_clearing_member, uxg_default_account, uxg_available_to_user, uxg_available_to_fix_adapter_user, uxg_mandatory_login, uxg_operator_id, uxg_max_orders_per_second, uxg_max_orders_per_second_on )
SELECT
    now, 0, now, 0, a.user_id, a.gm_id, 0, '', '', '', 0, 0, 0, '', 0, 0
FROM
(
    SELECT DISTINCT tt_user.user_id, gmgt_1.gm_id
      FROM ((( tt_user
      INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
      INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
      INNER JOIN tt_gmgt AS gmgt_1 ON tt_gmgt.gm_member = gmgt_1.gm_member AND tt_gmgt.gm_group = gmgt_1.gm_group AND tt_gmgt.gm_trader = gmgt_1.gm_trader )
	  WHERE left( tt_gmgt.gm_member, 5 ) <> 'TTORD' 
) a
LEFT JOIN
(
    SELECT tt_user.user_id, tt_gmgt.gm_id
    FROM (( tt_user
    INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
    INNER JOIN tt_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
	WHERE left( tt_gmgt.gm_member, 5 ) <> 'TTORD'
) b ON a.user_id = b.user_id AND a.gm_id = b.gm_id
WHERE b.gm_id IS NULL
go

DROP VIEW tt_view_max_x_trader_user_date
go
CREATE VIEW tt_view_max_x_trader_user_date AS
SELECT tt_ip_address_version.ipv_user_login,
Max(tt_ip_address_version.ipv_last_updated_datetime) AS ipv_last_datetime
FROM tt_ip_address_version
WHERE tt_ip_address_version.ipv_user_login <> '' 
and tt_ip_address_version.ipv_tt_product_id in (8,30,53) 
and tt_ip_address_version.ipv_gateway_id = 0
GROUP BY tt_ip_address_version.ipv_user_login;
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

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.010.000'
go

