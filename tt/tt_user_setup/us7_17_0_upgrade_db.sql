update tt_db_version set dbv_version = 'converting to 7.17.0'
go

-------------------------------------------------------------------------------
--  Gateway
-------------------------------------------------------------------------------
ALTER TABLE tt_gateway 
ADD gateway_locked byte NOT NULL
DEFAULT 0
GO

ALTER TABLE tt_gateway 
ADD gateway_last_updated_datetime datetime NOT NULL 
DEFAULT '1970-01-02 00:00:00'
GO

ALTER TABLE tt_gateway 
ADD gateway_last_updated_user_id int NOT NULL 
DEFAULT -1
GO

ALTER TABLE tt_gateway 
ADD gateway_is_active byte NOT NULL
DEFAULT 0
GO

UPDATE tt_gateway 
SET gateway_locked=0 
WHERE gateway_locked IS NULL
GO

UPDATE tt_gateway 
SET gateway_last_updated_datetime='1970-01-02 00:00:00' 
WHERE gateway_last_updated_datetime IS NULL
GO

UPDATE tt_gateway 
SET gateway_last_updated_user_id=-1 
WHERE gateway_last_updated_user_id IS NULL
GO

UPDATE tt_gateway 
SET gateway_is_active=0 
WHERE gateway_is_active IS NULL
GO

-------------------------------------------------------------------------------
--  MGT
-------------------------------------------------------------------------------

alter table tt_mgt add mgt_type int not null
go

-- mgt_type: 0=Direct Trader, 1=TTORD, 2=Admin MGT

update tt_mgt set mgt_type = 0 
go

update tt_mgt set mgt_type = 2
where mgt_member = 'TTADM'
or mgt_group = 'XXX'
or left(mgt_trader,3) = 'MGR'
or left(mgt_trader,4) = 'VIEW' 
go

update tt_mgt set mgt_type = 1 
where mgt_type = 0
and left(mgt_member,5) = 'TTORD'
go

-- clean up mgt passwords that don't do anything
update tt_mgt set mgt_password = '' 
where mgt_type <> 0
go


-------------------------------------------------------------------------------
--  Product Limit
-------------------------------------------------------------------------------

-- clean up product limits that don't do anything
delete from tt_product_limit where tt_product_limit.plim_mgt_id in
(select tt_mgt.mgt_id from tt_mgt where tt_mgt.mgt_type = 2)
go

-- delete account-based product limits of types Swap, Warrant, Forex or NDF
DELETE
FROM
    tt_product_limit
WHERE
    plim_product_type in ( 7, 8, 31, 33 )
    AND plim_account_group_id <> 0
go

-- table structure modifications
alter table tt_product_limit add plim_allow_trading_outrights_on byte not null
go
alter table tt_product_limit add plim_allow_trading_spreads_on byte not null
go
alter table tt_product_limit add plim_max_outright_order_size_on byte not null
go
alter table tt_product_limit add plim_max_outright_order_size int not null
go
alter table tt_product_limit add plim_max_spread_order_size_on byte not null
go
alter table tt_product_limit add plim_max_spread_order_size int not null
go
alter table tt_product_limit add plim_max_product_position_on byte not null
go
alter table tt_product_limit add plim_max_product_position int not null
go
alter table tt_product_limit add plim_max_outright_position_on byte not null
go
alter table tt_product_limit add plim_max_outright_position int not null
go
alter table tt_product_limit add plim_max_product_long_short_on byte not null
go
alter table tt_product_limit add plim_max_product_long_short int not null
go
alter table tt_product_limit add plim_outright_price_rsn_on byte not null
go
alter table tt_product_limit add plim_outright_price_rsn int not null
go
alter table tt_product_limit add plim_outright_price_rsn_into_market_on byte not null
go
alter table tt_product_limit add plim_spread_price_rsn_on byte not null
go
alter table tt_product_limit add plim_spread_price_rsn int not null
go
alter table tt_product_limit add plim_spread_price_rsn_into_market_on byte not null
go
alter table tt_product_limit add plim_tradeout_only_on byte not null
go
alter table tt_product_limit add plim_tradeout_only_days int not null
go
alter table tt_product_limit add plim_additional_outright_margin_pct int not null
go
alter table tt_product_limit add plim_additional_spread_margin_pct int not null
go

UPDATE
    tt_product_limit
