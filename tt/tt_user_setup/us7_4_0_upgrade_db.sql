update tt_db_version set dbv_version = 'converting to 7.4.0'
go

insert into tt_user_setup_user_type values(11, 'Broker Admin')
go

-----------------------------------------------------------------------
-- login server settings
-----------------------------------------------------------------------

alter table tt_login_server_settings add lss_multibroker_mode                      byte     not null
go

update tt_login_server_settings set 
lss_multibroker_mode = 0, 
lss_enable_automatic_diagnostic_Q = 1
go

update tt_login_server_settings set lss_reset_password_on_initial_login = 0 where lss_enforce_password_expiration = 0
go


-----------------------------------------------------------------------
-- gateway
-----------------------------------------------------------------------

alter table tt_gateway drop column gateway_comp_network_id
go

-----------------------------------------------------------------------
-- company
-----------------------------------------------------------------------

alter table tt_company drop column comp_network_id
go

alter table tt_company add comp_is_broker byte not null
go

alter table tt_company add comp_enable_auto_product_groups byte not null
go

update tt_company set comp_is_broker = 0
go

update tt_company set comp_enable_auto_product_groups = 0
go

-----------------------------------------------------------------------
-- customer default
-----------------------------------------------------------------------

alter table tt_customer_default add cusd_comp_id int not null
go

update tt_customer_default set cusd_comp_id = 0
go

alter table tt_customer_default drop constraint index_customer_default_key
go

create unique index index_customer_default_key on tt_customer_default (cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_in_hex, cusd_product_type)
go

alter table tt_customer_default add constraint fk_cusd_company foreign key (cusd_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go

-----------------------------------------------------------------------
--  user company
-----------------------------------------------------------------------

alter table tt_user_company_permission add ucp_customer_default_editing_allowed int not null
go

update tt_user_company_permission set ucp_customer_default_editing_allowed = 1
go

-----------------------------------------------------------------------
--  company market product
-----------------------------------------------------------------------

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
cmkp_margin                               int          not null
)
go

alter table tt_company_market_product add constraint fk_cmkp_to_company foreign key (cmkp_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go

alter table tt_company_market_product add constraint fk_cmkp_to_market foreign key (cmkp_market_id) references tt_market (market_id) ON DELETE CASCADE
go

alter table tt_company_market_product add constraint fk_cmkp_to_product_type foreign key (cmkp_product_type) references tt_product_type (product_id) ON DELETE CASCADE
go

create unique index unique_company_market_product on tt_company_market_product (cmkp_comp_id, cmkp_market_id, cmkp_product_type, cmkp_product)
go

-----------------------------------------------------------------------
-- user
-----------------------------------------------------------------------

alter table tt_user add user_ttapi_allowed byte not null
go

alter table tt_user add user_mgt_generation_method int not null
go

update tt_user set 
user_ttapi_allowed = 0,
user_mgt_generation_method = 0
go

alter table tt_user add user_staged_order_creation_allowed byte not null
go
alter table tt_user add user_staged_order_claiming_allowed byte not null
go
alter table tt_user add user_dma_order_creation_allowed byte not null
go
alter table tt_user add user_fix_staged_order_creation_allowed byte not null
go
alter table tt_user add user_fix_staged_order_claiming_allowed byte not null
go
alter table tt_user add user_fix_dma_order_creation_allowed byte not null
go

update tt_user set 
user_staged_order_creation_allowed = user_allow_staged_orders,
user_fix_staged_order_creation_allowed = user_fix_allow_staged_orders,
user_staged_order_claiming_allowed = 0,
user_dma_order_creation_allowed = 1,
user_fix_staged_order_claiming_allowed = 0,
user_fix_dma_order_creation_allowed = 1
go

alter table tt_user drop column user_allow_staged_orders
go
alter table tt_user drop column user_allow_staged_orders_only
go
alter table tt_user drop column user_fix_allow_staged_orders
go
alter table tt_user drop column user_fix_allow_staged_orders_only
go

-----------------------------------------------------------------------
-- user gmgt
-----------------------------------------------------------------------


alter table tt_user_gmgt add uxg_deploy_algo_to_server_allowed byte not null
go

update tt_user_gmgt set 
uxg_deploy_algo_to_server_allowed = 0
go


-----------------------------------------------------------------------
-- market product group
-----------------------------------------------------------------------

create table tt_market_product_group
(
mkpg_market_product_group_id               counter      not null primary key,
mkpg_created_datetime                      datetime     not null,
mkpg_created_user_id                       int          not null,
mkpg_last_updated_datetime                 datetime     not null,
mkpg_last_updated_user_id                  int          not null,
mkpg_market_id                             int          not null,
mkpg_product_group_id                      int          not null,
mkpg_product_group                         varchar(20)  not null
)
go

alter table tt_market_product_group add constraint fk_mkpg_to_market foreign key (mkpg_market_id) references tt_market (market_id) ON DELETE CASCADE
go

create unique index unique_market_product_group on tt_market_product_group (mkpg_market_id, mkpg_product_group_id)
go



-- ice
--CA Futures=2
--CCFE=3
--OTC Gas=4
--OTC Oil=5
--OTC Power=6
--UK Futures=7
--US Futures=8
--Fin Index Data=9
--Heat Rate Spread=10

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 32, 2, 'CA Futures')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 32, 3, 'CCFE')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 32, 4, 'OTC Gas')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 32, 5, 'OTC Oil')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 32, 6, 'OTC Power')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 32, 7, 'UK Futures')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 32, 8, 'US Futures')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 32, 9, 'Fin Index Data')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 32, 10, 'Heat Rate Spread')
go

