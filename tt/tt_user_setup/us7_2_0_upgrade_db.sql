update tt_db_version set dbv_version = 'converting to 7.2.0'
go

-- drop old constraints

alter table tt_account drop constraint fk_account_to_trader
go
alter table tt_account_default drop constraint fk_acctd_to_account
go
alter table tt_account_default drop constraint fk_acctd_to_account_type
go
alter table tt_account_default drop constraint fk_acctd_to_market
go
alter table tt_account_default drop constraint fk_acctd_to_product_type
go
alter table tt_account_default drop constraint fk_acctd_to_user
go
alter table tt_customer_default drop constraint fk_custd_to_account
go
alter table tt_customer_default drop constraint fk_custd_to_account_type
go
alter table tt_customer_default drop constraint fk_custd_to_market
go
alter table tt_customer_default drop constraint fk_custd_to_open_close
go
alter table tt_customer_default drop constraint fk_custd_to_order_restriction
go
alter table tt_customer_default drop constraint fk_custd_to_order_type
go
alter table tt_customer_default drop constraint fk_custd_to_product_type
go
alter table tt_customer_default drop constraint fk_custd_to_time_in_force
go
alter table tt_customer_default drop constraint fk_custd_to_user
go
alter table tt_gateway drop constraint fk_gateway_to_market
go
alter table tt_mgt drop constraint fk_mgt_to_gateway
go
alter table tt_password_history drop constraint fk_password_history_to_user
go
alter table tt_product_limit drop constraint fk_product_limit_to_gateway
go
alter table tt_product_limit drop constraint fk_product_limit_to_trader
go
alter table tt_trade_filter drop constraint fk_trade_filter_to_gateway
go
alter table tt_trade_filter drop constraint fk_trade_filter_to_match_field
go
alter table tt_trade_filter drop constraint fk_trade_filter_to_user
go
alter table tt_trader_mgt drop constraint fk_trader_mgt_to_mgt
go
alter table tt_trader_mgt drop constraint fk_trader_mgt_to_trader
go
alter table tt_user drop constraint fk_user_to_country
go
alter table tt_user drop constraint fk_user_to_email_account
go
alter table tt_user drop constraint fk_user_to_group
go
alter table tt_user drop constraint fk_user_to_state
go
alter table tt_user drop constraint fk_user_to_x_trader_mode
go
alter table tt_user_mgt drop constraint fk_user_mgt_to_mgt
go
alter table tt_user_mgt drop constraint fk_user_mgt_to_user
go

-----------------------------------------------------------------------
-- convert tt_mgt to tt_gmgt
-----------------------------------------------------------------------
create table tt_gmgt
(
gm_id                                    counter      not null primary key,
gm_created_datetime                      datetime     not null,
gm_created_user_id                       int          not null,
gm_last_updated_datetime                 datetime     not null,
gm_last_updated_user_id                  int          not null,
gm_gateway_id                            int          not null,
gm_member                                varchar(7)   not null,
gm_group                                 varchar(3)   not null,
gm_trader                                varchar(11)  not null,
gm_gateway_mgt_key                       varchar(30)  not null
)
go

insert into tt_gmgt (
gm_id,
gm_created_datetime,
gm_created_user_id,
gm_last_updated_datetime,
gm_last_updated_user_id,
gm_gateway_id,
gm_member,
gm_group,
gm_trader,
gm_gateway_mgt_key
)
select 
mgt_id,
mgt_created_datetime,
mgt_created_user_id,
mgt_last_updated_datetime,
mgt_last_updated_user_id,
mgt_gateway_id,
mgt_member,
mgt_group,
mgt_trader,
mgt_gateway_mgt_key
from tt_mgt
go

-- to handle TTSIM,12,34 versus TTSIM,1,234
create unique index unique_gmgt_gateway_mgt_key on tt_gmgt (gm_gateway_mgt_key)
go

create unique index unique_gmgt_gateway_mgt on tt_gmgt (gm_gateway_id, gm_member, gm_group, gm_trader)
go

-- non unique
create index index_mgt_member_group_trader on tt_gmgt (gm_member, gm_group, gm_trader)
go

drop table tt_mgt
go


-----------------------------------------------------------------------
-- convert tt_trader to tt_mgt
-----------------------------------------------------------------------

