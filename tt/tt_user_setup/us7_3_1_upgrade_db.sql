update tt_db_version set dbv_version = 'converting to 7.3.1'
go

update tt_customer_default set cusd_product_in_hex = '2A' where cusd_product = '*'
go

--------------- Start Mgt

alter table tt_mgt add mgt_enable_sods byte not null
go

update tt_mgt set mgt_enable_sods = 1
go

--------------- End Mgt


--------------- Start User Gmgt

alter table tt_user_gmgt add uxg_available_to_fix_adapter_user byte not null
go

alter table tt_user_gmgt add uxg_mandatory_login byte not null
go

update tt_user_gmgt set 
uxg_available_to_fix_adapter_user = 0,
uxg_mandatory_login = 0
go

--------------- End User Gmgt


--------------- Start User


alter table tt_user drop column user_xrisk_allowed
go
alter table tt_user drop column user_fix_adapter_allowed
go
alter table tt_user drop column user_fix_adapter_server byte
go
alter table tt_user add user_fix_adapter_role int not null 
go
alter table tt_user add user_cross_orders_cancel_resting byte not null
go

alter table tt_user add user_fmds_primary_ip                       varchar(15)  not null
go
alter table tt_user add user_fmds_primary_port                     int          not null
go
alter table tt_user add user_fmds_primary_service                  int          not null
go
alter table tt_user add user_fmds_primary_timeout_in_secs          int          not null
go
alter table tt_user add user_fmds_secondary_ip                     varchar(15)  not null
go
alter table tt_user add user_fmds_secondary_port                   int          not null
go
alter table tt_user add user_fmds_secondary_service                int          not null
go
alter table tt_user add user_fmds_secondary_timeout_in_secs        int          not null
go

alter table tt_user add user_gui_view_type int not null
go

--user_fix_adapter_role
-- 0 = not allowed
-- 1 = client
-- 2 = server
update tt_user set
user_fix_adapter_role = 0,
user_cross_orders_cancel_resting = 1,
user_fmds_primary_ip = '',
user_fmds_primary_port = 10200,
user_fmds_primary_service = 250,
user_fmds_primary_timeout_in_secs = 30,
user_fmds_secondary_ip = '',
user_fmds_secondary_port = 0,
user_fmds_secondary_service = 0,
user_fmds_secondary_timeout_in_secs = 0,
-- xtrader view type
user_gui_view_type = 1
go

-- 0 all, 1 xt, 2 fa server, 3 fa client, 4 ttus admin
-- if ttus admin, set view type to 0
update tt_user set user_gui_view_type = 0 where user_user_setup_user_type <> 0
go

alter table tt_user add user_use_user_level_fmds_settings              byte         not null
go

update tt_user set user_use_user_level_fmds_settings = 0
go


--------------- End of User


create table tt_user_user_relationship
(
	uur_id                                   counter      not null primary key,
	uur_created_datetime                     datetime     not null,
	uur_created_user_id                      int          not null,
	uur_last_updated_datetime                datetime     not null,
	uur_last_updated_user_id                 int          not null,
	uur_user_id1                             int          not null,
	uur_user_id2                             int          not null,
	uur_relationship_type                    char(3)      not null
)
go


----------------  Start of App Version Rule

--delete from tt_app_version_rule
--go

--delete from tt_tt_app
--go

--drop table tt_app_version_rule
--go

--drop table tt_tt_app
--go

create table tt_tt_app
(
	ttapp_app_id                            int          not null,
	ttapp_app_name                          varchar(50)  not null,
	ttapp_client_license_id                 int          not null,
	ttapp_display_order	                    int          not null,
	ttapp_display_name                      varchar(50)  not null
)
go

create unique index index_ttapp_app_id on tt_tt_app (ttapp_app_id)
go

create unique index index_ttapp_app_name on tt_tt_app (ttapp_app_name)
go

create table tt_app_version_rule
(
	avr_id                                   counter      not null primary key,
	avr_created_datetime                     datetime     not null,
	avr_created_user_id                      int          not null,
	avr_last_updated_datetime                datetime     not null,
	avr_last_updated_user_id                 int          not null,
	avr_tt_app_id                            int          not null,
	avr_user_id                              int          not null,
	avr_comparison_operator                  char(2)      not null,
	avr_version                              varchar(20)  not null,
--  true for err, false for warning
	avr_error                                byte         not null,
	avr_additional_message                   varchar(255) not null
)
go



create unique index index_avr_tt_app on tt_app_version_rule (avr_tt_app_id, avr_user_id)
go

alter table tt_app_version_rule add constraint fk_app_version_rule_to_app foreign key (avr_tt_app_id) references tt_tt_app (ttapp_app_id) ON DELETE CASCADE
go

-- The ttapp_app_name column must be the same as MSG_APP #defines in messages.h
-- the ttapp_display_name column can be anything

--insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('FIX Adapter Drop Copy Server',1,0,0,'FIX Adapter Drop Copy Server')
--go
--insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('FIX Adapter Order Routing Server',2,0,0,'FIX Adapter Order Routing Server')
--go
--insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('Guardian',3,-1,0,'Guardian')
--go
--insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('GuardianMFC',4,-2,0,'GuardianMFC')
--go
--insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('TT API',5,0,0,'TT API')
--go
insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('X_Risk',6,0,2,'X_RISK')
go
--insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('X_Study',7,45,0,'X_STUDY')
--go
--insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('X_Trader API',8,0,0,'X_TRADER API')
--go
insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('Old apps that don''t report version',9,0,1,'Old apps that don''t report version')
go
insert into tt_tt_app (ttapp_app_name, ttapp_app_id, ttapp_client_license_id, ttapp_display_order, ttapp_display_name) values ('X_Trader',10,0,3,'X_TRADER')
go


----------  END OF APP VERSION RULE





-------- login server settings

alter table tt_login_server_settings add lss_enable_diagnostics byte not null
go

alter table tt_login_server_settings add lss_restrict_diagnostics_to_superadmin byte not null
go

update tt_login_server_settings set
lss_enable_diagnostics = 1,
lss_restrict_diagnostics_to_superadmin = 0
go

alter table tt_login_server_settings add lss_enable_automatic_diagnostic_A byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_B byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_C byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_D byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_E byte not null
go

alter table tt_login_server_settings add lss_enable_automatic_diagnostic_F byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_G byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_H byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_I byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_J byte not null
go

alter table tt_login_server_settings add lss_enable_automatic_diagnostic_K byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_L byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_M byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_N byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_O byte not null
go

alter table tt_login_server_settings add lss_enable_automatic_diagnostic_P byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_Q byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_R byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_S byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_T byte not null
go

alter table tt_login_server_settings add lss_enable_automatic_diagnostic_U byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_V byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_W byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_X byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_Y byte not null
go
alter table tt_login_server_settings add lss_enable_automatic_diagnostic_Z byte not null
go

update tt_login_server_settings set
lss_enable_automatic_diagnostic_A = 0,
lss_enable_automatic_diagnostic_B = 0,
lss_enable_automatic_diagnostic_C = 0,
lss_enable_automatic_diagnostic_D = 0,
lss_enable_automatic_diagnostic_E = 0,

lss_enable_automatic_diagnostic_F = 0,
lss_enable_automatic_diagnostic_G = 0,
lss_enable_automatic_diagnostic_H = 0,
lss_enable_automatic_diagnostic_I = 1,
lss_enable_automatic_diagnostic_J = 1,

lss_enable_automatic_diagnostic_K = 0,
lss_enable_automatic_diagnostic_L = 1,
lss_enable_automatic_diagnostic_M = 1,
lss_enable_automatic_diagnostic_N = 1,
lss_enable_automatic_diagnostic_O = 0,

lss_enable_automatic_diagnostic_P = 0,
lss_enable_automatic_diagnostic_Q = 0,
lss_enable_automatic_diagnostic_R = 0,
lss_enable_automatic_diagnostic_S = 0,
lss_enable_automatic_diagnostic_T = 0,

lss_enable_automatic_diagnostic_U = 0,
lss_enable_automatic_diagnostic_V = 0,
lss_enable_automatic_diagnostic_W = 0,
lss_enable_automatic_diagnostic_X = 0,
lss_enable_automatic_diagnostic_Y = 0,

lss_enable_automatic_diagnostic_Z = 0
go


-------- end of login server settings


create unique index index_user1_user2 on tt_user_user_relationship (uur_user_id1, uur_relationship_type, uur_user_id2 )
go

create unique index index_user2_user1 on tt_user_user_relationship (uur_user_id2, uur_relationship_type, uur_user_id1)
go

alter table tt_user_user_relationship add constraint fk_user1_to_user foreign key (uur_user_id1) references tt_user (user_id) ON DELETE CASCADE
go

alter table tt_user_user_relationship add constraint fk_user2_to_user foreign key (uur_user_id2) references tt_user (user_id) ON DELETE CASCADE
go


-- obsolete views
drop view tt_view_cusd_acct_gateway_combos_for_direct_traders
go

drop view tt_view_mgt_acct_gateway_combos_for_exchange_traders
go

drop view tt_view_user_customer_default_accounts
go

drop view tt_view_user_mgt_accounts
go

drop view tt_view_users_with_autologin
go

drop view tt_view_unique_tradable_gateway_logins
go

drop view tt_view_mgt_member_group_user_group_combos
go

drop view tt_view_mgtmarket_accts_without_cusdmarket_accts
go

drop view tt_view_mgtmarket_accts_without_cusdmarket_accts2
go

drop view tt_view_cusdmarket_accts_without_mgtmarket_accts
go

drop view tt_view_cusdmarket_accts_without_mgtmarket_accts2
go

-- don't need <None>
delete from tt_market where market_id = 0
go
delete from tt_gateway where gateway_id = 0
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.003.001.000'
go