SET
    plim_allow_trading_outrights_on = 0,
    plim_allow_trading_spreads_on = 0,
    plim_max_outright_order_size_on = 0,
    plim_max_outright_order_size = 0,
    plim_max_spread_order_size_on = 0,
    plim_max_spread_order_size = 0,
    plim_max_product_position_on = 0,
    plim_max_product_position = 0,
    plim_max_outright_position_on = 0,
    plim_max_outright_position = 0,
    plim_max_product_long_short_on = 0,
    plim_max_product_long_short = 0,
    plim_outright_price_rsn_on = 0,
    plim_outright_price_rsn = 0,
    plim_outright_price_rsn_into_market_on = 0,
    plim_spread_price_rsn_on = 0,
    plim_spread_price_rsn = 0,
    plim_spread_price_rsn_into_market_on = 0,
    plim_tradeout_only_on = 0,
    plim_tradeout_only_days = 0,
    plim_additional_outright_margin_pct = 0,
    plim_additional_spread_margin_pct = 0
go

-------------------------------------------------------------------------------
--  Contract Limit
-------------------------------------------------------------------------------

create table tt_contract_limit
(
  clim_contract_limit_id                     counter      not null primary key,
  clim_created_datetime                      datetime     not null,
  clim_created_user_id                       int          not null,
  clim_last_updated_datetime                 datetime     not null,
  clim_last_updated_user_id                  int          not null,
  clim_product_limit_id                      int          not null,
  clim_name                                  varchar(36)  not null,
  clim_series_key                            varchar(40)  not null,
  clim_expiration                            varchar(32)  not null,
  clim_allow_trading                         byte         not null,
  clim_max_order_size_on                     byte         not null,
  clim_max_order_size                        int          not null,
  clim_max_position_on                       byte         not null,
  clim_max_position                          int          not null,
  clim_price_rsn_on                          byte         not null,
  clim_price_rsn                             int          not null
)
go

alter table tt_contract_limit add constraint fk_contract_limit_product_limit foreign key (clim_product_limit_id) references tt_product_limit (plim_product_limit_id) ON DELETE CASCADE
go

create unique index index_contract_limit_key on tt_contract_limit (clim_product_limit_id, clim_series_key)
go

-------------------------------------------------------------------------------
--  User 
-------------------------------------------------------------------------------

alter table tt_user add user_liquidate_exceeding_position_limits_allowed byte not null
go
alter table tt_user add user_billing1 varchar(50) null
go
alter table tt_user add user_billing2 varchar(50) null
go
alter table tt_user add user_billing3 varchar(50) null
go
alter table tt_user add user_never_locked_by_inactivity byte not null
go

alter table tt_user add user_most_recent_login_ip varchar(15) not null
go
alter table tt_user add user_most_recent_xt_version varchar(15) not null
go
alter table tt_user add user_most_recent_fa_version varchar(15) not null
go
alter table tt_user add user_most_recent_xr_version varchar(15) not null
go

alter table tt_user add user_algo_deployment_allowed byte not null
go

alter table tt_user add user_algo_sharing_allowed byte not null
go

alter table tt_user add user_individually_select_admin_logins byte not null
go

alter table tt_user add user_ignore_pl byte not null
go
alter table tt_user add user_ignore_margin byte not null
go
alter table tt_user add user_claim_own_staged_orders_allowed byte not null
go
alter table tt_user add user_wholesale_orders_with_undefined_accounts_allowed byte not null
go
alter table tt_user add user_account_permissions_enabled byte not null
go

update tt_user set 
user_liquidate_exceeding_position_limits_allowed = 1,
user_billing1 = user_def1,
user_billing2 = user_def2,
user_billing3 = user_def3,
user_never_locked_by_inactivity = 0,
user_most_recent_login_ip = '',
user_most_recent_xt_version = '',
user_most_recent_fa_version = '',
user_most_recent_xr_version = '',
user_algo_deployment_allowed = 0,
user_algo_sharing_allowed = 0,
user_individually_select_admin_logins = 0,
user_ignore_pl = 0,
user_ignore_margin = 0,
user_claim_own_staged_orders_allowed = CByte(1),
user_wholesale_orders_with_undefined_accounts_allowed = CByte(1),
user_account_permissions_enabled = CByte(0)
go