create table tt_mgt
(
mgt_id                                    counter      not null primary key,
mgt_created_datetime                      datetime     not null,
mgt_created_user_id                       int          not null,
mgt_last_updated_datetime                 datetime     not null,
mgt_last_updated_user_id                  int          not null,

-- max sizes because of guardian
mgt_member                                varchar(7)   not null,
mgt_group                                 varchar(3)   not null,
mgt_trader                                varchar(11)  not null,
mgt_description                           varchar(11)  not null,

mgt_credit                                int          not null,
mgt_currency                              varchar(3)   not null,
mgt_allow_trading                         byte         not null,
mgt_ignore_pl                             byte         not null,

mgt_risk_on                               byte         not null,
mgt_publish_to_guardian                   byte         not null,
mgt_mgt_key                               varchar(25)  not null,
mgt_password                              varchar(100) not null
)
go


insert into tt_mgt (
mgt_id,
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
mgt_password
)
select 
trdr_id,
trdr_created_datetime,
trdr_created_user_id,
trdr_last_updated_datetime,
trdr_last_updated_user_id,
trdr_member,
trdr_group,
trdr_trader,
trdr_description,
trdr_credit,
trdr_currency,
trdr_allow_trading,
trdr_ignore_pl,
trdr_risk_on,
trdr_publish_to_guardian,
trdr_mgt_key,
trdr_password
from tt_trader
go

create unique index unique_trader on tt_mgt (mgt_mgt_key)
go

drop table tt_trader
go

-----------------------------------------------------------------------
-- convert tt_trader_mgt to tt_mgt_gmgt
-----------------------------------------------------------------------

create table tt_mgt_gmgt
(
mxg_id                                   counter      not null primary key,
mxg_created_datetime                     datetime     not null,
mxg_created_user_id                      int          not null,
mxg_last_updated_datetime                datetime     not null,
mxg_last_updated_user_id                 int          not null,
mxg_mgt_id                               int          not null,
mxg_gmgt_id                              int          not null
)
go

insert into tt_mgt_gmgt (
mxg_id,
mxg_created_datetime,
mxg_created_user_id,
mxg_last_updated_datetime,
mxg_last_updated_user_id,
mxg_mgt_id,
mxg_gmgt_id
)
select
tmgt_id,
tmgt_created_datetime,
tmgt_created_user_id,
tmgt_last_updated_datetime,
tmgt_last_updated_user_id,
tmgt_trader_id,
tmgt_mgt_id
from tt_trader_mgt
go

create unique index unique_mgt_gmgt on tt_mgt_gmgt (mxg_mgt_id, mxg_gmgt_id)
go

create index index_mxg on tt_mgt_gmgt (mxg_gmgt_id)
go

drop table tt_trader_mgt
go


-----------------------------------------------------------------------
-- convert tt_user_mgt to tt_user_gmgt
-----------------------------------------------------------------------


create table tt_user_gmgt
(
uxg_user_gmgt_id                         counter      not null primary key,
uxg_created_datetime                     datetime     not null,
uxg_created_user_id                      int          not null,
uxg_last_updated_datetime                datetime     not null,
uxg_last_updated_user_id                 int          not null,
uxg_user_id                              int          not null,
uxg_gmgt_id                               int          not null,
uxg_automatically_login                  byte         not null,
uxg_preferred_ip                         varchar(15)  not null,
uxg_clearing_member                      varchar(11)  not null,
uxg_default_account                      varchar(2)   not null,
uxg_available_to_user                    byte         not null
)
go

insert into tt_user_gmgt (
uxg_user_gmgt_id,
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
uxg_available_to_user
)
select 
umgt_user_mgt_id,
umgt_created_datetime,
umgt_created_user_id,
umgt_last_updated_datetime,
umgt_last_updated_user_id,
umgt_user_id,
umgt_mgt_id,
umgt_automatically_login,
umgt_preferred_ip,
umgt_clearing_member,
umgt_default_account,
umgt_available_to_user
from tt_user_mgt
go

create unique index index_uxg_user_id on tt_user_gmgt (uxg_user_id, uxg_gmgt_id)
go

create index index_uxg_gmgt_id on tt_user_gmgt (uxg_gmgt_id)
go

drop table tt_user_mgt
go


-----------------------------------------------------------------------
-- add new tables
-----------------------------------------------------------------------

create table tt_user_group_permission
(
ugp_id                                   counter      not null primary key,
ugp_created_datetime                     datetime     not null,
ugp_created_user_id                      int          not null,
ugp_last_updated_datetime                datetime     not null,
ugp_last_updated_user_id                 int          not null,
ugp_user_id                              int          not null,
ugp_group_id                             int          not null,
ugp_automatically_add                    byte         not null
) 
go

create unique index index_user_group_permission_user_group on tt_user_group_permission (ugp_user_id, ugp_group_id)
go

