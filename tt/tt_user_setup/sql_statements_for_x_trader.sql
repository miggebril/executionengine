
-- if you change here, change _sim version too
--$get_properties_xt
SELECT user_id,
user_login,
user_display_name,
user_cross_orders_allowed,
user_x_trader_mode,
user_quoting_allowed,
user_wholesale_trades_allowed,
user_wholesale_orders_with_undefined_accounts_allowed,
user_fmds_allowed,
user_status,
user_last_updated_datetime,
user_credit,
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
user_xtapi_allowed,
user_autotrader_allowed,
user_autospreader_allowed,
user_use_pl_risk_algo,
user_xrisk_update_trading_allowed_allowed,
user_ttapi_admin_edition_allowed,
user_on_behalf_of_allowed,
user_mgt_generation_method,
user_mgt_generation_method_member,
user_mgt_generation_method_group,
user_individually_select_admin_logins,
user_machine_gun_orders_allowed,
user_algo_deployment_allowed,
user_algo_sharing_allowed,
user_persist_orders_on_eurex,
user_liquidate_exceeding_position_limits_allowed,
user_prevent_orders_based_on_price_ticks,
int_user_prevent_orders_price_ticks,
user_enforce_price_limit_on_buysell_only,
user_prevent_orders_based_on_rate,
int_user_prevent_orders_rate,
user_gtc_orders_allowed,
user_undefined_accounts_allowed,
user_account_changes_allowed,
user_no_sod_user_group_restrictions,
ugrp_name,
ugrp_comp_id,
iif( user_user_setup_user_type in ( 1, 2, 3, 7, 11 ), CByte(1), CByte(0) ) AS is_company_admin,
lss_fmds_allowed,
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_ip, everybody.lss_fmds_primary_ip) AS lss_fmds_primary_ip,
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_port, everybody.lss_fmds_primary_port) AS lss_fmds_primary_port,
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_service, everybody.lss_fmds_primary_service) AS lss_fmds_primary_service,
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_timeout_in_secs, everybody.lss_fmds_primary_timeout_in_secs) AS lss_fmds_primary_timeout_in_secs,
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_ip, everybody.lss_fmds_secondary_ip) AS lss_fmds_secondary_ip,
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_port, everybody.lss_fmds_secondary_port) AS lss_fmds_secondary_port,
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_service, everybody.lss_fmds_secondary_service) AS lss_fmds_secondary_service,
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_timeout_in_secs, everybody.lss_fmds_secondary_timeout_in_secs) AS lss_fmds_secondary_timeout_in_secs,

iif(ugrp_last_updated_datetime > iif(user_last_updated_datetime > lss_last_updated_datetime, user_last_updated_datetime,
lss_last_updated_datetime),
	ugrp_last_updated_datetime,
	iif(user_last_updated_datetime > lss_last_updated_datetime,
user_last_updated_datetime,
lss_last_updated_datetime)) AS max_date,

iif(tt_country.country_code = '<None>','',Trim(tt_country.country_code)) AS country_code,
iif(tt_us_state.state_abbrev = '<None>','',Trim(tt_us_state.state_abbrev)) AS state_abbrev,
user_ignore_pl,
user_ignore_margin,
user_claim_own_staged_orders_allowed,
user_account_permissions_enabled,
user_can_submit_market_orders,
user_can_submit_iceberg_orders,
user_can_submit_time_sliced_orders,
user_can_submit_volume_sliced_orders,
user_can_submit_time_duration_orders,
user_can_submit_volume_duration_orders,
user_xrisk_allowed,
user_aggregator_allowed,
user_sniper_orders_allowed,
user_eu_config_1_allowed,
user_eu_config_1,
user_eu_config_2_allowed,
user_eu_config_2
FROM tt_login_server_settings as everybody,
tt_us_state 
INNER JOIN (tt_country 
INNER JOIN (tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id) ON tt_country.country_id = tt_user.user_country_id) ON tt_us_state.state_id = tt_user.user_state_id
where user_login in ('??')
order by user_login


--$get_properties_xt_sim
SELECT user_id,
user_login,
user_display_name,
CBYTE(1) as user_cross_orders_allowed, 
CLNG(2) as user_x_trader_mode, 
CBYTE(1) as user_quoting_allowed,
CBYTE(1) as user_wholesale_trades_allowed,
CBYTE(1) as user_wholesale_orders_with_undefined_accounts_allowed,
user_fmds_allowed,
user_status,
user_last_updated_datetime,
iif(tt_user.user_use_simulation_credit = 1, tt_user.user_simulation_credit, tt_user.user_credit) as [user_credit],
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
CBYTE(1) as user_staged_order_creation_allowed,
CBYTE(1) as user_staged_order_claiming_allowed,
CBYTE(1) as user_dma_order_creation_allowed,
CBYTE(1) as user_fix_staged_order_creation_allowed,
CBYTE(1) as user_fix_dma_order_creation_allowed,
user_ttapi_allowed,
CBYTE(1) as user_xtapi_allowed,
CBYTE(1) as user_autotrader_allowed,
CBYTE(1) as user_autospreader_allowed,
user_use_pl_risk_algo,
user_xrisk_update_trading_allowed_allowed,
user_ttapi_admin_edition_allowed,
CBYTE(1) as user_on_behalf_of_allowed,
user_mgt_generation_method,
user_mgt_generation_method_member,
user_mgt_generation_method_group,
user_individually_select_admin_logins,
CBYTE(1) as user_machine_gun_orders_allowed,
CBYTE(1) as user_algo_deployment_allowed,
CBYTE(1) as user_algo_sharing_allowed,
0 as user_persist_orders_on_eurex,
user_liquidate_exceeding_position_limits_allowed,
user_prevent_orders_based_on_price_ticks,
int_user_prevent_orders_price_ticks,
user_enforce_price_limit_on_buysell_only,
user_prevent_orders_based_on_rate,
int_user_prevent_orders_rate,
CBYTE(1) as user_gtc_orders_allowed,
CBYTE(1) as user_undefined_accounts_allowed,
CBYTE(1) as user_account_changes_allowed,
user_no_sod_user_group_restrictions,
ugrp_name,
ugrp_comp_id,
iif( user_user_setup_user_type in ( 1, 2, 3, 7, 11 ), CByte(1), CByte(0) ) AS is_company_admin,
lss_fmds_allowed,
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_ip, everybody.lss_fmds_primary_ip) AS lss_fmds_primary_ip,
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_port, everybody.lss_fmds_primary_port) AS lss_fmds_primary_port,
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_service, everybody.lss_fmds_primary_service) AS lss_fmds_primary_service,
iif(user_use_user_level_fmds_settings = 1, user_fmds_primary_timeout_in_secs, everybody.lss_fmds_primary_timeout_in_secs) AS lss_fmds_primary_timeout_in_secs,
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_ip, everybody.lss_fmds_secondary_ip) AS lss_fmds_secondary_ip,
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_port, everybody.lss_fmds_secondary_port) AS lss_fmds_secondary_port,
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_service, everybody.lss_fmds_secondary_service) AS lss_fmds_secondary_service,
iif(user_use_user_level_fmds_settings = 1, user_fmds_secondary_timeout_in_secs, everybody.lss_fmds_secondary_timeout_in_secs) AS lss_fmds_secondary_timeout_in_secs,