update tt_user set
user_persist_orders_on_eurex = 0
where user_persist_orders_on_eurex = 2
go

UPDATE tt_user
SET user_algo_deployment_allowed = 1
WHERE user_login in
(
  select tt_user.user_login
  FROM ((( tt_user
  INNER JOIN tt_user_gmgt on tt_user.user_id = tt_user_gmgt.uxg_user_id )
  INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
  INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
  INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id
  WHERE tt_market.market_name = 'AlgoSE' AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))
  GROUP BY tt_user.user_login
  HAVING sum( tt_user_gmgt.uxg_deploy_algo_to_server_allowed ) > 0
)
go

UPDATE tt_user
SET user_algo_sharing_allowed = 1
WHERE user_login in
(
  select tt_user.user_login
  FROM ((( tt_user
  INNER JOIN tt_user_gmgt on tt_user.user_id = tt_user_gmgt.uxg_user_id )
  INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
  INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
  INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id
  WHERE tt_market.market_name = 'AlgoSE' AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))
  GROUP BY tt_user.user_login
  HAVING sum( tt_user_gmgt.uxg_algo_sharing_allowed ) > 0
)
go


update tt_user set
user_quoting_allowed = 1
where user_quoting_allowed = 0
go

update tt_user set
user_machine_gun_orders_allowed = 1
where user_machine_gun_orders_allowed = 0
go

-- Need to do this before the next two scripts as their logic relies on this.
update tt_user
set
user_fix_staged_order_creation_allowed = 0,
user_fix_dma_order_creation_allowed = 0
where
(user_fix_adapter_role = 2 or user_fix_adapter_role = 3)
go

update tt_user
set
user_staged_order_creation_allowed = 1,
user_fix_staged_order_creation_allowed = 1
where
(user_staged_order_creation_allowed = 1 and user_fix_staged_order_creation_allowed = 0) or
(user_staged_order_creation_allowed = 0 and user_fix_staged_order_creation_allowed = 1)
go

update tt_user
set
user_dma_order_creation_allowed = 1,
user_fix_dma_order_creation_allowed = 1
where
(user_dma_order_creation_allowed = 1 and user_fix_dma_order_creation_allowed = 0) or
(user_dma_order_creation_allowed = 0 and user_fix_dma_order_creation_allowed = 1)
go

update tt_user set user_xrisk_manual_fills_allowed = CByte(1) where user_xrisk_sods_allowed = CByte(1)
go
update tt_user set user_xrisk_sods_allowed = CByte(1) where user_xrisk_manual_fills_allowed = CByte(1)
go

UPDATE tt_user 
SET user_wholesale_trades_allowed = 0
WHERE user_id in 
 (
    SELECT user_id 
    FROM(( tt_user 
    INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id)
    INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id)
    WHERE tt_company.comp_is_broker = 0 AND tt_company.comp_id <> 0 AND tt_user.user_wholesale_trades_allowed = 1
 )
 AND 1 = ( select lss_multibroker_mode from tt_login_server_settings)
go

UPDATE tt_user
SET user_on_behalf_of_allowed = CByte(0)
go

