update tt_db_version set dbv_version = 'converting to 7.4.6'
go

-------------------------------------------------------------------------------
-- user
-------------------------------------------------------------------------------

alter table tt_user add user_prevent_orders_based_on_price_ticks byte not null
go
alter table tt_user add int_user_prevent_orders_price_ticks int not null
go
alter table tt_user add user_enforce_price_limit_on_buysell_only byte not null
go
alter table tt_user add user_prevent_orders_based_on_rate byte not null
go
alter table tt_user add int_user_prevent_orders_rate int not null
go
alter table tt_user add user_gtc_orders_allowed byte not null
go

update tt_user set
user_prevent_orders_based_on_price_ticks = 0,
int_user_prevent_orders_price_ticks = 0,
user_enforce_price_limit_on_buysell_only = 1,
user_prevent_orders_based_on_rate = 0,
int_user_prevent_orders_rate = 0,
user_gtc_orders_allowed = 1
go

update tt_user set user_ttapi_allowed = 0 where user_x_trader_mode <> 2
go

update tt_user set user_ttapi_allowed = 1 where user_x_trader_mode = 2
go

-------------------------------------------------------------------------------
-- bvmf
-------------------------------------------------------------------------------

insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,188,'TRADING TECHNOLOGIES')
go

-------------------------------------------------------------------------------
-- views
-------------------------------------------------------------------------------

drop view tt_view_get_properties_xt
go
create view tt_view_get_properties_xt as
SELECT
user_id, 
user_login, 
user_display_name, 
user_cross_orders_allowed, 
user_x_trader_mode, 
user_quoting_allowed, 
user_wholesale_trades_allowed,
user_fmds_allowed,
user_status,
user_last_updated_datetime,
user_credit as real_credit,
user_use_simulation_credit,
user_simulation_credit,
user_currency,
user_allow_trading,
user_force_logoff_switch,
user_restrict_customer_default_editing, 
user_fix_adapter_role,
user_fix_adapter_enable_order_logging,
user_fix_adapter_enable_price_logging,
user_fix_adapter_default_editing_allowed,
user_cross_orders_cancel_resting,
user_most_recent_login_datetime,
user_xrisk_sods_allowed,
user_xrisk_manual_fills_allowed,
user_xrisk_prices_allowed,
user_xrisk_instant_messages_allowed,
user_staged_order_creation_allowed,
user_staged_order_claiming_allowed,
user_dma_order_creation_allowed,
user_fix_staged_order_creation_allowed,
user_fix_dma_order_creation_allowed,
user_ttapi_allowed,
user_use_pl_risk_algo,
user_xrisk_update_trading_allowed_allowed,
user_ttapi_admin_edition_allowed,
user_on_behalf_of_allowed,
user_mgt_generation_method,
user_mgt_generation_method_member,
user_mgt_generation_method_group,
user_machine_gun_orders_allowed,
user_persist_orders_on_eurex,
user_prevent_orders_based_on_price_ticks,
int_user_prevent_orders_price_ticks,
user_enforce_price_limit_on_buysell_only,
user_prevent_orders_based_on_rate,
int_user_prevent_orders_rate,
user_gtc_orders_allowed,
ugrp_name,
ugrp_comp_id,
lss_fmds_allowed,
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_ip, lss_fmds_primary_ip) as [fmds_primary_ip],
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_port, lss_fmds_primary_port) as [fmds_primary_port],
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_service, lss_fmds_primary_service) as [fmds_primary_service],
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_timeout_in_secs, lss_fmds_primary_timeout_in_secs) as [fmds_primary_timeout_in_secs],
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_ip, lss_fmds_secondary_ip) as [fmds_secondary_ip],
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_port, lss_fmds_secondary_port) as [fmds_secondary_port],
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_service, lss_fmds_secondary_service) as [fmds_secondary_service],
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_timeout_in_secs, lss_fmds_secondary_timeout_in_secs) as [fmds_secondary_timeout_in_secs],
iif(ugrp_last_updated_datetime > 
	iif(user_last_updated_datetime > lss_last_updated_datetime, user_last_updated_datetime, lss_last_updated_datetime),
	ugrp_last_updated_datetime,
	iif(user_last_updated_datetime > lss_last_updated_datetime, user_last_updated_datetime, lss_last_updated_datetime))
as max_date,
iif(country_code = '<None>','',Trim(country_code)) as country_code2,
iif(state_abbrev = '<None>','',Trim(state_abbrev)) as state_abbrev2
FROM tt_login_server_settings, tt_us_state 
INNER JOIN (tt_country 
INNER JOIN (tt_user_group 
INNER JOIN tt_user 
ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
ON tt_country.country_id = tt_user.user_country_id) 
ON tt_us_state.state_id = tt_user.user_state_id;
go


drop view tt_view_gmgts_missing_passwords 
go
create view tt_view_gmgts_missing_passwords as
SELECT tt_mgt.mgt_id, tt_mgt.mgt_comp_id, tt_gateway.gateway_name as [Gateway], tt_gmgt.gm_member as [Member], tt_gmgt.gm_group as [Group], tt_gmgt.gm_trader as [Trader], tt_market.market_name, tt_mgt.mgt_password
FROM tt_mgt INNER JOIN (tt_market INNER JOIN (tt_gateway INNER JOIN tt_gmgt ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) ON tt_market.market_id = tt_gateway.gateway_market_id) ON (tt_mgt.mgt_trader = tt_gmgt.gm_trader) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_member = tt_gmgt.gm_member)
where (
        tt_market.market_id = 2
        or tt_market.market_id = 1
        or tt_market.market_id = 10
        or tt_market.market_id = 11
        or tt_market.market_id = 32
        or tt_market.market_id = 67
        or (tt_market.market_id = 6 and tt_gateway.gateway_name like '%ecbot%')
        or (tt_market.market_id = 3 and tt_gateway.gateway_name like 'liffe%')
)
and left(tt_mgt.mgt_member,5) <> 'TTORD'
and tt_mgt.mgt_member <> 'TTADM'
and tt_mgt.mgt_group <> 'XXX'
and tt_mgt.mgt_trader <> 'MGR'
and tt_mgt.mgt_trader <> 'VIEW'
and tt_mgt.mgt_member <> '<No'
and tt_mgt.mgt_password = ''
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.006.000'
go
