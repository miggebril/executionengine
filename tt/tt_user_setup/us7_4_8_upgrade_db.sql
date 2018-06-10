update tt_db_version set dbv_version = 'converting to 7.4.8'
go


--- tt_product_limit
alter table tt_product_limit add plim_account_group_id int default null
go
alter table tt_product_limit add plim_addl_margin_pct_on byte not null default 1
go
alter table tt_product_limit add plim_max_order_qty_on byte not null default 1
go
alter table tt_product_limit add plim_max_position_on byte not null default 1
go
alter table tt_product_limit add plim_max_long_short_on byte not null default 1
go
update tt_product_limit set plim_addl_margin_pct_on = 1
go
update tt_product_limit set plim_max_order_qty_on = 1
go
update tt_product_limit set plim_max_position_on = 1
go
update tt_product_limit set plim_max_long_short_on = 1
go

alter table tt_product_limit drop constraint index_product_limit_key
go
create unique index index_product_limit_key on tt_product_limit (plim_mgt_id, plim_account_group_id, plim_gateway_id, plim_product_in_hex, plim_product_type, plim_for_simulation)
go
--- alter table tt_product_limit add constraint fk_product_limit_to_account_group foreign key (plim_account_group_id) references tt_account_group (ag_id) ON DELETE CASCADE
--- go

--- tt_account_group
create table tt_account_group
(
  ag_id counter not null primary key,
  ag_created_datetime datetime not null,
  ag_created_user_id int not null,
  ag_last_updated_datetime datetime not null,
  ag_last_updated_user_id int not null,
  ag_name varchar(64) not null,
  ag_name_in_hex varchar(128) not null,
  ag_description varchar(100) not null,
  ag_comp_id int not null,
  ag_is_auto_assigned byte not null,
  ag_risk_enabled byte not null default 1,
  ag_trading_allowed byte not null default 1
)
go

create unique index unique_account_group on tt_account_group( ag_name_in_hex, ag_comp_id )
go

--- tt_margin_limit
create table tt_margin_limit
(
  mlim_margin_limit_id counter not null primary key,
  mlim_created_datetime datetime not null,
  mlim_created_user_id int not null,
  mlim_last_updated_datetime datetime not null,
  mlim_last_updated_user_id int not null,
  mlim_account_group_id int not null,
  mlim_gateway_id int not null,
  mlim_currency_id int not null,
  mlim_margin_limit_times_100 int not null,
  mlim_margin_limit_enabled byte not null
)
go

alter table tt_margin_limit add constraint fk_margin_limit_to_account_group foreign key (mlim_account_group_id) references tt_account_group (ag_id) ON DELETE CASCADE
go

--- tt_user
alter table tt_user add user_undefined_accounts_allowed byte not null default 0
go
alter table tt_user add user_account_changes_allowed byte not null default 0
go
alter table tt_user add user_no_sod_user_group_restrictions byte not null default 1
go
update tt_user set user_undefined_accounts_allowed = 1
go
update tt_user set user_account_changes_allowed = 1
go
update tt_user set user_no_sod_user_group_restrictions = 1
go

--- tt_account
alter table tt_account add acct_account_group_id int default null
go

--- tt_user_group_sod_permission
create table tt_user_group_sod_permission
(
ugps_id                                   counter      not null primary key,
ugps_created_datetime                     datetime     not null,
ugps_created_user_id                      int          not null,
ugps_last_updated_datetime                datetime     not null,
ugps_last_updated_user_id                 int          not null,
ugps_user_id                              int          not null,
ugps_group_id                             int          not null
) 
go

create unique index index_user_group_sod_permission_user_group on tt_user_group_sod_permission (ugps_user_id, ugps_group_id)
go

alter table tt_user_group_sod_permission add constraint fk_user_group_sod_permission_to_user foreign key (ugps_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_user_group_sod_permission add constraint fk_user_group_sod_permission_to_group foreign key (ugps_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go

--- create account groups and their account links
insert into tt_account_group
    ( ag_id, ag_created_datetime, ag_created_user_id, ag_last_updated_datetime, ag_last_updated_user_id,
      ag_name, ag_name_in_hex, ag_description, ag_comp_id, ag_is_auto_assigned, ag_risk_enabled, ag_trading_allowed )
    select acct_id, now, 0, now, 0, acct_name, acct_name_in_hex, acct_description, acct_comp_id, 1, 0, 1 from tt_account
go


update tt_account set acct_account_group_id = acct_id
go

--- tt_account_group_group_permission
create table tt_account_group_group_permission
(
  aggp_id                                   counter      not null primary key,
  aggp_created_datetime                     datetime     not null,
  aggp_created_user_id                      int          not null,
  aggp_last_updated_datetime                datetime     not null,
  aggp_last_updated_user_id                 int          not null,
  aggp_account_group_id                     int          not null,
  aggp_group_id                             int          not null
) 
go

create unique index index_account_group_group_permission_account_group on tt_account_group_group_permission (aggp_account_group_id, aggp_group_id)
go

--- misc
update tt_mgt set mgt_enable_sods = 1
go

update tt_user set user_ttapi_allowed = 1 where user_x_trader_mode = 2
go

--- views
-- in 7.17 mode all views are pulled out of here and moved to views.sql

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.008.000'
go
