update tt_db_version set dbv_version = 'converting to 7.3.2'
go

alter table tt_login_server_settings drop column lss_multibroker_mode
go

alter table tt_user add user_allow_staged_orders byte not null
go
alter table tt_user add user_allow_staged_orders_only byte not null
go
alter table tt_user add user_fix_allow_staged_orders byte not null
go
alter table tt_user add user_fix_allow_staged_orders_only byte not null
go
alter table tt_user add user_most_recent_failed_login_attempt_datetime datetime not null
go
alter table tt_user add user_marked_for_deletion_datetime datetime not null
go

update tt_user set
user_allow_staged_orders = 0,
user_allow_staged_orders_only = 0,
user_fix_allow_staged_orders = 0,
user_fix_allow_staged_orders_only = 0,
user_most_recent_failed_login_attempt_datetime = #1970-01-02 00:00:00#,
user_marked_for_deletion_datetime = #1970-01-02 00:00:00#
go

-- 'GTD' as [cusd_time_in_force],
-- 'Limit' as [cusd_order_type],
-- '<None>' as [cusd_restriction],
-- 'Open' as [cusd_open_close],
-- CBYTE(0) as [cusd_use_max_order_qty],
-- 1 as [cusd_max_order_qty],

alter table tt_customer_default add column cusd_max_order_qty      int          not null
go
alter table tt_customer_default add column cusd_open_close         varchar(5)   not null
go
alter table tt_customer_default add column cusd_order_type         varchar(5)   not null
go
alter table tt_customer_default add column cusd_restriction        varchar(10)  not null
go
alter table tt_customer_default add column cusd_time_in_force      varchar(3)   not null
go
alter table tt_customer_default add column cusd_use_max_order_qty  byte         not null
go

update tt_customer_default set
cusd_time_in_force = 'GTD',
cusd_order_type = 'Limit',
cusd_restriction = '<None>',
cusd_open_close = 'Open',
cusd_use_max_order_qty = 0,
cusd_max_order_qty = 1
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.003.002.000'
go