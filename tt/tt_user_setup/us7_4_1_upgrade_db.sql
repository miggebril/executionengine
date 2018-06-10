update tt_db_version set dbv_version = 'converting to 7.4.1'
go

insert into tt_account_type values('A4',16,'Agent account type')
go
insert into tt_account_type values('A5',17,'Agent account type')
go
insert into tt_account_type values('A6',18,'Agent account type')
go
insert into tt_account_type values('A7',19,'Agent account type')
go
insert into tt_account_type values('A8',20,'Agent account type')
go
insert into tt_account_type values('A9',21,'Agent account type')
go

--[CME]
--CME=2
--NYMEX=3
--CBOT=4
--COMEX=5
--KCBT=6
--MGEX=7
--DME=8
--BVMF=9
--GreenX=10
--Bursa Malaysia=11
--DME-NYMEX=12
--MexDer=13
--KRX=14

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 2, 'CME')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 3, 'NYMEX')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 4, 'CBOT')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 5, 'COMEX')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 6, 'KCBT')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 7, 'MGEX')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 8, 'DME')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 9, 'BVMF')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 10, 'GreenX')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 11, 'Bursa Malaysia')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 12, 'DME-NYMEX')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 13, 'MexDer')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 7, 14, 'KRX')
go

--[CBOT]
--CBOT=4
--KCBT=6
--MGEX=7

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 6, 4, 'CBOT')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 6, 6, 'KCBT')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 6, 7, 'MGEX')
go

-----------------------------------------------------------------------
--  tt_account
-----------------------------------------------------------------------

alter table tt_account add acct_include_in_auto_sods byte not null
go

update tt_account set acct_include_in_auto_sods = 1
go

-----------------------------------------------------------------------
--  tt_company
-----------------------------------------------------------------------

alter table tt_company add comp_abbrev varchar(3) not null
go

update tt_company set comp_abbrev = left(comp_name, 3)
go

create unique index index_company_unique_abbrev on tt_company (comp_abbrev)
go

alter table tt_company drop column comp_enable_auto_product_groups
go

-----------------------------------------------------------------------
--  tt_company_market_product
-----------------------------------------------------------------------

drop table tt_company_market_product
go
create table tt_company_market_product
(
cmkp_comp_market_product_id               counter      not null primary key,
cmkp_created_datetime                     datetime     not null,
cmkp_created_user_id                      int          not null,
cmkp_last_updated_datetime                datetime     not null,
cmkp_last_updated_user_id                 int          not null,
cmkp_comp_id                              int          not null,
cmkp_market_id                            int          not null,
cmkp_product_type                         int          not null,
cmkp_product                              varchar(20)  not null,
cmkp_product_in_hex                       varchar(40)  not null,
cmkp_margin_times_100                     int          not null,
-- sizes from Guardian
cmkp_alias                                varchar(15)  not null,
cmkp_description                          varchar(127) not null                           
)
go

