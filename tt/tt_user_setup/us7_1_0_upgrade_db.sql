update tt_db_version set dbv_version = 'converting to 7.1.0'
go

-- drop fks
alter table tt_account drop constraint fk_account_to_trader
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


alter table tt_login_server_settings add lss_apply_additional_failed_login_msg     byte         not null
go
alter table tt_login_server_settings add lss_additional_failed_login_msg_text      varchar(255) not null
go

update tt_login_server_settings set 
lss_apply_additional_failed_login_msg = 0, 
lss_additional_failed_login_msg_text = '<Any text, e.g., For assistance, please contact Trader Support at 1-555-555-HELP or email help@example.com>'
go


-- changing from char to varchar
alter table tt_x_trader_mode drop column x_trader_mode_name
go
alter table tt_x_trader_mode add x_trader_mode_name varchar(20) not null
go

-- get rid of special characters.  Now handled by client.
update tt_x_trader_mode set x_trader_mode_name = '<N/A>' where x_trader_mode_id = 0
go
update tt_x_trader_mode set x_trader_mode_name = 'X_TRADER' where x_trader_mode_id = 1
go
update tt_x_trader_mode set x_trader_mode_name = 'X_TRADER Pro' where x_trader_mode_id = 2
go
update tt_x_trader_mode set x_trader_mode_name = 'TT_TRADER' where x_trader_mode_id = 3
go

update tt_user set user_x_trader_mode = 0 where user_x_trader_mode = 3
go
delete from tt_x_trader_mode where x_trader_mode_id = 3
go

create unique index unique_trader_mode_name on tt_x_trader_mode (x_trader_mode_name)
go

create unique index unique_state_long_name on tt_us_state (state_long_name)
go

drop table tt_name_value_pair
go
create table tt_name_value_pair
(
nvp_id                                     counter      not null primary key,
nvp_created_datetime                       datetime     not null,
nvp_created_user_id                        int          not null,
nvp_last_updated_datetime                  datetime     not null,
nvp_last_updated_user_id                   int          not null,
nvp_name                                   varchar(30)  not null,
nvp_value                                  varchar(30)  not null
)
go

create unique index unique_nvp_name on tt_name_value_pair (nvp_name)
go


drop table tt_trader
go
create table tt_trader
(
trdr_id                                    counter      not null primary key,
trdr_created_datetime                      datetime     not null,
trdr_created_user_id                       int          not null,
trdr_last_updated_datetime                 datetime     not null,
trdr_last_updated_user_id                  int          not null,

-- max sizes because of guardian
trdr_member                                varchar(7)   not null,
trdr_group                                 varchar(3)   not null,
trdr_trader                                varchar(11)  not null,
trdr_description                           varchar(11)  not null,

trdr_credit                                int          not null,
trdr_currency                              varchar(3)   not null,
trdr_allow_trading                         byte         not null,
trdr_ignore_pl                             byte         not null,

trdr_risk_on                               byte         not null,
trdr_publish_to_guardian                   byte         not null,
trdr_mgt_key                               varchar(25)  not null,
trdr_password                              varchar(100) not null
)
go

create unique index unique_trader on tt_trader (trdr_mgt_key)
go

drop table tt_trader_mgt
go
create table tt_trader_mgt
(
tmgt_id                                   counter      not null primary key,
tmgt_created_datetime                     datetime     not null,
tmgt_created_user_id                      int          not null,
tmgt_last_updated_datetime                datetime     not null,
tmgt_last_updated_user_id                 int          not null,
tmgt_trader_id                            int          not null,
tmgt_mgt_id                               int          not null
)
go

create unique index unique_trader_mgt on tt_trader_mgt (tmgt_trader_id, tmgt_mgt_id)
go

create index index_trader_mgt on tt_trader_mgt (tmgt_mgt_id)
go

drop table tt_product_limit
go
create table tt_product_limit
(
plim_product_limit_id                      counter      not null primary key,
plim_created_datetime                      datetime     not null,
plim_created_user_id                       int          not null,
plim_last_updated_datetime                 datetime     not null,
plim_last_updated_user_id                  int          not null,
-- key
plim_trader_id                             int          not null,
plim_gateway_id                            int          not null,
plim_product                               varchar(20)  not null,
plim_product_type                          int          not null,
-- data
plim_additional_margin_pct                 int          not null,
plim_max_order_qty                         int          not null,
plim_max_position                          int          not null,
plim_allow_tradeout                        byte         not null,
plim_max_long_short                        int          not null,

plim_product_in_hex                        varchar(40)  not null
)
go