iif(ugrp_last_updated_datetime > iif(user_last_updated_datetime > lss_last_updated_datetime, user_last_updated_datetime,
lss_last_updated_datetime),
	ugrp_last_updated_datetime,
	iif(user_last_updated_datetime > lss_last_updated_datetime,
user_last_updated_datetime,
lss_last_updated_datetime)) AS max_date,

iif(tt_country.country_code = '<None>','',Trim(tt_country.country_code)) AS country_code,
iif(tt_us_state.state_abbrev = '<None>','',Trim(tt_us_state.state_abbrev)) AS state_abbrev,
user_ignore_pl,
user_ignore_margin,
CBYTE(1) as user_claim_own_staged_orders_allowed,
user_account_permissions_enabled,
CBYTE(1) as user_can_submit_market_orders,
CBYTE(1) as user_can_submit_iceberg_orders,
CBYTE(1) as user_can_submit_time_sliced_orders,
CBYTE(1) as user_can_submit_volume_sliced_orders,
CBYTE(1) as user_can_submit_time_duration_orders,
CBYTE(1) as user_can_submit_volume_duration_orders,
user_xrisk_allowed,
CBYTE(1) as user_aggregator_allowed,
CBYTE(1) as user_sniper_orders_allowed,
CBYTE(0) as user_eu_config_1_allowed,
user_eu_config_1,
CBYTE(0) as user_eu_config_2_allowed,
user_eu_config_2
FROM tt_login_server_settings as everybody,
tt_us_state 
INNER JOIN (tt_country 
INNER JOIN (tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id) ON tt_country.country_id = tt_user.user_country_id) ON tt_us_state.state_id = tt_user.user_state_id
where user_login in ('??')
order by user_login

-----------------------------------------------------------------------

-- Used in xt 7.7.4 and if TTUS 7.2, also 7.8.   But for TTUS 7.7.3, XT 7.8 uses the new sql below.
--$get_all_customer_defaults_info_xt
SELECT 
tt_user.user_restrict_customer_default_editing, 
tt_customer_default.*, 
-- obsolete fields hard-coded for backwards compatibility with pre-778, except now in 7.3.2 we added back the obsolete fields..
--'GTD' as [cusd_time_in_force],
--'Limit' as [cusd_order_type],
--'<None>' as [cusd_restriction],
--'Open' as [cusd_open_close],
--CBYTE(0) as [cusd_use_max_order_qty],
--1 as [cusd_max_order_qty],
tt_account.acct_name
FROM tt_account 
INNER JOIN (tt_user 
INNER JOIN tt_customer_default 
ON tt_user.user_id = tt_customer_default.cusd_user_id) 
ON tt_account.acct_id = tt_customer_default.cusd_account_id
WHERE user_login = ?

-- new in ttus 7.3, used starting in XT 7.7.8 - doesn't have obsolete fields (except that really it does, because we added them back in 7.3.2)
--$get_customer_defaults_xt
SELECT
  tt_customer_default.cusd_id,
  iif( tt_customer_default.cusd_default_gmgt_id is null, -1, tt_customer_default.cusd_default_gmgt_id ) as [cusd_default_gmgt_id],
  iif( direct_gmgt.gm_id is null, iif( tt_customer_default.cusd_default_gmgt_id is null, -1, tt_customer_default.cusd_default_gmgt_id ), direct_gmgt.gm_id ) as cusd_default_direct_gmgt_id,
  tt_customer_default.cusd_created_datetime,
  tt_customer_default.cusd_created_user_id,
  tt_customer_default.cusd_last_updated_datetime,
  tt_customer_default.cusd_last_updated_user_id,
  tt_customer_default.cusd_user_id,
  tt_customer_default.cusd_customer,
  tt_customer_default.cusd_selected,
  tt_customer_default.cusd_market_id,
  tt_customer_default.cusd_product,
  tt_customer_default.cusd_product_type,
  tt_customer_default.cusd_account_id,
  tt_customer_default.cusd_account_type,
  tt_customer_default.cusd_give_up,
  tt_customer_default.cusd_fft2,
  tt_customer_default.cusd_fft3,
  tt_customer_default.cusd_first_default,
  tt_customer_default.cusd_product_in_hex,
  tt_customer_default.cusd_gateway_id,
  tt_customer_default.cusd_max_order_qty,
  tt_customer_default.cusd_open_close,
  tt_customer_default.cusd_order_type,
  tt_customer_default.cusd_restriction,
  tt_customer_default.cusd_time_in_force,
  tt_customer_default.cusd_use_max_order_qty,
  tt_customer_default.cusd_comp_id,
  tt_customer_default.cusd_on_behalf_of_mgt_id,
  tt_customer_default.cusd_on_behalf_of_user_id,
  tt_customer_default.cusd_on_behalf_of_account_id,
  tt_customer_default.cusd_fft4,
  tt_customer_default.cusd_fft5,
  tt_customer_default.cusd_fft6,
  tt_customer_default.cusd_investment_decision,
  tt_customer_default.cusd_execution_decision,
  tt_customer_default.cusd_client,
  tt_customer_default.cusd_dea,
  tt_customer_default.cusd_trading_capacity,
  tt_customer_default.cusd_liquidity_provision,
  tt_customer_default.cusd_cdi,
  tt_account.acct_name, 
  IIF(tt_mgt.mgt_member = '<None>','',tt_mgt.mgt_member) as cusd_on_behalf_of_member,
  tt_mgt.mgt_group as cusd_on_behalf_of_group,
  tt_mgt.mgt_trader as cusd_on_behalf_of_trader,
  tt_user_obo.user_login AS cusd_on_behalf_of_user,
  tt_account_obo.acct_name AS cusd_on_behalf_of_account,
  IIF(default_gmgt.gm_member = '<None>','',default_gmgt.gm_member) as cusd_default_member,
  default_gmgt.gm_group as cusd_default_group,
  default_gmgt.gm_trader as cusd_default_trader,
  default_gmgt.gm_gateway_id as cusd_default_gateway_id,
  default_mgt.mgt_description as cusd_default_alias,
  IIF(cusd_last_updated_datetime>tt_account.acct_last_updated_datetime,cusd_last_updated_datetime,tt_account.acct_last_updated_datetime) AS max_date,
  tt_algos.al_algo_name