alter table tt_company_market_product add constraint fk_cmkp_to_company foreign key (cmkp_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go

alter table tt_company_market_product add constraint fk_cmkp_to_market foreign key (cmkp_market_id) references tt_market (market_id) ON DELETE CASCADE
go

alter table tt_company_market_product add constraint fk_cmkp_to_product_type foreign key (cmkp_product_type) references tt_product_type (product_id) ON DELETE CASCADE
go

create unique index unique_company_market_product on tt_company_market_product (cmkp_comp_id, cmkp_market_id, cmkp_product_type, cmkp_product_in_hex)
go

-----------------------------------------------------------------------
--  tt_currency
-----------------------------------------------------------------------

create table tt_currency
(
crn_currency_id                          counter      not null primary key,
crn_created_datetime                     datetime     not null,
crn_created_user_id                      int          not null,
crn_last_updated_datetime                datetime     not null,
crn_last_updated_user_id                 int          not null,
crn_abbrev                               varchar(6)   not null
)
go

create unique index index_currency_unique_abbrev on tt_currency (crn_abbrev)
go

create table tt_currency_exchange_rate
(
cex_exchange_rate_id                     counter      not null primary key,
cex_created_datetime                     datetime     not null,
cex_created_user_id                      int          not null,
cex_last_updated_datetime                datetime     not null,
cex_last_updated_user_id                 int          not null,
cex_from_currency_id                     int          not null,
cex_to_currency_id                       int          not null,
cex_rate_times_10000                     int          not null
)
go

alter table tt_currency_exchange_rate add constraint fk_exchange_rate_to_currency1 foreign key (cex_from_currency_id) references tt_currency (crn_currency_id) ON DELETE CASCADE
go

alter table tt_currency_exchange_rate add constraint fk_exchange_rate_to_currency2 foreign key (cex_to_currency_id) references tt_currency (crn_currency_id) ON DELETE CASCADE
go

create unique index index_currency_exchange_rate_unique_pair on tt_currency_exchange_rate (cex_from_currency_id, cex_to_currency_id)
go

-----------------------------------------------------------------------
--  tt_customer_default
-----------------------------------------------------------------------

alter table tt_customer_default add cusd_on_behalf_of_mgt_id int not null
go

update tt_customer_default set cusd_on_behalf_of_mgt_id = 0
go

-----------------------------------------------------------------------
--  tt_db_version
-----------------------------------------------------------------------

alter table tt_db_version add dbv_last_updated_datetime datetime not null
go
alter table tt_db_version add dbv_last_updated_ttus_server_version varchar(20) not null
go
alter table tt_db_version add dbv_last_notification_sequence_number int not null
go

update tt_db_version set
dbv_last_updated_datetime = now,
dbv_last_updated_ttus_server_version = '7.4.1.0',
dbv_last_notification_sequence_number = 1
go
 
 
-----------------------------------------------------------------------
--  tt_login_server_settings
-----------------------------------------------------------------------

alter table tt_login_server_settings drop column lss_use_ttus_risk_versus_guardian_risk
go
  
-----------------------------------------------------------------------
--  tt_mgt
-----------------------------------------------------------------------

alter table tt_mgt add mgt_use_simulation_credit byte not null
go

alter table tt_mgt add mgt_simulation_credit int not null
go

update tt_mgt set 
mgt_use_simulation_credit = 0, 
mgt_simulation_credit = 0
go

-----------------------------------------------------------------------
--  tt_product_limit
-----------------------------------------------------------------------

alter table tt_product_limit add plim_for_simulation byte not null
go

update tt_product_limit set plim_for_simulation = 0
go

alter table tt_product_limit drop constraint index_product_limit_key
go

create unique index index_product_limit_key on tt_product_limit (plim_mgt_id, plim_gateway_id, plim_product_in_hex, plim_product_type, plim_for_simulation)
go

-----------------------------------------------------------------------
--  tt_user
-----------------------------------------------------------------------
alter table tt_user drop column user_fix_staged_order_claiming_allowed
go
alter table tt_user add user_use_pl_risk_algo byte not null
go
alter table tt_user add user_xrisk_update_trading_allowed_allowed byte not null
go
alter table tt_user add user_ttapi_admin_edition_allowed byte not null
go
alter table tt_user add user_most_recent_login_datetime_for_inactivity datetime not null
go

update tt_user set
user_use_pl_risk_algo = 0,
user_xrisk_update_trading_allowed_allowed = 0,
user_ttapi_admin_edition_allowed = 0,
user_most_recent_login_datetime_for_inactivity = user_most_recent_login_datetime
go

alter table tt_user add user_use_simulation_credit byte not null
go
alter table tt_user add user_simulation_credit int not null
go
alter table tt_user add user_on_behalf_of_allowed byte not null
go

update tt_user set
user_use_simulation_credit = 0,
user_simulation_credit = 0,
user_on_behalf_of_allowed = 0
go

alter table tt_user add user_mgt_generation_method_member varchar(7) not null
go
alter table tt_user add user_mgt_generation_method_group varchar(3) not null
go

update tt_user set
user_mgt_generation_method_member = '',
user_mgt_generation_method_group = ''
go

-----------------------------------------------------------------------
-- tt_user_gmgt
-----------------------------------------------------------------------


alter table tt_user_gmgt add uxg_algo_sharing_allowed byte not null
go

update tt_user_gmgt set 
uxg_algo_sharing_allowed = 0
go


-----------------------------------------------------------------------
--  tt_previously_heartbeating_gateways
-----------------------------------------------------------------------

drop table tt_previously_heartbeating_gateways
go
create table tt_previously_heartbeating_gateways
(
phg_product                               int not null,
phg_gateway_id                            int not null,
phg_ip                                    int not null,
phg_time_last_heartbeat                   int not null
)
go

-----------------------------------------------------------------------
--  product types
-----------------------------------------------------------------------

insert into tt_product_type values('INDEX',35)
go
insert into tt_product_type values('ALGO',36)
go

-----------------------------------------------------------------------
--  ip address version
-----------------------------------------------------------------------

alter table tt_ip_address_version drop constraint index_ip_address_version
go

create unique index index_ip_address_version on tt_ip_address_version 
(
ipv_ip_address,
ipv_version,
ipv_tt_product_id,
ipv_user_login,
ipv_exe_path,
ipv_gateway_id
) 
go

update tt_ip_address_version set ipv_gateway_id = 36 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 37 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-A\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 38 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-B\priceserver.exe'
go

update tt_ip_address_version set ipv_gateway_id = 90 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-C\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 91 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-D\priceserver.exe'
go

update tt_ip_address_version set ipv_gateway_id = 159 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-E\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 160 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-F\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 161 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-G\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 162 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-H\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 163 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-I\priceserver.exe'
go

update tt_ip_address_version set ipv_gateway_id = 741 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-J\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 742 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-K\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 743 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-L\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 744 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-M\priceserver.exe'
go

update tt_ip_address_version set ipv_gateway_id = 745 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-N\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 746 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-O\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 747 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-P\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 748 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-Q\priceserver.exe'
go

update tt_ip_address_version set ipv_gateway_id = 749 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-R\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 750 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-S\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 751 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-T\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 752 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-U\priceserver.exe'
go

update tt_ip_address_version set ipv_gateway_id = 753 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-V\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 754 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-W\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 755 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-X\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 756 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-Y\priceserver.exe'
go
update tt_ip_address_version set ipv_gateway_id = 757 where ipv_gateway_id = 0 and ipv_exe_path like '%ICE_IPE-Z\priceserver.exe'
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.001.000'
go