create index index_product_limit_trader_id on tt_product_limit (plim_trader_id)
go
create unique index index_product_limit_key on tt_product_limit (plim_trader_id, plim_gateway_id, plim_product_in_hex, plim_product_type)
go


alter table tt_mgt add mgt_gateway_mgt_key                       varchar(30)  not null
go

update tt_mgt set mgt_gateway_mgt_key = CSTR(mgt_gateway_id) + ";" + mgt_member + mgt_group + mgt_trader
go

alter table tt_mgt drop constraint unique_gmt 
go

alter table tt_mgt drop constraint index_mgt_gateway_id
go

-- to handle TTSIM,12,34 versus TTSIM,1,234
create unique index unique_mgt_gateway_mgt_key on tt_mgt (mgt_gateway_mgt_key)
go

create unique index unique_mgt_gateway_mgt on tt_mgt (mgt_gateway_id, mgt_member, mgt_group, mgt_trader)
go

-- non unique
create index index_mgt_member_group_trader on tt_mgt (mgt_member, mgt_group, mgt_trader)
go

alter table tt_user drop column user_restrict_account_default_editing
go

alter table tt_user add user_fix_adapter_allowed                  byte         not null
go
alter table tt_user add user_fix_adapter_enable_order_logging     byte         not null
go
alter table tt_user add user_fix_adapter_enable_price_logging     byte         not null
go
alter table tt_user add user_fix_adapter_default_editing_allowed  byte         not null
go
alter table tt_user add user_xrisk_allowed                        byte         not null
go
alter table tt_user add user_xrisk_sods_allowed                   byte         not null
go
alter table tt_user add user_xrisk_manual_fills_allowed           byte         not null
go
alter table tt_user add user_xrisk_prices_allowed                 byte         not null
go
alter table tt_user add user_xrisk_instant_messages_allowed       byte         not null
go
alter table tt_user add user_cross_orders_allowed                 byte         not null
go

update tt_user set 
user_fix_adapter_allowed = 0,
user_fix_adapter_enable_order_logging = 0,
user_fix_adapter_enable_price_logging = 0,
user_fix_adapter_default_editing_allowed = 0,
user_xrisk_allowed = 0,
user_xrisk_sods_allowed = 0,
user_xrisk_manual_fills_allowed = 0,
user_xrisk_prices_allowed = 0,
user_xrisk_instant_messages_allowed = 0,
user_cross_orders_allowed = 1
go

alter table tt_user_mgt add umgt_available_to_user                    byte         not null
go

update tt_user_mgt set umgt_available_to_user = 1
go

alter table tt_user_mgt drop constraint index_umgt_user_id
go

create unique index index_umgt_user_id on tt_user_mgt (umgt_user_id, umgt_mgt_id)
go

drop table tt_trade_filter_match_field
go
create table tt_trade_filter_match_field
(
match_field_name                           varchar(30) not null primary key,
match_field_id                             int not null
) 
go

create unique index unique_match_field_id on tt_trade_filter_match_field (match_field_id)
go


alter table tt_account add acct_description                          varchar(100) not null
go
alter table tt_account add acct_trader_id                            int          not null
go

create unique index unique_ordrest_long_description on tt_order_restriction (ordrest_long_description)
go

create unique index unique_ordrest_short_description on tt_order_restriction (ordrest_short_description)
go


create unique index unique_ordertype_description on tt_order_type (ordertype_description)
go

create unique index unique_ordertype_code on tt_order_type (ordertype_code)
go


create unique index unique_timeInForce_code on tt_time_in_force (timeInForce_code)
go

create unique index unique_timeInForce_description on tt_time_in_force (timeInForce_description)
go


create unique index unique_openClose_description on tt_open_close_code (openClose_description)
go

create unique index unique_openClose_coden on tt_open_close_code (openClose_code)
go


alter table tt_customer_default alter cusd_product varchar(20)  not null
go

alter table tt_customer_default add cusd_product_in_hex                       varchar(40)  not null
go

alter table tt_customer_default drop constraint index_customer_default_key
go
create unique index index_customer_default_key on tt_customer_default (cusd_user_id, cusd_customer, cusd_market_id, cusd_product_in_hex, cusd_product_type)
go

alter table tt_account_default add acctd_sequence_number                      int          not null
go