FROM ((((((((( tt_mgt
  INNER JOIN tt_customer_default ON tt_mgt.mgt_id = tt_customer_default.cusd_on_behalf_of_mgt_id )
  INNER JOIN tt_user ON tt_user.user_id = tt_customer_default.cusd_user_id )
  INNER JOIN tt_account ON tt_account.acct_id = tt_customer_default.cusd_account_id ) 
  LEFT JOIN tt_account as tt_account_obo ON tt_account_obo.acct_id = tt_customer_default.cusd_on_behalf_of_account_id )
  LEFT JOIN tt_user as tt_user_obo ON tt_user_obo.user_id = tt_customer_default.cusd_on_behalf_of_user_id )
  LEFT JOIN tt_gmgt as default_gmgt ON tt_customer_default.cusd_default_gmgt_id = default_gmgt.gm_id )
  LEFT JOIN tt_mgt as default_mgt ON ( default_gmgt.gm_member = default_mgt.mgt_member AND default_gmgt.gm_group = default_mgt.mgt_group AND default_gmgt.gm_trader = default_mgt.mgt_trader ) )
  LEFT JOIN tt_mgt_gmgt ON default_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id )
  LEFT JOIN tt_gmgt as direct_gmgt ON tt_mgt_gmgt.mxg_gmgt_id = direct_gmgt.gm_id)
  LEFT JOIN tt_algos ON tt_algos.al_algo_id = tt_customer_default.cusd_al_algo_id
WHERE ( direct_gmgt.gm_gateway_id = default_gmgt.gm_gateway_id OR direct_gmgt.gm_gateway_id is null )
  AND tt_user.user_login = ?


-----------------------------------------------------------------------


--$get_account_defaults_info_xt
SELECT 
tt_user.user_login,
tt_account_default.*, 
tt_account.acct_name,
iif(acctd_last_updated_datetime > acct_last_updated_datetime, acctd_last_updated_datetime, acct_last_updated_datetime) as max_date
FROM tt_account 
INNER JOIN (tt_user 
INNER JOIN tt_account_default 
ON tt_user.user_id = tt_account_default.acctd_user_id) 
ON tt_account.acct_id = tt_account_default.acctd_account_id
WHERE user_login in ('??')
order by tt_user.user_login, tt_account_default.acctd_comp_id, tt_account_default.acctd_sequence_number

-----------------------------------------------------------------------

--$get_account_restrictions_xt
SELECT tt_user.user_login, tt_account.acct_name, tt_user_account.*, tt_account.acct_comp_id
FROM ( tt_user
INNER JOIN tt_user_account ON tt_user.user_id = tt_user_account.uxa_user_id )
INNER JOIN tt_account ON tt_user_account.uxa_account_id = tt_account.acct_id
WHERE tt_user.user_login IN ('??')

-----------------------------------------------------------------------


-- Used in xt 7.8
--$get_revision_info_by_login_xt
SELECT 
      'cusd' as identifier, 
      Count(1) as row_cnt, 
      Max(iif(cusd_last_updated_datetime > acct_last_updated_datetime, cusd_last_updated_datetime, acct_last_updated_datetime)) as max_date
FROM tt_account 
INNER JOIN (tt_user 
INNER JOIN tt_customer_default ON tt_user.user_id = tt_customer_default.cusd_user_id) ON tt_account.acct_id = tt_customer_default.cusd_account_id
WHERE tt_user.user_login= ?

UNION
SELECT 
     'mgt' as identifier, 
      Count(1) as row_cnt, 
      Max(tt_mgt.mgt_last_updated_datetime) as max_date
FROM (tt_view_user_mgt_combos 
INNER JOIN tt_user ON tt_view_user_mgt_combos.uxg_user_id = tt_user.user_id) 
INNER JOIN tt_mgt ON tt_view_user_mgt_combos.mgt_id = tt_mgt.mgt_id
WHERE tt_user.user_login = ?

UNION
SELECT 
      'plim' as identifier, 
      Count(1) as row_cnt, 
      Max(tt_product_limit.plim_last_updated_datetime)  as max_date