create table tt_account_group_permission
(
agp_id                                   counter      not null primary key,
agp_created_datetime                     datetime     not null,
agp_created_user_id                      int          not null,
agp_last_updated_datetime                datetime     not null,
agp_last_updated_user_id                 int          not null,
agp_account_id                           int          not null,
agp_group_id                             int          not null
) 
go

create unique index index_account_group_permission_account_group on tt_account_group_permission (agp_account_id, agp_group_id)
go


create table tt_mgt_group_permission
(
mgp_id                                   counter      not null primary key,
mgp_created_datetime                     datetime     not null,
mgp_created_user_id                      int          not null,
mgp_last_updated_datetime                datetime     not null,
mgp_last_updated_user_id                 int          not null,
mgp_mgt_id                               int          not null,
mgp_group_id                             int          not null
) 
go

create unique index index_mgt_group_permission_mgt_group on tt_mgt_group_permission (mgp_mgt_id, mgp_group_id)
go


create table tt_user_setup_user_type
(
utype_id                                  int          not null primary key,
utype_description                         varchar(50)  not null
)
go

-- insert initial data

insert into tt_user_setup_user_type values(0, '')
go
insert into tt_user_setup_user_type values(1, 'Super Admin')
go
insert into tt_user_setup_user_type values(2, 'Group Admin')
go
insert into tt_user_setup_user_type values(3, 'Group Admin (can create non-TTORDS)')
go
insert into tt_user_setup_user_type values(4, 'Password Admin (restricted)')
go
insert into tt_user_setup_user_type values(5, 'Password Admin (all groups)')
go


-----------------------------------------------------------------------
-- add new fields to user, drop old stuff
-----------------------------------------------------------------------

alter table tt_user add user_user_setup_user_type                 int          not null
go
alter table tt_user add user_smtp_host                            varchar(100) not null
go
alter table tt_user add user_smtp_port                            int          not null
go
alter table tt_user add user_smtp_requires_authentication         byte         not null
go
alter table tt_user add user_smtp_login_user                      varchar(100) not null
go
alter table tt_user add user_smtp_login_password                  varchar(100) not null
go
alter table tt_user add user_smtp_use_ssl                         byte         not null
go
alter table tt_user add user_smtp_from_address                    varchar(100) not null
go
alter table tt_user add user_smtp_subject                         varchar(100) not null
go
alter table tt_user add user_smtp_body                            varchar(255) not null
go
alter table tt_user add user_smtp_include_username_in_message     byte         not null
go

alter table tt_user add user_smtp_enable_settings                 byte         not null
go
alter table tt_user add user_quoting_allowed                      byte         not null
go
alter table tt_user add user_wholesale_trades_allowed             byte         not null
go
alter table tt_user add user_fmds_allowed                         byte         not null
go


update tt_user set user_user_setup_user_type = user_is_admin
go

alter table tt_user drop column user_is_admin
go

update tt_user set 
user_smtp_host = '',
user_smtp_port = 25,
user_smtp_requires_authentication = 0,
user_smtp_login_user = '',
user_smtp_login_password = '',
user_smtp_use_ssl = 0,
user_smtp_from_address = '',
user_smtp_subject = '',
user_smtp_body = '',
user_smtp_include_username_in_message = 0,
user_quoting_allowed = 1,
user_wholesale_trades_allowed = 1,
user_fmds_allowed = 1
go

UPDATE tt_user INNER JOIN tt_email_account ON tt_user.user_email_account = tt_email_account.emac_id SET
tt_user.user_smtp_host = tt_email_account.emac_host,
tt_user.user_smtp_port = tt_email_account.emac_port,
tt_user.user_smtp_requires_authentication = tt_email_account.emac_requires_authentication,
tt_user.user_smtp_login_user = tt_email_account.emac_login_user,
tt_user.user_smtp_login_password = tt_email_account.emac_login_password,
tt_user.user_smtp_use_ssl = tt_email_account.emac_use_ssl,
tt_user.user_smtp_from_address = tt_email_account.emac_from_address,
tt_user.user_smtp_subject = tt_email_account.emac_subject,
tt_user.user_smtp_body = tt_email_account.emac_body,
tt_user.user_smtp_include_username_in_message = tt_email_account.emac_include_username_in_message,
tt_user.user_smtp_enable_settings = 1
where user_email_account <> 0
go

-- just 0 and 1 at conversion time
update tt_user set user_smtp_enable_settings = user_user_setup_user_type
go

-- turn OFF users who don't have settings
update tt_user set user_smtp_enable_settings = 0 where user_email_account = 0
go

