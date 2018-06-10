update tt_db_version set dbv_version = 'converting to 7.3.0'
go

-----------------------------------------------------------------------
-- user types
-----------------------------------------------------------------------


-- Add new admin types
insert into tt_user_setup_user_type values(6, 'Gateway Login Admin (all groups)')
go

insert into tt_user_setup_user_type values(7, 'Group Admin - Can''t Edit Risk')
go

insert into tt_user_setup_user_type values(8, 'Gateway Login Admin (restricted)')
go

insert into tt_user_setup_user_type values(9, 'View Only (all groups)')
go

insert into tt_user_setup_user_type values(10, 'View Only (restricted)')
go

-----------------------------------------------------------------------
-- company
-----------------------------------------------------------------------


-- new company table
create table tt_company
(
comp_id                          counter         not null primary key,
comp_created_datetime            datetime        not null,
comp_created_user_id             int             not null,
comp_last_updated_datetime       datetime        not null,
comp_last_updated_user_id        int             not null,
comp_name                        varchar(30)     not null,
comp_network_id                  int             not null
)
go

create unique index unique_comp_name on tt_company (comp_name)
go

insert into tt_company (
comp_id,
comp_created_datetime, 
comp_created_user_id, 
comp_last_updated_datetime,
comp_last_updated_user_id,
comp_name,
comp_network_id)
values (0,now,1,now,1,'Trading Technologies',0)
go

-- to make usrs visible to gateway login admins
create table tt_user_company_permission
(
ucp_id                          counter         not null primary key,
ucp_created_datetime            datetime        not null,
ucp_created_user_id             int             not null,
ucp_last_updated_datetime       datetime        not null,
ucp_last_updated_user_id        int             not null,
ucp_user_id                     int             not null,
ucp_comp_id                     int             not null
)
go

create unique index unique_user_company_permission on tt_user_company_permission (ucp_user_id, ucp_comp_id)
go

-----------------------------------------------------------------------
-- update gateway and mgt
-----------------------------------------------------------------------

alter table tt_gateway add gateway_comp_network_id int not null
go
update tt_gateway set gateway_comp_network_id = 0
go

alter table tt_mgt add mgt_comp_id int not null
go
update tt_mgt set mgt_comp_id = 0
go


-----------------------------------------------------------------------
-- user table
-----------------------------------------------------------------------

alter table tt_user add user_credit              int          not null
go
alter table tt_user add user_currency            varchar(3)   not null
go
alter table tt_user add user_allow_trading       byte         not null
go
alter table tt_user add user_force_logoff_switch byte         not null
go


update tt_user set 
user_credit = 0,
user_currency = 'USD',
user_allow_trading = 1,
user_force_logoff_switch = 0
go

-----------------------------------------------------------------------
-- user group table
-----------------------------------------------------------------------

alter table tt_user_group add ugrp_comp_id int not null
go

update tt_user_group set ugrp_comp_id = 0
go

-----------------------------------------------------------------------
-- account table
-----------------------------------------------------------------------

alter table tt_account add acct_comp_id int not null
go

update tt_account set acct_comp_id = 0
go

alter table tt_account drop constraint unique_acct_name_in_hex
go

create unique index unique_acct_name_in_hex_company on tt_account (acct_name_in_hex, acct_comp_id)
go

-----------------------------------------------------------------------
-- customer defaults table
-----------------------------------------------------------------------

alter table tt_customer_default add cusd_gateway_id int not null
go

update tt_customer_default set cusd_gateway_id = -1
go

alter table tt_customer_default drop constraint index_customer_default_key
go

create unique index index_customer_default_key on tt_customer_default 
	(cusd_user_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_in_hex, cusd_product_type)
go

-- drop obsolete cusd stuff

alter table tt_customer_default drop constraint fk_custd_to_open_close
go
alter table tt_customer_default drop constraint fk_custd_to_order_restriction
go
alter table tt_customer_default drop constraint fk_custd_to_order_type
go
alter table tt_customer_default drop constraint fk_custd_to_time_in_force
go

alter table tt_customer_default drop column cusd_max_order_qty
go
alter table tt_customer_default drop column cusd_open_close
go
alter table tt_customer_default drop column cusd_order_type
go
alter table tt_customer_default drop column cusd_restriction
go
alter table tt_customer_default drop column cusd_time_in_force
go
alter table tt_customer_default drop column cusd_use_max_order_qty
go

drop table tt_order_restriction
go
drop table tt_order_type
go
drop table tt_time_in_force
go
drop table tt_open_close_code
go


-----------------------------------------------------------------------
-- drop obsolete trade filter stuff
-----------------------------------------------------------------------

alter table tt_trade_filter drop constraint fk_trade_filter_to_gateway
go
alter table tt_trade_filter drop constraint fk_trade_filter_to_match_field
go
alter table tt_trade_filter drop constraint fk_trade_filter_to_user
go

drop table tt_trade_filter
go

drop table tt_trade_filter_match_field
go

-----------------------------------------------------------------------
-- create fk constraints
-----------------------------------------------------------------------

alter table tt_user_company_permission add constraint fk_user_company_permission_user foreign key (ucp_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_user_company_permission add constraint fk_user_company_permission_comp foreign key (ucp_comp_id) references tt_company (comp_id) ON DELETE CASCADE
go
alter table tt_mgt add constraint fk_mgt_company foreign key (mgt_comp_id) references tt_company(comp_id) ON DELETE CASCADE
go
alter table tt_user_group add constraint fk_user_group_company foreign key (ugrp_comp_id) references tt_company(comp_id) ON DELETE CASCADE
go
alter table tt_account add constraint fk_account_company foreign key (acct_comp_id) references tt_company(comp_id) ON DELETE CASCADE
go


--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.003.000.000'
go