FROM 
      (tt_user INNER JOIN 
      ((tt_gmgt INNER JOIN tt_mgt ON 
      (tt_gmgt.gm_member = tt_mgt.mgt_member) AND 
      (tt_gmgt.gm_group = tt_mgt.mgt_group) AND 
      (tt_gmgt.gm_trader = tt_mgt.mgt_trader)) INNER JOIN tt_user_gmgt ON 
      tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON 
      tt_user.user_id = tt_user_gmgt.uxg_user_id) INNER JOIN tt_product_limit ON 
      tt_mgt.mgt_id = tt_product_limit.plim_mgt_id
WHERE tt_user.user_login = ?
and tt_product_limit.plim_for_simulation = 0

UNION
SELECT 
      'userinfo' as identifier, 
      Count(1) as row_cnt, 
      Max(iif(ugrp_last_updated_datetime > 
          iif(user_last_updated_datetime > lss_last_updated_datetime, user_last_updated_datetime, lss_last_updated_datetime),
          ugrp_last_updated_datetime,
          iif(user_last_updated_datetime > lss_last_updated_datetime, user_last_updated_datetime, lss_last_updated_datetime)))
      as max_date
FROM tt_login_server_settings, tt_user_group INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id
WHERE tt_user.user_login = ?



-- Used in xt 7.9
--$get_revision_info_by_login_xt_731
SELECT 
      'cusd' as identifier, 
      Count(1) as row_cnt, 
      Max(iif(cusd_last_updated_datetime > acct_last_updated_datetime, cusd_last_updated_datetime, acct_last_updated_datetime)) as max_date
FROM tt_account 
INNER JOIN (tt_user 
INNER JOIN tt_customer_default ON tt_user.user_id = tt_customer_default.cusd_user_id) ON tt_account.acct_id = tt_customer_default.cusd_account_id
WHERE tt_user.user_login= ?

UNION
SELECT 
      'acctd' as identifier, 
      Count(1) as row_cnt, 
      Max(iif(acctd_last_updated_datetime > acctd_last_updated_datetime, acctd_last_updated_datetime, acctd_last_updated_datetime)) as max_date
FROM
      tt_account_default INNER JOIN 
      tt_user ON tt_user.user_id = tt_account_default.acctd_user_id
WHERE tt_user.user_login= ?

UNION

SELECT 
      'uur' as identifier, 
      Count(1) as row_cnt, 
      Max(tt_user_user_relationship.uur_last_updated_datetime) as max_date
FROM tt_user_user_relationship INNER JOIN tt_user AS tt_user_2 ON tt_user_user_relationship.uur_user_id2 = tt_user_2.user_id
WHERE tt_user_user_relationship.uur_relationship_type = 'fix' AND tt_user_2.user_login = ?

UNION


SELECT 
       'ares' as identifier,
       Count(tt_user_account.uxa_user_id) AS row_cnt, 
       Max(tt_user_account.uxa_last_updated_datetime) AS max_date
FROM tt_user LEFT JOIN tt_user_account ON tt_user.user_id = tt_user_account.uxa_user_id
WHERE tt_user.user_login = ?

UNION
SELECT 
      'userinfo' as identifier, 
      Count(1) as row_cnt, 
      Max(iif(user_last_updated_datetime > lss_last_updated_datetime, user_last_updated_datetime, lss_last_updated_datetime)) as max_date
FROM tt_user, tt_login_server_settings
WHERE tt_user.user_login = ?



-----------------------------------------------------------------------

--$get_product_limits_by_gateway_id_xt
SELECT
      tt_user.user_login,
      tt_user.user_allow_trading,
      tt_mgt.mgt_id,
      tt_mgt.mgt_comp_id,
      tt_mgt.mgt_member as [trdr_member],
      tt_mgt.mgt_group as [trdr_group],
      tt_mgt.mgt_trader as [trdr_trader],
      tt_mgt.mgt_risk_on,
      tt_product_limit.plim_gateway_id, 
      tt_product_limit.plim_product, 
      tt_product_limit.plim_product_type, 
      tt_product_limit.plim_additional_margin_pct, 
      tt_product_limit.plim_max_order_qty, 
      tt_product_limit.plim_max_position, 
      tt_product_limit.plim_allow_tradeout, 
      tt_product_limit.plim_addl_margin_pct_on, 
      tt_product_limit.plim_max_order_qty_on, 
      tt_product_limit.plim_max_position_on, 
      tt_product_limit.plim_max_long_short_on, 
      tt_product_limit.plim_max_long_short,
      tt_product_limit.plim_prevent_orders_based_on_price_ticks,
      tt_product_limit.plim_prevent_orders_price_ticks,
      tt_product_limit.plim_enforce_price_limit_on_buysell_only,
      tt_product_limit.plim_last_updated_datetime,
      tt_product_limit.plim_allow_trading
FROM (tt_gmgt INNER JOIN (tt_user 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
INNER JOIN (tt_mgt INNER JOIN tt_product_limit ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id) 
ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)
WHERE tt_product_limit.plim_gateway_id = tt_gmgt.gm_gateway_id
and tt_product_limit.plim_for_simulation = 0
and tt_product_limit.plim_gateway_id = ?

-----------------------------------------------------------------------

--$get_fix_adapter_clients_fa
SELECT tt_user_1.user_id, tt_user_1.user_login, uur_last_updated_datetime as last_updated_datetime
FROM (tt_user_user_relationship 
INNER JOIN tt_user AS tt_user_1 ON tt_user_user_relationship.uur_user_id1 = tt_user_1.user_id) INNER JOIN tt_user AS tt_user_2 ON tt_user_user_relationship.uur_user_id2 = tt_user_2.user_id
where tt_user_user_relationship.uur_relationship_type = 'fix'
and tt_user_2.user_login = ?
and tt_user_1.user_status = 1


-----------------------------------------------------------------------

-- return nothing in sim mode
--$get_users_an_xrisk_admin_can_admin_sim
SELECT '' as other_user_login, '' as other_user_id, 0 as user_comp_id
from tt_gateway
WHERE 1 = 2

-----------------------------------------------------------------------

--$get_product_margins_xt

SELECT 
tt_company_market_product.cmkp_comp_id, 
tt_company_market_product.cmkp_market_id, 
tt_company_market_product.cmkp_product_type, 
tt_company_market_product.cmkp_product, 
tt_company_market_product.cmkp_margin_times_100,
tt_company_market_product.cmkp_last_updated_datetime as last_updated_datetime
FROM tt_company_market_product 
WHERE tt_company_market_product.cmkp_margin_times_100 <> 0;

-----------------------------------------------------------------------

--$get_user_companies_xt

SELECT 
tt_user.user_login,
tt_user_company_permission.ucp_comp_id,       
tt_user_company_permission.ucp_customer_default_editing_allowed,  
tt_user_company_permission.ucp_fix_adapter_default_editing_allowed,
tt_user_company_permission.ucp_last_updated_datetime as last_updated_datetime,
tt_user_company_permission.ucp_cross_orders_allowed,
tt_user_company_permission.ucp_wholesale_trades_allowed,
tt_user_company_permission.ucp_wholesale_orders_with_undefined_accounts_allowed,
tt_user_company_permission.ucp_persist_orders_on_eurex,
tt_user_company_permission.ucp_prevent_orders_based_on_price_ticks,
tt_user_company_permission.ucp_prevent_orders_price_ticks,
tt_user_company_permission.ucp_enforce_price_limit_on_buysell_only,
tt_user_company_permission.ucp_prevent_orders_based_on_rate,
tt_user_company_permission.ucp_prevent_orders_rate,
tt_user_company_permission.ucp_dma_order_creation_allowed,
tt_user_company_permission.ucp_fix_dma_order_creation_allowed,
tt_user_company_permission.ucp_gtc_orders_allowed,
tt_user_company_permission.ucp_cross_orders_cancel_resting,
tt_user_company_permission.ucp_organization,
IIF((tt_user.user_allow_trading = 1 OR tt_company.comp_is_broker = 1 ) AND tt_user_company_permission.ucp_allow_trading = 1, CBYTE(1), CBYTE(0)) AS ucp_allow_trading,
tt_user_company_permission.ucp_xrisk_sods_allowed,
tt_user_company_permission.ucp_xrisk_manual_fills_allowed,
tt_user_company_permission.ucp_ttapi_allowed,
tt_user_company_permission.ucp_xtapi_allowed,
tt_user_company_permission.ucp_autotrader_allowed,
tt_user_company_permission.ucp_autospreader_allowed,
tt_user_company_permission.ucp_undefined_accounts_allowed,
tt_user_company_permission.ucp_account_changes_allowed,
tt_user_company_permission.ucp_account_permissions_enabled,
tt_user_company_permission.ucp_can_submit_market_orders,
tt_user_company_permission.ucp_can_submit_iceberg_orders,
tt_user_company_permission.ucp_can_submit_time_sliced_orders,
tt_user_company_permission.ucp_can_submit_volume_sliced_orders,
tt_user_company_permission.ucp_can_submit_time_duration_orders,
tt_user_company_permission.ucp_can_submit_volume_duration_orders,
tt_user_company_permission.ucp_machine_gun_orders_allowed,
tt_user_company_permission.ucp_quoting_allowed,
tt_user_company_permission.ucp_2fa_required_mode,
tt_user_company_permission.ucp_can_manage_trader_based_product_limits,
tt_user_company_permission.ucp_ob_passing_group_id,
tt_user_company_permission.ucp_aggregator_allowed,
tt_user_company_permission.ucp_sniper_orders_allowed,
tt_user_company_permission.ucp_eu_config_1_allowed,
tt_user_company_permission.ucp_eu_config_1,
tt_user_company_permission.ucp_eu_config_2_allowed,
tt_user_company_permission.ucp_eu_config_2
FROM (( tt_user_company_permission
INNER JOIN tt_user on tt_user.user_id = tt_user_company_permission.ucp_user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
WHERE tt_user.user_login in ('??')
order by tt_user.user_login

-----------------------------------------------------------------------

--$get_user_companies_xt_sim

SELECT 
tt_user.user_login,
tt_user_company_permission.ucp_comp_id,       
tt_user_company_permission.ucp_customer_default_editing_allowed,  
tt_user_company_permission.ucp_fix_adapter_default_editing_allowed,
tt_user_company_permission.ucp_last_updated_datetime as last_updated_datetime,
CBYTE(1) as ucp_cross_orders_allowed,
CBYTE(1) as ucp_wholesale_trades_allowed,
CBYTE(1) as ucp_wholesale_orders_with_undefined_accounts_allowed,
0 as ucp_persist_orders_on_eurex,
tt_user_company_permission.ucp_prevent_orders_based_on_price_ticks,
tt_user_company_permission.ucp_prevent_orders_price_ticks,
tt_user_company_permission.ucp_enforce_price_limit_on_buysell_only,
tt_user_company_permission.ucp_prevent_orders_based_on_rate,
tt_user_company_permission.ucp_prevent_orders_rate,
CBYTE(1) as ucp_dma_order_creation_allowed,
CBYTE(1) as ucp_fix_dma_order_creation_allowed,
CBYTE(1) as ucp_gtc_orders_allowed,
tt_user_company_permission.ucp_cross_orders_cancel_resting,
tt_user_company_permission.ucp_organization,
IIF((tt_user.user_allow_trading = 1 OR tt_company.comp_is_broker = 1 ) AND tt_user_company_permission.ucp_allow_trading = 1, CBYTE(1), CBYTE(0)) AS ucp_allow_trading,
tt_user_company_permission.ucp_xrisk_sods_allowed,
tt_user_company_permission.ucp_xrisk_manual_fills_allowed,
tt_user_company_permission.ucp_ttapi_allowed,
CBYTE(1) as ucp_xtapi_allowed,
CBYTE(1) as ucp_autotrader_allowed,
CBYTE(1) as ucp_autospreader_allowed,
CBYTE(1) as ucp_undefined_accounts_allowed,
CBYTE(1) as ucp_account_changes_allowed,
tt_user_company_permission.ucp_account_permissions_enabled,
CBYTE(1) as ucp_can_submit_market_orders,
CBYTE(1) as ucp_can_submit_iceberg_orders,
CBYTE(1) as ucp_can_submit_time_sliced_orders,
CBYTE(1) as ucp_can_submit_volume_sliced_orders,
CBYTE(1) as ucp_can_submit_time_duration_orders,
CBYTE(1) as ucp_can_submit_volume_duration_orders,
CBYTE(1) as ucp_machine_gun_orders_allowed,
CBYTE(1) as ucp_quoting_allowed,
tt_user_company_permission.ucp_2fa_required_mode,
tt_user_company_permission.ucp_can_manage_trader_based_product_limits,
tt_user_company_permission.ucp_ob_passing_group_id,
CBYTE(1) as ucp_aggregator_allowed,
CBYTE(1) as ucp_sniper_orders_allowed,
CBYTE(0) as ucp_eu_config_1_allowed,
ucp_eu_config_1,
CBYTE(0) as ucp_eu_config_2_allowed,
ucp_eu_config_2
FROM (( tt_user_company_permission
INNER JOIN tt_user on tt_user.user_id = tt_user_company_permission.ucp_user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
WHERE tt_user.user_login in ('??')
order by tt_user.user_login

-----------------------------------------------------------------------

--$get_companies_xt

select 
comp_id, 
comp_name, 
comp_is_broker,
comp_abbrev, 
comp_last_updated_datetime as last_updated_datetime,
comp_trading_enabled
from tt_company

--$get_all_company_bitmaps_as_base64_encoded_gzip_compressed
select blb_key, blb_data from tt_blob where left( blb_key, 13 ) = 'CompanyBitmap'

--$get_company_bitmap_as_base64_encoded_gzip_compressed
select blb_key, blb_data from tt_blob where blb_key = 'CompanyBitmap' + CStr(?)

-----------------------------------------------------------------------

--$get_user_product_groups_xt
SELECT tt_user.user_login,
tt_market_product_group.mkpg_market_id, 
tt_market_product_group.mkpg_product_group_id,
tt_user_product_group.upg_comp_id, 
tt_user_product_group.upg_last_updated_datetime
FROM tt_user 
INNER JOIN (tt_market_product_group 
INNER JOIN tt_user_product_group 
ON tt_market_product_group.mkpg_market_product_group_id = tt_user_product_group.upg_market_product_group_id) 
ON tt_user.user_id = tt_user_product_group.upg_user_id
WHERE tt_user.user_login in ('??')
order by tt_user.user_login

-----------------------------------------------------------------------

--For GuardianMFC logfile collection, not XT.
--$get_recently_used_client_versions_for_gmfc
SELECT 
tt_view_get_recently_used_client_versions_for_gmfc.ipv_tt_product_name, 
tt_ip_address_version.ipv_version, 
tt_view_get_recently_used_client_versions_for_gmfc.last_seen_datetime,
tt_ip_address_version.ipv_lang_id
FROM tt_view_get_recently_used_client_versions_for_gmfc 
INNER JOIN tt_ip_address_version 
ON (tt_view_get_recently_used_client_versions_for_gmfc.ipv_ip_address = tt_ip_address_version.ipv_ip_address) 
AND (tt_view_get_recently_used_client_versions_for_gmfc.ipv_tt_product_name = tt_ip_address_version.ipv_tt_product_name) 
AND (tt_view_get_recently_used_client_versions_for_gmfc.ipv_user_login = tt_ip_address_version.ipv_user_login) 
AND (tt_view_get_recently_used_client_versions_for_gmfc.last_seen_datetime = tt_ip_address_version.ipv_last_updated_datetime)
ORDER BY 1, 2

--For GuardianMFC logfile collection, not XT.
--$get_recently_used_server_versions_for_gmfc
SELECT 
tt_view_get_recently_used_server_versions_for_gmfc.ipv_tt_product_name, 
tt_market.market_name, 
tt_gateway.gateway_name, 
tt_ip_address_version.ipv_version, 
tt_view_get_recently_used_server_versions_for_gmfc.last_seen_datetime,
tt_ip_address_version.ipv_lang_id
FROM tt_view_get_recently_used_server_versions_for_gmfc 
INNER JOIN (tt_ip_address_version 
INNER JOIN (tt_market 
INNER JOIN tt_gateway 
ON tt_market.market_id = tt_gateway.gateway_market_id) 
ON tt_ip_address_version.ipv_gateway_id = tt_gateway.gateway_id) 
ON (tt_view_get_recently_used_server_versions_for_gmfc.ipv_gateway_id = tt_ip_address_version.ipv_gateway_id) 
AND (tt_view_get_recently_used_server_versions_for_gmfc.ipv_tt_product_name = tt_ip_address_version.ipv_tt_product_name) 
AND (tt_view_get_recently_used_server_versions_for_gmfc.ipv_ip_address = tt_ip_address_version.ipv_ip_address) 
AND (tt_view_get_recently_used_server_versions_for_gmfc.last_seen_datetime = tt_ip_address_version.ipv_last_updated_datetime)
ORDER BY 1, 2, 3, 4

--$get_routing_key_by_gateway
SELECT str(tt_mgt.mgt_id) + ',' as routing_key,
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader, 
tt_gmgt.gm_member as exch_member,
tt_gmgt.gm_group as exch_group, 
tt_gmgt.gm_trader as exch_trader,
tt_mgt_gmgt.mxg_last_updated_datetime as last_updated_datetime
FROM tt_mgt INNER JOIN (tt_gmgt INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
WHERE gm_gateway_id = ?
AND mgt_type = 1
union
SELECT tt_account.acct_name,
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader, 
tt_gmgt.gm_member,
tt_gmgt.gm_group, 
tt_gmgt.gm_trader,
tt_account.acct_last_updated_datetime as last_updated_datetime
FROM tt_gmgt 
INNER JOIN ((tt_mgt 
INNER JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id) 
INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id
where gm_gateway_id = ?
AND mgt_type = 1

--$get_routing_key_by_gateway_no_guardian
SELECT str(tt_mgt.mgt_id) + ',' as routing_key,
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader, 
tt_gmgt.gm_member as exch_member,
tt_gmgt.gm_group as exch_group, 
tt_gmgt.gm_trader as exch_trader,
tt_mgt_gmgt.mxg_last_updated_datetime as last_updated_datetime
FROM tt_mgt INNER JOIN (tt_gmgt INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
WHERE gm_gateway_id = ?
AND mgt_type = 1

--$get_mgt_passwords_by_gateway
SELECT distinct
tt_mgt_1.mgt_member as exch_member, 
tt_mgt_1.mgt_group as exch_group, 
tt_mgt_1.mgt_trader as exch_trader, 
tt_mgt_1.mgt_password,
tt_mgt_1.mgt_last_updated_datetime as last_updated_datetime
FROM (tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN tt_mgt_gmgt 
ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) 
ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
INNER JOIN tt_mgt AS tt_mgt_1 
ON (tt_gmgt.gm_trader = tt_mgt_1.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt_1.mgt_group) AND (tt_gmgt.gm_member = tt_mgt_1.mgt_member)
WHERE tt_gmgt.gm_gateway_id = ?
and tt_mgt.mgt_password <> ''

--$get_mgt_passwords_by_mgt
SELECT 
tt_mgt.mgt_member as exch_member, 
tt_mgt.mgt_group as exch_group, 
tt_mgt.mgt_trader as exch_trader, 
tt_mgt.mgt_password,
tt_mgt.mgt_last_updated_datetime as last_updated_datetime
FROM tt_mgt 
WHERE tt_mgt.mgt_member + tt_mgt.mgt_group + tt_mgt.mgt_trader in ('??')
and tt_mgt.mgt_password <> ''
order by tt_mgt.mgt_member, tt_mgt.mgt_group, tt_mgt.mgt_trader

--$get_accounts_for_gateways
select 
acct_name, 
acct_comp_id,
acct_last_updated_datetime as last_updated_datetime
from tt_account 
where acct_include_in_auto_sods = 0
and acct_id > 1

--$get_bvmf_participants
select 
bvmf_participant_code,
bvmf_participant_name,
bvmf_last_updated_datetime as last_updated_datetime
from tt_bvmf_participant

--$get_users_who_can_connect_to_gateway
SELECT distinct tt_user.user_id, tt_user.user_login, user_last_updated_datetime as last_updated_datetime
FROM tt_gmgt 
INNER JOIN (tt_user 
INNER JOIN tt_user_gmgt 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
WHERE gm_gateway_id = ?
AND (uxg_available_to_user = 1 or (user_fix_adapter_role = 1 and uxg_available_to_fix_adapter_user = 1))

--$get_gateways_linked_to_user
SELECT distinct tt_gmgt.gm_gateway_id
FROM tt_gmgt 
INNER JOIN (tt_user 
INNER JOIN tt_user_gmgt 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
WHERE tt_user.user_id = ?
AND (uxg_available_to_user = 1 or (user_fix_adapter_role = 1 and uxg_available_to_fix_adapter_user = 1))

-----------------------------------------------------------------------

--$get_users_for_billing
SELECT 
tt_user.user_login, 
tt_user.user_display_name, 
tt_user.user_city, 
tt_us_state.state_abbrev,
tt_user.user_postal_code, 
tt_country.country_code, 
tt_country.country_name, 
'' as [buy_side_comp_name],
0 as [buy_side_comp_id],
tt_user.user_def1 as [billing1],
tt_user.user_def2 as [billing2],
tt_user.user_def3 as [billing3],
'' as [broker_name],
0 as [broker_id],
tt_user.user_most_recent_login_datetime as last_login
FROM tt_us_state 
RIGHT JOIN (tt_country 
RIGHT JOIN tt_user 
ON tt_country.country_id = tt_user.user_country_id) 
ON tt_us_state.state_id = tt_user.user_state_id
WHERE 0 = (SELECT lss_multibroker_mode FROM tt_login_server_settings)
UNION
SELECT 
    tt_user.user_login, 
    tt_user.user_display_name, 
    tt_user.user_city, 
    tt_us_state.state_abbrev, 
    tt_user.user_postal_code, 
    tt_country.country_code, 
    tt_country.country_name,
    tt_company.comp_name as [buy_side_comp_name], 
    tt_company.comp_id as [buy_side_comp_id], 
    tt_user_company_permission.ucp_billing1 as [billing1], 
    tt_user_company_permission.ucp_billing2 as [billing2], 
    tt_user_company_permission.ucp_billing3 as [billing3], 
    tt_company_1.comp_name as [broker_name],
    tt_company_1.comp_id as [broker_id],
    tt_user.user_most_recent_login_datetime as last_login
FROM ((((( tt_user
INNER JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
INNER JOIN tt_company AS tt_company_1 ON tt_user_company_permission.ucp_comp_id = tt_company_1.comp_id )
LEFT JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
LEFT JOIN tt_country ON tt_user.user_country_id = tt_country.country_id
WHERE 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
    AND ( 0 = tt_user.user_mgt_generation_method OR 1 = tt_company.comp_is_broker )
UNION
SELECT
    [user].user_login,
    [user].user_display_name,
    [user].user_city,
    [user].state_abbrev,
    [user].user_postal_code,
    [user].country_code,
    [user].country_name,
    [user].buy_side_comp_name,
    [user].buy_side_comp_id,
    '' as [billing1],
    '' as [billing3],
    '' as [billing2],
    [combos].broker_comp_name as [broker_name],
    [combos].broker_comp_id as [broker_id],
    [user].last_login
FROM
(
    SELECT
        buy_side_company.comp_id as [buy_side_comp_id],
        broker_company.comp_id as [broker_comp_id],
        broker_company.comp_name as [broker_comp_name]
    FROM ((((( tt_company AS [buy_side_company]
    INNER JOIN tt_user_group ON buy_side_company.comp_id = tt_user_group.ugrp_comp_id )
    INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id )
    INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
    INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
    INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader )
    INNER JOIN tt_company AS [broker_company] ON tt_mgt.mgt_comp_id = broker_company.comp_id
    WHERE 1 = broker_company.comp_is_broker
        AND ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
        AND 0 = buy_side_company.comp_is_broker
    GROUP BY
        buy_side_company.comp_id,
        broker_company.comp_id,
        broker_company.comp_name
) [combos]
INNER JOIN
(
    SELECT 
        tt_user.user_login, 
        tt_user.user_display_name, 
        tt_user.user_city, 
        tt_us_state.state_abbrev, 
        tt_user.user_postal_code, 
        tt_country.country_code, 
        tt_country.country_name,
        tt_company.comp_name as [buy_side_comp_name], 
        tt_company.comp_id as [buy_side_comp_id], 
        tt_user.user_most_recent_login_datetime as last_login
    FROM ((( tt_user
    INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
    INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
    LEFT JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
    LEFT JOIN tt_country ON tt_user.user_country_id = tt_country.country_id
    WHERE 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
        AND ( 1 = tt_user.user_mgt_generation_method AND 0 = tt_company.comp_is_broker )
) [user] ON [combos].buy_side_comp_id = [user].buy_side_comp_id
UNION
    SELECT 
        tt_user.user_login, 
        tt_user.user_display_name, 
        tt_user.user_city, 
        tt_us_state.state_abbrev, 
        tt_user.user_postal_code, 
        tt_country.country_code, 
        tt_country.country_name,
        tt_company.comp_name as [buy_side_comp_name], 
        tt_company.comp_id as [buy_side_comp_id], 
        '' as [billing1],
        '' as [billing3],
        '' as [billing2],
        tt_company.comp_name as [broker_name],
        tt_company.comp_id as [broker_id],
        tt_user.user_most_recent_login_datetime as last_login
        FROM ((( tt_user
        INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
        INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
        LEFT JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
        LEFT JOIN tt_country ON tt_user.user_country_id = tt_country.country_id
        WHERE 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
            AND  0 = tt_company.comp_is_broker
            AND tt_user.user_fix_adapter_role > 1  

--$get_buyside_broker_relationships_for_billing
select
    buyside.comp_id as [buyside_comp_id],
    buyside.comp_name as [buyside_comp_name],
    broker.comp_id as [broker_comp_id],
    broker.comp_name as [broker_comp_name]
from ( tt_company_company_permission
inner join tt_company as buyside on tt_company_company_permission.ccp_buyside_comp_id = buyside.comp_id )
inner join tt_company as broker on tt_company_company_permission.ccp_broker_comp_id = broker.comp_id
where 1 = (SELECT lss_multibroker_mode FROM tt_login_server_settings)
union
select
    comp_id as [buyside_comp_id],
    comp_name as [buyside_comp_name],
    comp_id as [broker_comp_id],
    comp_name as [broker_comp_name]
from tt_company
where 0 = (SELECT lss_multibroker_mode FROM tt_login_server_settings)

--$get_users_products_brokers_for_billing
select
    ipvcur.ipv_user_login as [user_login],
    iif( ipvcur.ipv_tt_product_id < 0, -ipvcur.ipv_tt_product_id, ipvcur.ipv_tt_product_id ) as [product_id],
    broker.comp_id as [broker_comp_id],
    broker.comp_name as [broker_comp_name],
    ipvcur.ipv_last_updated_datetime as [last_login_datetime]
from ((((( tt_ip_address_version as ipvcur
inner join (
    select ipv_user_login, ipv_tt_product_id, max( ipv_last_updated_datetime ) as [max_datetime]
    from tt_ip_address_version
    where ipv_user_login <> ''
    group by ipv_user_login, ipv_tt_product_id
) maxipv on ipvcur.ipv_user_login = maxipv.ipv_user_login
                    and ipvcur.ipv_tt_product_id = maxipv.ipv_tt_product_id
                    and ipvcur.ipv_last_updated_datetime = maxipv.max_datetime )
inner join tt_user on ipvcur.ipv_user_login = tt_user.user_login )
inner join tt_user_gmgt on tt_user.user_id = tt_user_gmgt.uxg_user_id )
inner join tt_gmgt on tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
inner join tt_mgt on tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader )
inner join tt_company as broker on tt_mgt.mgt_comp_id = broker.comp_id
where tt_mgt.mgt_comp_id <> 0
    and 1 = (SELECT lss_multibroker_mode FROM tt_login_server_settings)
    and 0 = tt_user.user_mgt_generation_method
group by ipvcur.ipv_user_login, iif( ipvcur.ipv_tt_product_id < 0, -ipvcur.ipv_tt_product_id, ipvcur.ipv_tt_product_id ), broker.comp_id, broker.comp_name, ipvcur.ipv_last_updated_datetime

union

select
    ipvcur.ipv_user_login as [user_login],
    iif( ipvcur.ipv_tt_product_id < 0, -ipvcur.ipv_tt_product_id, ipvcur.ipv_tt_product_id ) as [product_id],
    broker.comp_id as [broker_comp_id],
    broker.comp_name as [broker_comp_name],
    ipvcur.ipv_last_updated_datetime as [last_login_datetime]
from ((( tt_ip_address_version as ipvcur
inner join (
    select ipv_user_login, ipv_tt_product_id, max( ipv_last_updated_datetime ) as [max_datetime]
    from tt_ip_address_version
    where ipv_user_login <> ''
    group by ipv_user_login, ipv_tt_product_id
) maxipv on ipvcur.ipv_user_login = maxipv.ipv_user_login
                    and ipvcur.ipv_tt_product_id = maxipv.ipv_tt_product_id
                    and ipvcur.ipv_last_updated_datetime = maxipv.max_datetime )
inner join tt_user on ipvcur.ipv_user_login = tt_user.user_login )
inner join tt_user_group on tt_user.user_group_id = tt_user_group.ugrp_group_id )
inner join tt_company as broker on tt_user_group.ugrp_comp_id = broker.comp_id
where broker.comp_id <> 0
    and 1 = broker.comp_is_broker
    and 1 = (SELECT lss_multibroker_mode FROM tt_login_server_settings)
    and 0 <> tt_user.user_mgt_generation_method
group by ipvcur.ipv_user_login, iif( ipvcur.ipv_tt_product_id < 0, -ipvcur.ipv_tt_product_id, ipvcur.ipv_tt_product_id ), broker.comp_id, broker.comp_name, ipvcur.ipv_last_updated_datetime
union
select
    users.user_login,
    users.product_id,
    brokers.broker_comp_id,
    brokers.broker_comp_name,
    users.last_login_datetime
from
(
  select distinct
      ipvcur.ipv_user_login as [user_login],
      iif( ipvcur.ipv_tt_product_id < 0, -ipvcur.ipv_tt_product_id, ipvcur.ipv_tt_product_id ) as [product_id],
      ipvcur.ipv_last_updated_datetime as [last_login_datetime],
      tt_user.user_group_id,
      tt_gmgt.gm_gateway_id
  from ((((( tt_ip_address_version as ipvcur
  inner join (
      select ipv_user_login, ipv_tt_product_id, max( ipv_last_updated_datetime ) as [max_datetime]
      from tt_ip_address_version
      where ipv_user_login <> ''
      group by ipv_user_login, ipv_tt_product_id
  ) maxipv on ipvcur.ipv_user_login = maxipv.ipv_user_login
                      and ipvcur.ipv_tt_product_id = maxipv.ipv_tt_product_id
                      and ipvcur.ipv_last_updated_datetime = maxipv.max_datetime )
  inner join tt_user on ipvcur.ipv_user_login = tt_user.user_login )
  inner join tt_user_gmgt on tt_user.user_id = tt_user_gmgt.uxg_user_id )
  inner join tt_gmgt on tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
  inner join tt_mgt on tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader )
  where tt_mgt.mgt_comp_id = 0
      and ( tt_user_gmgt.uxg_available_to_user = 1 or ( tt_user.user_fix_adapter_role = 1 and tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
  group by ipvcur.ipv_user_login, iif( ipvcur.ipv_tt_product_id < 0, -ipvcur.ipv_tt_product_id, ipvcur.ipv_tt_product_id ), ipvcur.ipv_last_updated_datetime, tt_user.user_group_id, tt_gmgt.gm_gateway_id
) as users
inner join
(
  select
      tt_user.user_group_id,
      tt_gmgt.gm_gateway_id,
      broker.comp_id as [broker_comp_id],
      broker.comp_name as [broker_comp_name]
  from ((( tt_user
  inner join tt_user_gmgt on tt_user.user_id = tt_user_gmgt.uxg_user_id )
  inner join tt_gmgt on tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
  inner join tt_mgt on tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader )
  inner join tt_company as broker on tt_mgt.mgt_comp_id = broker.comp_id
  where tt_mgt.mgt_comp_id <> 0
      and ( tt_user_gmgt.uxg_available_to_user = 1 or ( tt_user.user_fix_adapter_role = 1 and tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
  group by tt_user.user_group_id, tt_gmgt.gm_gateway_id, broker.comp_id, broker.comp_name
) as brokers on users.user_group_id = brokers.user_group_id and users.gm_gateway_id = brokers.gm_gateway_id
where 1 = (SELECT lss_multibroker_mode FROM tt_login_server_settings)
group by
    users.user_login,
    users.product_id,
    brokers.broker_comp_id,
    brokers.broker_comp_name,
    users.last_login_datetime
union
select 
    ipvcur.ipv_user_login as [user_login],
    iif( ipvcur.ipv_tt_product_id < 0, -ipvcur.ipv_tt_product_id, ipvcur.ipv_tt_product_id ) as [product_id],
    broker.comp_id as [broker_comp_id],
    broker.comp_name as [broker_comp_name],
    ipvcur.ipv_last_updated_datetime as [last_login_datetime]
from ((((( tt_ip_address_version as ipvcur
inner join (
    select ipv_user_login, ipv_tt_product_id, max( ipv_last_updated_datetime ) as [max_datetime]
    from tt_ip_address_version
    where ipv_user_login <> ''
    group by ipv_user_login, ipv_tt_product_id
) maxipv on ipvcur.ipv_user_login = maxipv.ipv_user_login
                    and ipvcur.ipv_tt_product_id = maxipv.ipv_tt_product_id
                    and ipvcur.ipv_last_updated_datetime = maxipv.max_datetime )
inner join tt_user on ipvcur.ipv_user_login = tt_user.user_login )
inner join tt_user_gmgt on tt_user.user_id = tt_user_gmgt.uxg_user_id )
inner join tt_gmgt on tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
inner join tt_mgt on tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader )
inner join tt_company as broker on tt_mgt.mgt_comp_id = broker.comp_id
where 0 = (SELECT lss_multibroker_mode FROM tt_login_server_settings)
group by ipvcur.ipv_user_login, iif( ipvcur.ipv_tt_product_id < 0, -ipvcur.ipv_tt_product_id, ipvcur.ipv_tt_product_id ), broker.comp_id, broker.comp_name, ipvcur.ipv_last_updated_datetime

UNION 

select distinct
    ipvcur.ipv_user_login as [user_login],
    iif( ipvcur.ipv_tt_product_id < 0, -ipvcur.ipv_tt_product_id, ipvcur.ipv_tt_product_id ) as [product_id],
    broker.comp_id as [broker_comp_id],
    broker.comp_name as [broker_comp_name],
    ipvcur.ipv_last_updated_datetime as [last_login_datetime]
from (((( tt_ip_address_version as ipvcur
inner join (
    select ipv_user_login, ipv_tt_product_id, max( ipv_last_updated_datetime ) as [max_datetime]
    from tt_ip_address_version
    where ipv_user_login <> ''
    group by ipv_user_login, ipv_tt_product_id
) maxipv on ipvcur.ipv_user_login = maxipv.ipv_user_login
                    and ipvcur.ipv_tt_product_id = maxipv.ipv_tt_product_id
                    and ipvcur.ipv_last_updated_datetime = maxipv.max_datetime )
inner join tt_user on ipvcur.ipv_user_login = tt_user.user_login )
inner join tt_user_group on tt_user_group.ugrp_group_id = tt_user.user_group_id)
inner join tt_company as broker on tt_user_group.ugrp_comp_id = broker.comp_id)
where (tt_user.user_mgt_generation_method = 1 or tt_user.user_mgt_generation_method = 2)
  OR  (tt_user.user_fix_adapter_role = 2 or tt_user.user_fix_adapter_role = 3)

--$get_buy_side_companies_with_permissions_for_broker
SELECT tt_company.comp_id, tt_company.comp_name
FROM tt_company INNER JOIN tt_view_companies_related_to_broker ON tt_company.comp_id = tt_view_companies_related_to_broker.related_comp_id
WHERE tt_view_companies_related_to_broker.broker_comp_id = ?
AND tt_company.comp_id <> tt_view_companies_related_to_broker.broker_comp_id

--$get_buyside_broker_possible_relationships_and_their_approval_status
select
    allpairs.buyside_comp_id,
    allpairs.buyside_comp_name,
    allpairs.broker_comp_id,
    allpairs.broker_comp_name,
    iif( ccp.ccp_id is not null, CByte(1), CByte(0) ) as [approved]
from
    ( select
          buyside.comp_id as [buyside_comp_id],
          buyside.comp_name as [buyside_comp_name],
          broker.comp_id as [broker_comp_id],
          broker.comp_name as [broker_comp_name]
      from tt_company as buyside, tt_company as broker
      where buyside.comp_is_broker = 0 and broker.comp_is_broker = 1 and buyside.comp_id <> 0 and broker.comp_id <> 0
    ) as allpairs
left join tt_company_company_permission as ccp on allpairs.buyside_comp_id = ccp.ccp_buyside_comp_id and allpairs.broker_comp_id = ccp.ccp_broker_comp_id