drop table tt_email_account
go

alter table tt_user drop column user_email_account
go

-----------------------------------------------------------------------
-- 
-- tt_login_server_settings
-----------------------------------------------------------------------



alter table tt_login_server_settings add lss_initial_guardian_import_done          byte     not null
go
alter table tt_login_server_settings add lss_multibroker_mode                      byte     not null
go
alter table tt_login_server_settings add lss_use_ttus_risk_versus_guardian_risk    char(1)  not null
go

alter table tt_login_server_settings add lss_fmds_allowed                          byte         not null
go
alter table tt_login_server_settings add lss_fmds_primary_ip                       varchar(15)  not null
go
alter table tt_login_server_settings add lss_fmds_primary_port                     int          not null
go
alter table tt_login_server_settings add lss_fmds_primary_service                  int          not null
go
alter table tt_login_server_settings add lss_fmds_primary_timeout_in_secs          int          not null
go
alter table tt_login_server_settings add lss_fmds_secondary_ip                     varchar(15)  not null
go
alter table tt_login_server_settings add lss_fmds_secondary_port                   int          not null
go
alter table tt_login_server_settings add lss_fmds_secondary_service                int          not null
go
alter table tt_login_server_settings add lss_fmds_secondary_timeout_in_secs        int          not null
go

update tt_login_server_settings set
lss_initial_guardian_import_done = 0,
lss_multibroker_mode = 0,
lss_use_ttus_risk_versus_guardian_risk = ' ',
lss_fmds_allowed = 1,
lss_fmds_primary_ip = '',
lss_fmds_primary_port = 10200,
lss_fmds_primary_service = 250,
lss_fmds_primary_timeout_in_secs = 30,
lss_fmds_secondary_ip = '',
lss_fmds_secondary_port = 0,
lss_fmds_secondary_service = 0,
lss_fmds_secondary_timeout_in_secs = 0
go

update tt_login_server_settings set lss_initial_guardian_import_done = 1
where exists (select * from tt_name_value_pair where nvp_name = '1st guardian import done' and nvp_value = 'true')
go

update tt_login_server_settings set lss_multibroker_mode = 1
where exists (select * from tt_name_value_pair where nvp_name = 'multibroker mode' and nvp_value = 'true')
go

update tt_login_server_settings set lss_use_ttus_risk_versus_guardian_risk = 1
where exists (select * from tt_name_value_pair where nvp_name = 'use ttus risk' and nvp_value = 'true')
go

update tt_login_server_settings set lss_use_ttus_risk_versus_guardian_risk = 0
where exists (select * from tt_name_value_pair where nvp_name = 'use ttus risk' and nvp_value = 'false')
go

drop table tt_name_value_pair
go

-----------------------------------------------------------------------
-- account table
-----------------------------------------------------------------------

alter table tt_account add acct_mgt_id int not null
go

update tt_account set acct_mgt_id = acct_trader_id
go

alter table tt_account drop column acct_trader_id
go


-----------------------------------------------------------------------
-- product limit table
-----------------------------------------------------------------------

alter table tt_product_limit add plim_mgt_id int not null
go

update tt_product_limit set plim_mgt_id = plim_trader_id
go

alter table tt_product_limit drop constraint index_product_limit_trader_id
go

alter table tt_product_limit drop constraint index_product_limit_key
go

alter table tt_product_limit drop column plim_trader_id
go

create unique index index_product_limit_key on tt_product_limit (plim_mgt_id, plim_gateway_id, plim_product_in_hex, plim_product_type)
go

-----------------------------------------------------------------------
-- tt_mgt
-----------------------------------------------------------------------

alter table tt_mgt add mgt_can_associate_with_user_directly     byte         not null
go

update tt_mgt set mgt_can_associate_with_user_directly = 1
go

-----------------------------------------------------------------------

create unique index unique_product_id on tt_product_type (product_id)
go


update tt_user_group set ugrp_name = '<General>' where ugrp_name = '<None>'
go

-----------------------------------------------------------------------
-- get rid of passwords we don't need
-----------------------------------------------------------------------

-- TTORDs should never have passwords
update tt_mgt set mgt_password = '' 
where mgt_password <> ''
and (
Left(tt_mgt.mgt_member,5) = 'TTORD'
or tt_mgt.mgt_group = 'XXX'
or tt_mgt.mgt_trader = 'MGR'
or tt_mgt.mgt_group = 'VIEW'
)
go

-----------------------------------------------------------------------
-- add foreign key constraints
-----------------------------------------------------------------------