create unique index index_account_default_user_seq on tt_account_default (acctd_user_id, acctd_sequence_number)
go

drop table tt_trade_filter
go
create table tt_trade_filter
(
tflt_id                                    counter      not null primary key,

tflt_created_datetime                      datetime     not null,
tflt_created_user_id                       int          not null,
tflt_last_updated_datetime                 datetime     not null,
tflt_last_updated_user_id                  int          not null,

tflt_user_id                               int          not null,
tflt_gateway_id                            int          not null,
tflt_member                                varchar(7)   not null,
tflt_group                                 varchar(3)   not null,
tflt_trader                                varchar(11)  not null,
tflt_match_mgt_with_which_fields           int          not null
)
go

create index index_trade_filter_user_id on tt_trade_filter (tflt_user_id)
go

create unique index index_trade_filter_key on tt_trade_filter (tflt_user_id , tflt_gateway_id, tflt_member, tflt_group, tflt_trader, tflt_match_mgt_with_which_fields)
go


alter table tt_account add constraint fk_account_to_trader foreign key (acct_trader_id) references tt_trader (trdr_id) ON DELETE CASCADE
go

alter table tt_product_limit add constraint fk_product_limit_to_gateway foreign key (plim_gateway_id) references tt_gateway (gateway_id) ON DELETE CASCADE
go
alter table tt_product_limit add constraint fk_product_limit_to_trader foreign key (plim_trader_id) references tt_trader (trdr_id) ON DELETE CASCADE
go
alter table tt_trade_filter add constraint fk_trade_filter_to_gateway foreign key (tflt_gateway_id) references tt_gateway (gateway_id) ON DELETE CASCADE
go
alter table tt_trade_filter add constraint fk_trade_filter_to_match_field foreign key (tflt_match_mgt_with_which_fields) references tt_trade_filter_match_field (match_field_id) ON DELETE CASCADE  
go
alter table tt_trade_filter add constraint fk_trade_filter_to_user foreign key (tflt_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_trader_mgt add constraint fk_trader_mgt_to_mgt foreign key (tmgt_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go
alter table tt_trader_mgt add constraint fk_trader_mgt_to_trader foreign key (tmgt_trader_id) references tt_trader (trdr_id) ON DELETE CASCADE
go


-- Trade Filter Match Type
insert into tt_trade_filter_match_field values('*',1) 
go
insert into tt_trade_filter_match_field values('TTORD ID',2) 
go
insert into tt_trade_filter_match_field values('Exchange Trader ID',3) 
go


insert into tt_product_type values('NDF', 33)
go


-- this is needed for trade filter
insert into tt_gateway (gateway_id, gateway_name, gateway_market_id) values (-1,'*',-1) 
go

-- Markets, gateways,....

insert into tt_market (market_id, market_name) values (0,'<None>')
go
insert into tt_gateway (gateway_id, gateway_name, gateway_market_id) values (0,'<None>',0)
go


-- for accounts fk constraint
insert into tt_trader values(0,now,1,now,1,
'<None>','','','<None>',
0,'USD',0,0,0,0,'<None>', '')
go

update tt_account set
acct_description = '',
acct_trader_id = 0
go


insert into tt_name_value_pair
(nvp_created_datetime,
nvp_created_user_id,
nvp_last_updated_datetime,
nvp_last_updated_user_id,
nvp_name,
nvp_value)
values (now,1,now,1,"1st guardian import done","false")
go

insert into tt_name_value_pair
(nvp_created_datetime,
nvp_created_user_id,
nvp_last_updated_datetime,
nvp_last_updated_user_id,
nvp_name,
nvp_value)
values (now,1,now,1,"multibroker mode","false")
go

insert into tt_name_value_pair
(nvp_created_datetime,
nvp_created_user_id,
nvp_last_updated_datetime,
nvp_last_updated_user_id,
nvp_name,
nvp_value)
values (now,1,now,1,"use ttus risk","")
go

update tt_customer_default set cusd_customer = UCase(cusd_customer)
go


insert into tt_open_close_code values('FIFO','F')
go
insert into tt_order_type values('BL','S')
go
insert into tt_order_type values('MTL','T')
go
insert into tt_order_restriction values('IT', chr(200),  'If Touched')
go
insert into tt_order_restriction values('MLM', 'm', 'Market Limit')
go

update tt_market set market_name = 'EBS' where market_id = 83
go

-- intentionally not updating version table yet, because UserSetupUtil.exe has to update product hex fields.