-----------------------------------------------------------------------
-- user product group
-----------------------------------------------------------------------

create table tt_user_product_group
(
upg_user_product_group_id                 counter      not null primary key,
upg_created_datetime                      datetime     not null,
upg_created_user_id                       int          not null,
upg_last_updated_datetime                 datetime     not null,
upg_last_updated_user_id                  int          not null,
upg_user_id                               int          not null,
upg_comp_id                               int          not null,
upg_market_product_group_id               int          not null
)
go

alter table tt_user_product_group add constraint fk_upg_to_user foreign key (upg_user_id) references tt_user (user_id) ON DELETE CASCADE
go

alter table tt_user_product_group add constraint fk_upg_market_product_group foreign key (upg_market_product_group_id) references tt_market_product_group (mkpg_market_product_group_id) ON DELETE CASCADE
go

alter table tt_user_product_group add constraint fk_upg_to_company foreign key (upg_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go

create unique index unique_user_product_group on tt_user_product_group (upg_user_id, upg_comp_id, upg_market_product_group_id)
go


-----------------------------------------------------------------------
-- app version
-----------------------------------------------------------------------

alter table tt_app_version_rule add avr_min_version_from_license varchar(20)  not null
go

update tt_app_version_rule set avr_min_version_from_license = ""
go


alter table tt_app_version_rule add avr_generated_from_license byte not null
go

update tt_app_version_rule set avr_generated_from_license = 0
go

-----------------------------------------------------------------------
-- ip address version,  aka,  "announce self"
-----------------------------------------------------------------------


alter table tt_ip_address_version add ipv_gateway_id int not null
go

update tt_ip_address_version set
ipv_gateway_id = 0
go

-----------------------------------------------------------------------
-- states
-----------------------------------------------------------------------

alter table tt_us_state add state_country_id int not null
go

update tt_us_state set
state_country_id = 227
where state_id <> 0
go

insert into tt_us_state values(66,'AB','Alberta',39)
go
insert into tt_us_state values(67,'BC','British Columbia',39)
go
insert into tt_us_state values(68,'MB','Manitoba',39)
go
insert into tt_us_state values(69,'NB','New Brunswick',39)
go
insert into tt_us_state values(70,'NL','Newfoundland and Labrador',39)
go
insert into tt_us_state values(71,'NS','Nova Scotia',39)
go
insert into tt_us_state values(72,'ON','Ontario',39)
go
insert into tt_us_state values(73,'PE','Prince Edward Island',39)
go
insert into tt_us_state values(74,'QC','Quebec',39)
go
insert into tt_us_state values(75,'SK','Saskatchewan',39)
go
insert into tt_us_state values(76,'NT','Northwest Territories',39)
go
insert into tt_us_state values(77,'NU','Nunavut',39)
go
insert into tt_us_state values(78,'YT','Yukon Territory',39)
go

alter table tt_us_state add constraint fk_state_to_country foreign key (state_country_id) references tt_country (country_id) ON DELETE CASCADE
go

-- mixed case
update tt_country set country_name = StrConv(country_name,3) where country_id <> 0
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.000.000'
go
