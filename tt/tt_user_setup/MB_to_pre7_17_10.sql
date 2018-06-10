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

alter table tt_app_version_rule add avr_user_group_id int not null
go

update tt_app_version_rule set avr_user_group_id = 0
go

drop index index_avr_tt_app on tt_app_version_rule
go

create unique index index_avr_tt_app on tt_app_version_rule (avr_tt_app_id, avr_user_id, avr_user_group_id)
go