alter table tt_account add constraint fk_account_to_mgt foreign key (acct_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_account foreign key (acctd_account_id) references tt_account (acct_id) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_account_type foreign key (acctd_account_type) references tt_account_type (acctType_code) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_market foreign key (acctd_market_id) references tt_market (market_id) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_product_type foreign key (acctd_product_type) references tt_product_type (product_description) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_user foreign key (acctd_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_account foreign key (cusd_account_id) references tt_account (acct_id) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_account_type foreign key (cusd_account_type) references tt_account_type (acctType_code) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_market foreign key (cusd_market_id) references tt_market (market_id) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_open_close foreign key (cusd_open_close) references tt_open_close_code (openClose_description) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_order_restriction foreign key (cusd_restriction) references tt_order_restriction (ordrest_short_description) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_order_type foreign key (cusd_order_type) references tt_order_type (ordertype_description) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_product_type foreign key (cusd_product_type) references tt_product_type (product_description) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_time_in_force foreign key (cusd_time_in_force) references tt_time_in_force (timeInForce_code) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_user foreign key (cusd_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_gateway add constraint fk_gateway_to_market foreign key (gateway_market_id) references tt_market (market_id) ON DELETE CASCADE
go
alter table tt_gmgt add constraint fk_gmgt_to_gateway foreign key (gm_gateway_id) references tt_gateway (gateway_id) ON DELETE CASCADE
go
alter table tt_password_history add constraint fk_password_history_to_user foreign key (password_history_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_product_limit add constraint fk_product_limit_to_gateway foreign key (plim_gateway_id) references tt_gateway (gateway_id) ON DELETE CASCADE
go
alter table tt_product_limit add constraint fk_product_limit_to_mgt foreign key (plim_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go
alter table tt_product_limit add constraint fk_product_limit_to_product_type foreign key (plim_product_type) references tt_product_type (product_id) ON DELETE CASCADE
go
alter table tt_trade_filter add constraint fk_trade_filter_to_gateway foreign key (tflt_gateway_id) references tt_gateway (gateway_id) ON DELETE CASCADE
go
alter table tt_trade_filter add constraint fk_trade_filter_to_match_field foreign key (tflt_match_mgt_with_which_fields) references tt_trade_filter_match_field (match_field_id) ON DELETE CASCADE  
go
alter table tt_trade_filter add constraint fk_trade_filter_to_user foreign key (tflt_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_mgt_gmgt add constraint fk_mgt_gmgt_to_gmgt foreign key (mxg_gmgt_id) references tt_gmgt (gm_id) ON DELETE CASCADE
go
alter table tt_mgt_gmgt add constraint fk_mgt_gmgt_to_mgt foreign key (mxg_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_country foreign key (user_country_id) references tt_country (country_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_group foreign key (user_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_state foreign key (user_state_id) references tt_us_state (state_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_x_trader_mode foreign key (user_x_trader_mode) references tt_x_trader_mode (x_trader_mode_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_user_setup_user_type foreign key (user_user_setup_user_type) references tt_user_setup_user_type (utype_id) ON DELETE CASCADE
go
alter table tt_user_gmgt add constraint fk_user_gmgt_to_gmgt foreign key (uxg_gmgt_id) references tt_gmgt (gm_id) ON DELETE CASCADE
go
alter table tt_user_gmgt add constraint fk_user_gmgt_to_user foreign key (uxg_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_user_group_permission add constraint fk_user_group_permission_to_user foreign key (ugp_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_user_group_permission add constraint fk_user_group_permission_to_group foreign key (ugp_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go
alter table tt_account_group_permission add constraint fk_account_group_permission_to_account foreign key (agp_account_id) references tt_account (acct_id) ON DELETE CASCADE
go
alter table tt_account_group_permission add constraint fk_account_group_permission_to_group foreign key (agp_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go
alter table tt_mgt_group_permission add constraint fk_mgt_group_permission_to_mgt foreign key (mgp_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go
alter table tt_mgt_group_permission add constraint fk_mgt_group_permission_to_group foreign key (mgp_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go

-----------------------------------------------------------------------
-- Views
-----------------------------------------------------------------------

drop view tt_view_product_limits_and_traders
go
drop view tt_view_users_and_their_trader_relationships
go
drop view tt_view_user_trader_accounts
go
drop view tt_view_traders_and_trader_mgts
go
drop view tt_view_missing_umgts_users_with_traders
go
drop view tt_view_missing_umgts_what_users_have
go
drop view tt_view_missing_umgts_what_users_should_have
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.002.000.000'
go