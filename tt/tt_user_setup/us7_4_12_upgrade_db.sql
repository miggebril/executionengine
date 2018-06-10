update tt_db_version set dbv_version = 'converting to 7.4.12'
go

alter table tt_user alter column user_fmds_primary_ip varchar(255) not null
go

alter table tt_user alter column user_fmds_secondary_ip varchar(255) not null
go

alter table tt_login_server_settings alter column lss_fmds_primary_ip varchar(255) not null
go

alter table tt_login_server_settings alter column lss_fmds_secondary_ip varchar(255) not null
go

alter table tt_user_gmgt add uxg_max_orders_per_second int not null default 0
go

update tt_user_gmgt set uxg_max_orders_per_second = 0
go

alter table tt_user_gmgt add uxg_max_orders_per_second_on byte not null default 0
go

update tt_user_gmgt set uxg_max_orders_per_second_on = 0
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.012.000'
go