UPDATE tt_user
SET user_on_behalf_of_allowed = CByte(1)
WHERE user_login IN
(
    SELECT user_login
    FROM ( tt_user
    INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
    INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id
    WHERE LEFT( tt_gmgt.gm_member, 5 ) NOT IN ( 'TTORD', 'TTADM' ) AND tt_user_gmgt.uxg_available_to_user = CByte(1)
    GROUP BY tt_user.user_login
)
go

-------------------------------------------------------------------------------
--  User/GMGT
-------------------------------------------------------------------------------
alter table tt_user_gmgt drop column uxg_deploy_algo_to_server_allowed
go

alter table tt_user_gmgt drop column uxg_algo_sharing_allowed
go

-------------------------------------------------------------------------------
--  Fix Adapter Role
-------------------------------------------------------------------------------

create table tt_fix_adapter_role
(
far_role_id int primary key not null,
far_description varchar(40) not null
)
go

insert into tt_fix_adapter_role values(0, "None")
go
insert into tt_fix_adapter_role values(1, "Client")
go
insert into tt_fix_adapter_role values(2, "Order Routing Server 7.6-7.8")
go
insert into tt_fix_adapter_role values(3, "Drop Copy Server 7.6-7.8")
go
insert into tt_fix_adapter_role values(4, "Order Routing Server 7.17+")
go
insert into tt_fix_adapter_role values(5, "Drop Copy Server 7.17+")
go

alter table tt_user add constraint fk_user_to_fix_adapter_role foreign key (user_fix_adapter_role) references tt_fix_adapter_role (far_role_id) ON DELETE CASCADE
go

-------------------------------------------------------------------------------
--  Company
-------------------------------------------------------------------------------

alter table tt_company add comp_smtp_body memo not null
go

-------------------------------------------------------------------------------
--  User Company Permission
-------------------------------------------------------------------------------

alter table tt_user_company_permission add ucp_billing1 varchar(50) null
go
alter table tt_user_company_permission add ucp_billing2 varchar(50) null
go
alter table tt_user_company_permission add ucp_billing3 varchar(50) null
go
alter table tt_user_company_permission add ucp_fix_adapter_default_editing_allowed byte not null 
go
alter table tt_user_company_permission add ucp_cross_orders_allowed byte null
go
alter table tt_user_company_permission add ucp_wholesale_trades_allowed byte null
go
alter table tt_user_company_permission add ucp_persist_orders_on_eurex int null
go
alter table tt_user_company_permission add ucp_prevent_orders_based_on_price_ticks byte null
go
alter table tt_user_company_permission add ucp_prevent_orders_price_ticks int null
go
alter table tt_user_company_permission add ucp_enforce_price_limit_on_buysell_only byte null
go
alter table tt_user_company_permission add ucp_prevent_orders_based_on_rate byte null
go
alter table tt_user_company_permission add ucp_prevent_orders_rate int null
go
alter table tt_user_company_permission add ucp_dma_order_creation_allowed byte null
go
alter table tt_user_company_permission add ucp_fix_dma_order_creation_allowed byte null
go
alter table tt_user_company_permission add ucp_gtc_orders_allowed byte null
go
alter table tt_user_company_permission add ucp_cross_orders_cancel_resting byte null
go
alter table tt_user_company_permission add ucp_organization varchar(128) null
go
alter table tt_user_company_permission add ucp_xrisk_sods_allowed byte null
go
alter table tt_user_company_permission add ucp_xrisk_manual_fills_allowed byte null
go
alter table tt_user_company_permission add ucp_allow_trading byte null
go
alter table tt_user_company_permission add ucp_ttapi_allowed byte not null default 1
go
alter table tt_user_company_permission add ucp_undefined_accounts_allowed byte not null default 0
go
alter table tt_user_company_permission add ucp_account_changes_allowed byte not null default 0
go
alter table tt_user_company_permission add ucp_wholesale_orders_with_undefined_accounts_allowed byte null
go
alter table tt_user_company_permission add ucp_account_permissions_enabled byte null
go


update tt_user_company_permission set 
  ucp_billing1 = '',
  ucp_billing2 = '',
  ucp_billing3 = '',
  ucp_fix_adapter_default_editing_allowed = 1,
  ucp_cross_orders_allowed = 1,
  ucp_wholesale_trades_allowed = 1,
  ucp_persist_orders_on_eurex = 0,
  ucp_prevent_orders_based_on_price_ticks = 0,
  ucp_prevent_orders_price_ticks = 0,
  ucp_enforce_price_limit_on_buysell_only = 1,
  ucp_prevent_orders_based_on_rate = 0,
  ucp_prevent_orders_rate = 0,
  ucp_dma_order_creation_allowed = 1,
  ucp_fix_dma_order_creation_allowed = 1,
  ucp_gtc_orders_allowed = 1,
  ucp_cross_orders_cancel_resting = 1,
  ucp_organization = '',
  ucp_xrisk_sods_allowed = 0,
  ucp_xrisk_manual_fills_allowed = 0,
  ucp_allow_trading = 1,
  ucp_ttapi_allowed = 1,
  ucp_undefined_accounts_allowed = 1,
  ucp_account_changes_allowed = 1,
  ucp_account_permissions_enabled = CByte(0)
go

update tt_user_company_permission
    set ucp_wholesale_orders_with_undefined_accounts_allowed = CByte(1)
    where tt_user_company_permission.ucp_id in
      ( select tt_user_company_permission.ucp_id
            from (( tt_user_company_permission
            inner join tt_user on tt_user_company_permission.ucp_user_id = tt_user.user_id )
            inner join tt_user_group on tt_user.user_group_id = tt_user_group.ugrp_group_id )
            inner join tt_company on tt_user_group.ugrp_comp_id = tt_company.comp_id
            where tt_company.comp_is_broker = CByte(1)
      )
go
 
-------------------------------------------------------------------------------
--  Product Type
-------------------------------------------------------------------------------

alter table tt_product_type add should_ignore_max_long_short byte default 0 not null;
go
update tt_product_type set should_ignore_max_long_short = 0;
go
update tt_product_type set should_ignore_max_long_short = 1
where product_description in ('SPREAD', 'STRATEGY');
go

insert into tt_product_type values( 'INTER-PRODUCT SPREAD', 515, 0 )
go
insert into tt_product_type values( 'INTER-PRODUCT STRATEGY', 516, 0 )
go

-----------------------------------------------------------------------
--  tt_customer_default
-----------------------------------------------------------------------

alter table tt_customer_default add cusd_on_behalf_of_user_id int not null
go

alter table tt_customer_default add cusd_on_behalf_of_account_id int not null
go

alter table tt_customer_default add cusd_default_gmgt_id int not null
go

update tt_customer_default set
  cusd_on_behalf_of_user_id = 0,
  cusd_on_behalf_of_account_id = 1,
  cusd_default_gmgt_id = 0
go

-------------------------------------------------------------------------------
--  Country
-------------------------------------------------------------------------------

alter table tt_country add country_display_order int not null;
go

update tt_country set country_display_order = 0;
go

update tt_country set country_display_order = 1 where country_name = '<None>';
go
update tt_country set country_display_order = 20 where country_name = 'AUSTRALIA';
go
update tt_country set country_display_order = 30 where country_name = 'BRAZIL';
go
update tt_country set country_display_order = 40 where country_name = 'CANADA';
go
update tt_country set country_display_order = 50 where country_name = 'GERMANY';
go
update tt_country set country_display_order = 60 where country_name = 'HONG KONG';
go
update tt_country set country_display_order = 70 where country_name = 'JAPAN';
go
update tt_country set country_display_order = 80 where country_name = 'SINGAPORE';
go
update tt_country set country_display_order = 90 where country_name = 'SWITZERLAND';
go
update tt_country set country_display_order = 100 where country_name = 'UNITED KINGDOM';
go
update tt_country set country_display_order = 110 where country_name = 'UNITED STATES';
go

-------------------------------------------------------------------------------
-- tt_db_version
-------------------------------------------------------------------------------

alter table tt_db_version add dbv_txn_billing byte not null
go

update tt_db_version set
dbv_txn_billing = 0
go


alter table tt_db_version add dbv_last_notification_sequence_number2 int not null
go

update tt_db_version set
dbv_last_notification_sequence_number2 = 1
go

-------------------------------------------------------------------------------
-- ip address version
-------------------------------------------------------------------------------

create index index_ip_address_version_login on tt_ip_address_version 
(
ipv_user_login
) 
go

alter table tt_ip_address_version add ipv_lang_id int not null
go

update tt_ip_address_version set ipv_lang_id = 0
go

-------------------------------------------------------------------------------
-- account default
-------------------------------------------------------------------------------

alter table tt_account_default add acctd_comp_id int not null
go

update tt_account_default set acctd_comp_id = 0
go

alter table tt_account_default drop constraint index_account_default_key
go

create unique index index_account_default_key on tt_account_default (acctd_user_id, acctd_comp_id, acctd_account_id, acctd_market_id, acctd_gateway_id, acctd_product_type)
go

alter table tt_account_default add constraint fk_acctd_company foreign key (acctd_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go

drop index index_account_default_user_seq on tt_account_default
go

create unique index index_account_default_user_seq on tt_account_default (acctd_user_id, acctd_comp_id, acctd_sequence_number)
go

-------------------------------------------------------------------------------
-- Account Group
-------------------------------------------------------------------------------
alter table tt_account_group add ag_risk_enabled_for_wholesale_trades byte not null default 0
go

update tt_account_group set ag_risk_enabled_for_wholesale_trades = CByte(0)
go


-------------------------------------------------------------------------------
--  tt_user_account
-------------------------------------------------------------------------------

create table tt_user_account
(
  uxa_user_account_id                      counter       not null primary key,
  uxa_created_datetime                     datetime      not null,
  uxa_created_user_id                      int           not null,
  uxa_last_updated_datetime                datetime      not null,
  uxa_last_updated_user_id                 int           not null,
  uxa_user_id                              int           not null,
  uxa_account_id                           int           not null,
  uxa_order_routing                        byte          not null,
  uxa_adl_order_routing                    byte          not null
)
go

create unique index index_unique_user_account_key on tt_user_account ( uxa_user_id, uxa_account_id )
go

alter table tt_user_account add constraint fk_user_account_user foreign key (uxa_user_id) references tt_user (user_id) ON DELETE CASCADE
go

alter table tt_user_account add constraint fk_user_account_account foreign key (uxa_account_id) references tt_account (acct_id) ON DELETE CASCADE
go

-------------------------------------------------------------------------------
-- password history
-------------------------------------------------------------------------------

alter table tt_password_history drop constraint fk_password_history_to_user
go

create table tt_password_history2
(
password_history_id                       counter      not null primary key,
password_history_created_datetime         datetime      not null,
password_history_created_user_id          int           not null,
password_history_last_updated_datetime    datetime      not null,
password_history_last_updated_user_id     int           not null,
password_history_user_id                  int          not null,
password_history_password                 varchar(100) not null
)
go

-- copy data to new table
insert into tt_password_history2
(
password_history_created_datetime,
password_history_created_user_id,
password_history_last_updated_datetime,
password_history_last_updated_user_id,
password_history_user_id, 
password_history_password 
)
select
password_history_created_datetime,
0,
password_history_created_datetime,
0,  
password_history_user_id,
password_history_password
from tt_password_history
go

alter table tt_password_history2 add constraint fk_password_history_to_user foreign key (password_history_user_id) references tt_user (user_id) ON DELETE CASCADE
go

create index index_user on tt_password_history2 (password_history_user_id)
go

-- drop old table
drop table tt_password_history
go


--- tt_company_company_permission
create table tt_company_company_permission
(
  ccp_id                                   counter      not null primary key,
  ccp_created_datetime                     datetime     not null,
  ccp_created_user_id                      int          not null,
  ccp_last_updated_datetime                datetime     not null,
  ccp_last_updated_user_id                 int          not null,
  ccp_broker_comp_id                       int          not null,
  ccp_buyside_comp_id                      int          not null
) 
go

create unique index index_buy_sell_permission_company_company on tt_company_company_permission (ccp_broker_comp_id, ccp_buyside_comp_id)
go

alter table tt_company_company_permission add constraint fk_company_company_permission_broker foreign key (ccp_broker_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go

alter table tt_company_company_permission add constraint fk_company_company_permission_buyside foreign key (ccp_buyside_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go

-------------------------------------------------------------------------------
-- login server settings
-------------------------------------------------------------------------------

update tt_login_server_settings set lss_enforce_ip_login_limit = CByte(0) where lss_multibroker_mode = CByte(1)
go

-------------------------------------------------------------------------------
-- work item
-------------------------------------------------------------------------------

drop table tt_work_item
go
create table tt_work_item
(
	wi_id                                   counter      not null primary key,
	wi_created_datetime                     datetime     not null,
	wi_created_user_id                      int          not null,
	wi_last_updated_datetime                datetime     not null,
	wi_last_updated_user_id                 int          not null,
	wi_created_by_comp_id                   int          not null,
	wi_assigned_to_comp_id                  int          not null,
	wi_attention_comp_id                    int          not null,
	wi_related_to_user_login                varchar(30) not null,
	wi_title                                varchar(255) not null,
	wi_comments                             memo  not null
)
go

alter table tt_work_item add constraint fk_created_by_comp_id foreign key (wi_created_by_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go
alter table tt_work_item add constraint fk_assigned_to_comp_id foreign key (wi_assigned_to_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go
alter table tt_work_item add constraint fk_attention_comp_id foreign key (wi_attention_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go


INSERT INTO tt_market_product_group
    ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id,
      mkpg_product_group_id, mkpg_product_group )
SELECT
    now, 0, now, 0, tt_market.market_id, 0, '<All Products>'
FROM ( tt_previously_heartbeating_gateways [phg]
INNER JOIN tt_gateway ON phg.phg_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id
WHERE tt_market.market_id NOT IN ( SELECT mkpg_market_id FROM tt_market_product_group )
GROUP BY
    tt_market.market_id
go

-------------------------------------------------------------------------------
-- for generated mgt feature
delete from tt_previously_heartbeating_gateways where phg_product <> 2
go

update tt_mgt set mgt_enable_sods = 1 where mgt_member = 'TTADM' and mgt_group = 'XXX' and mgt_trader in ( 'MGR', 'VIEW' )
go

-------------------------------------------------------------------------------
-- include views (always in latest upgrade script only)
-------------------------------------------------------------------------------

#include views.sql


-- populate most_recent_login_ip, most_recent_xt_version
create table delete_me
(
login varchar(20) not null,
version varchar(15) not null,
ip varchar(15) not null
)
go

insert into delete_me (login, version, ip)
select ipv_user_login, ipv_version, ipv_ip_address from tt_view_max_x_trader_user_date2
go

UPDATE distinctrow tt_user
inner join delete_me on tt_user.user_login = delete_me.login
set 
tt_user.user_most_recent_xt_version = delete_me.version,
tt_user.user_most_recent_login_ip = delete_me.ip
go

drop table delete_me
go

-------------------------------------------------------------------------------
-- Customer Default OBO auto-population
-------------------------------------------------------------------------------
CREATE TABLE temp1 ( cusd_id int, mgt_id int, user_id int, acct_id int )
go

INSERT INTO temp1
    SELECT
        tt_customer_default.cusd_id, tt_mgt.mgt_id, max( proxy_user.user_id ) AS [user_id], tt_account.acct_id
    FROM ((((((((((( tt_user
    INNER JOIN tt_customer_default ON tt_user.user_id = tt_customer_default.cusd_user_id )
    INNER JOIN tt_account ON tt_customer_default.cusd_account_id = tt_account.acct_id )
    INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
    INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
    INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id )
    INNER JOIN tt_mgt ON tt_mgt_gmgt.mxg_mgt_id = tt_mgt.mgt_id )
    INNER JOIN tt_gmgt AS proxy_gmgt ON tt_mgt.mgt_member = proxy_gmgt.gm_member AND tt_mgt.mgt_group = proxy_gmgt.gm_group AND tt_mgt.mgt_trader = proxy_gmgt.gm_trader )
    INNER JOIN tt_mgt AS proxy_mgt ON proxy_gmgt.gm_member = proxy_mgt.mgt_member AND proxy_gmgt.gm_group = proxy_mgt.mgt_group AND proxy_gmgt.gm_trader = proxy_mgt.mgt_trader )
    INNER JOIN tt_user_gmgt AS proxy_user_gmgt ON proxy_gmgt.gm_id = proxy_user_gmgt.uxg_gmgt_id )
    INNER JOIN tt_user AS proxy_user ON proxy_user_gmgt.uxg_user_id = proxy_user.user_id )
    LEFT JOIN tt_gateway ON tt_customer_default.cusd_market_id = tt_gateway.gateway_market_id )
    WHERE tt_account.acct_name <> ''
        AND ( tt_customer_default.cusd_on_behalf_of_mgt_id = 0 OR tt_customer_default.cusd_on_behalf_of_user_id = 0 )
        AND LEFT( tt_gmgt.gm_member, 5 ) NOT IN ( 'TTADM', 'TTORD' )
        AND tt_gmgt.gm_gateway_id = proxy_gmgt.gm_gateway_id
        AND LEFT( proxy_gmgt.gm_member, 5 ) = 'TTORD'
        AND ( tt_gateway.gateway_id = -1 OR tt_gateway.gateway_id = tt_gmgt.gm_gateway_id )
        AND tt_account.acct_mgt_id = tt_mgt.mgt_id
    GROUP BY
        tt_customer_default.cusd_id, tt_mgt.mgt_id, tt_account.acct_id
go

UPDATE tt_customer_default
INNER JOIN temp1 ON tt_customer_default.cusd_id = temp1.cusd_id
SET tt_customer_default.cusd_on_behalf_of_mgt_id = temp1.mgt_id,
    tt_customer_default.cusd_on_behalf_of_user_id = temp1.user_id,
    tt_customer_default.cusd_on_behalf_of_account_id = temp1.acct_id
go

DROP TABLE temp1
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.000.000'
go

