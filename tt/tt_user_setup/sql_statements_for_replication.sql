-----------------------------------------------------------------------
-- inserts for replication start here
-----------------------------------------------------------------------

--$rep_private_insert_password_history
insert into tt_password_history2
values
(
?,?,?,?,
?,?,?
)

--$rep_private_insert_blob
insert into tt_blob
values
(
?,?,?,?,
?,?,?,?,
?,?
)

--$rep_insert_epg_subscription_agreement
INSERT INTO tt_user_mpg_sub_agreement
    ( umsa_id, umsa_created_datetime, umsa_created_user_id, umsa_last_updated_datetime, umsa_last_updated_user_id,
      umsa_user_id, umsa_market_product_group_id )
VALUES
(
?,?,?,?,
?,?,?
)


--$rep_insert_currency
insert into tt_currency
values
(
?,?,?,?,
?,?
)

--$rep_insert_currency_exchange_rate
insert into tt_currency_exchange_rate
values
(
?,?,?,?,
?,?,?,?
)

--$rep_insert_company_market_product
insert into tt_company_market_product
values
(
?,?,?,?,
?,?,?,?,
?,?,?
)

--$rep_insert_app_version_rule
insert into tt_app_version_rule
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?
)

--$rep_insert_work_item
insert into tt_work_item
values
(
?,?,?,?,
?,?,?,?,
?,?,?
)


--$rep_insert_company_company_permission
insert into tt_company_company_permission
values
(
?,?,?,?,
?,?,?
)

--$rep_insert_user_user_relationship
insert into tt_user_user_relationship
values
(
?,?,?,?,
?,?,?,?
)

--$rep_insert_company
insert into tt_company
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?
)

--$rep_insert_ob_passing_group
insert into tt_ob_passing_group
(
obpg_id,
obpg_created_datetime,
obpg_created_user_id,
obpg_last_updated_datetime,
obpg_last_updated_user_id,
obpg_group_name,
obpg_owning_comp_id,
obpg_assigned_comp_id,
obpg_allow_ob_passing_to_all,
obpg_show_accounts_on_passed_orders
) 
values
(
?,?,?,?,
?,?,?,?,
?,?
)

--$rep_insert_netting_organization
insert into tt_netting_organization
(
no_id,
no_created_datetime,
no_created_user_id,
no_last_updated_datetime,
no_last_updated_user_id,
no_comp_id,
no_name,
no_tt_approved,
no_notes
) 
values
(
?,?,?,?,
?,?,?,?,
?
)

--$rep_insert_algo_type
insert into tt_algos
(
al_algo_id,
al_created_datetime,
al_created_user_id,
al_last_updated_datetime,
al_last_updated_user_id,
al_algo_name,
al_comp_id,
al_editable
)
values
(
?,?,?,?,
?,?,?,?
)

--$rep_insert_user_company
insert into tt_user_company_permission
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?
)

--$rep_insert_user_account
insert into tt_user_account
values
(
?,?,?,?,
?,?,?,?,
?
)

--$rep_insert_contract_limit
insert into tt_contract_limit
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?
)

--$rep_insert_product_limit
insert into tt_product_limit
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?
)

--$rep_insert_margin_limit
insert into tt_margin_limit
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?
)

--$rep_insert_mxg
insert into tt_mgt_gmgt
values
(
?,?,?,?,
?,?,?
)

--$rep_insert_mgt
insert into tt_mgt
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?
)


--$rep_insert_gmgt
insert into tt_gmgt
values (
?,?,?,?,
?,?,?,?,
?,?
)


--$rep_insert_user_group
insert into tt_user_group
values (
?,?,?,?,
?,?,?,?,
?,?
)


--$rep_insert_user
insert into tt_user
(
user_id,

--1 // just for correlating fields and question marks
user_created_datetime,
user_created_user_id,
user_last_updated_datetime,
user_last_updated_user_id,

--2
user_group_id,
user_login,
user_display_name,
user_password,

--3
user_city,
user_postal_code,
user_state_id,
user_country_id,

--4
user_status,
user_password_never_expires,
user_must_change_password_next_login,
user_most_recent_password_change_datetime,

--5
user_most_recent_login_datetime,
-- defaulted to zero, don't pass
user_failed_login_attempts_count,
user_def1,
user_def2,

--6
user_def3,
user_enforce_ip_login_limit,
user_ip_login_limit,
user_email,

--7
user_restrict_customer_default_editing,
user_address,
user_phone,
user_def4,

--8
user_def5,
user_def6,
user_x_trader_mode,
--hardcoded
user_login_attempt_key,

--9
user_fix_adapter_enable_order_logging,
user_fix_adapter_enable_price_logging,
user_fix_adapter_default_editing_allowed,
user_xrisk_sods_allowed,

--10
user_xrisk_manual_fills_allowed,
user_xrisk_prices_allowed,     
user_xrisk_instant_messages_allowed,
user_cross_orders_allowed,

--11
user_user_setup_user_type,
user_smtp_host,
user_smtp_port,
user_smtp_requires_authentication,

--12
user_smtp_login_user,
user_smtp_login_password,
user_smtp_use_ssl,
user_smtp_from_address,

--13
user_smtp_subject,
user_smtp_body,
user_smtp_include_username_in_message,
user_smtp_enable_settings,

--14
user_quoting_allowed,
user_wholesale_trades_allowed,
user_fmds_allowed,
user_credit,

--15
user_currency,
user_allow_trading,
--hardcoded
user_force_logoff_switch,
user_fix_adapter_role,

--16
user_cross_orders_cancel_resting,
user_fmds_primary_ip,
user_fmds_primary_port,
user_fmds_primary_service,

--17
user_fmds_primary_timeout_in_secs,
user_fmds_secondary_ip,
user_fmds_secondary_port,
user_fmds_secondary_service,

--18
user_fmds_secondary_timeout_in_secs,
user_gui_view_type,
user_use_user_level_fmds_settings,
user_most_recent_failed_login_attempt_datetime,

--19
user_marked_for_deletion_datetime,
user_ttapi_allowed,
user_mgt_generation_method,
user_staged_order_creation_allowed,

--20
user_staged_order_claiming_allowed,
user_dma_order_creation_allowed,
user_fix_staged_order_creation_allowed,
--user_fix_staged_order_claiming_allowed,

--21
user_fix_dma_order_creation_allowed,
user_use_pl_risk_algo,
user_xrisk_update_trading_allowed_allowed,
user_ttapi_admin_edition_allowed,

--22
user_most_recent_login_datetime_for_inactivity,
user_use_simulation_credit,
user_simulation_credit,
user_on_behalf_of_allowed,

--23
user_mgt_generation_method_member,
user_mgt_generation_method_group,
user_non_simulation_allowed,
user_organization,

--24
user_simulation_allowed,
user_machine_gun_orders_allowed,
user_persist_orders_on_eurex,
user_prevent_orders_based_on_price_ticks,

--25
int_user_prevent_orders_price_ticks,
user_enforce_price_limit_on_buysell_only,
user_prevent_orders_based_on_rate,
int_user_prevent_orders_rate,

--26
user_gtc_orders_allowed,
user_undefined_accounts_allowed,
user_account_changes_allowed,
user_no_sod_user_group_restrictions,

--27
user_liquidate_exceeding_position_limits_allowed,
user_billing1,
user_billing2,
user_billing3,

--28
user_never_locked_by_inactivity,
user_most_recent_login_ip,
user_most_recent_xt_version,
user_most_recent_fa_version,

--29
user_most_recent_xr_version,
user_algo_deployment_allowed,
user_algo_sharing_allowed,
user_individually_select_admin_logins,

--30
user_ignore_pl,
user_ignore_margin,
user_claim_own_staged_orders_allowed,
user_wholesale_orders_with_undefined_accounts_allowed,

--31
user_account_permissions_enabled,
user_can_submit_market_orders,
user_xrisk_allowed,
user_2fa_required,

--32
user_xtapi_allowed,
user_autotrader_allowed,
user_autospreader_allowed,
user_can_submit_iceberg_orders,

--33
user_can_submit_time_sliced_orders,
user_can_submit_volume_sliced_orders,
user_can_submit_time_duration_orders,
user_can_submit_volume_duration_orders,

--34
user_sms_number,
user_gf_cbot,
user_gf_cme,
user_gf_cme_europe,

--35
user_gf_comex,
user_gf_nymex,
user_gf_dme,
user_netting_cbot,

--36
user_netting_cme,
user_netting_cme_europe,
user_netting_comex,
user_netting_nymex,

--37
user_netting_dme,
user_netting_organization_id,
user_fa_category_id,
user_2fa_required_mode,

--38
user_fix_subscribers_cbot,
user_fix_subscribers_cme,
user_fix_subscribers_cme_europe,
user_fix_subscribers_comex,

--39
user_fix_subscribers_nymex,
user_fix_subscribers_dme,
user_mgt_auto_login,
user_sw_ice_fut_can,

--40
user_sw_ice_phy_env,
user_sw_ice_ifus_gas,
user_sw_ice_ifeu_oil,
user_sw_ice_ifus_pwr,

--41
user_sw_ice_ifeu_com,
user_sw_ice_fut_us,
user_sw_ice_ifeu_fin,
user_sw_ice_endex,

--42
user_sw_ice_fut_sg,
user_aggregator_allowed,
user_sniper_orders_allowed,
user_eu_config_1_allowed,

--43
user_eu_config_1,
user_eu_config_2_allowed,
user_eu_config_2
)

values
(
?,
--1
?,?,?,?,
?,?,?,?,
?,?,?,?,

--4
?,?,?,?,
?,0,?,?,
?,?,?,?,

--7
?,?,?,?,
?,?,?,0,
?,?,?,?,

--10
?,?,?,?,
?,?,?,?,
?,?,?,?,

--13
?,?,?,?,
?,?,?,?,
?,?,0,?,

--16
?,?,?,?,
?,?,?,?,
?,?,?,#1970-01-02 00:00:00#,

--19
#1970-01-02 00:00:00#,?,?,?,
?,?,?,
?,?,?,?,

--22
#1970-01-02 00:00:00#,?,?,?,
?,?,?,?,
?,?,?,?,

--25
?,?,?,?,
?,?,?,?,
?,?,?,?,

--28
?,'','','',
'',?,?,?,
?,?,?,?,

--31
?,?,?,?,
?,?,?,?,
?,?,?,?,

--34
?,?,?,?,
?,?,?,?,
?,?,?,?,

--37
?,?,?,?,
?,?,?,?,
?,?,?,?,

--40
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?
)


--$rep_insert_user_gmgt

insert into tt_user_gmgt
values (
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?
)

--$rep_insert_password_history
insert into tt_password_history2
values (
?,?,?,?,
?,?,?
)

--$rep_insert_customer_default
insert into tt_customer_default
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?
)


--$rep_insert_account_default
insert into tt_account_default
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?
)

--$rep_insert_account
insert into tt_account
values (
?,?,?,?,
?,?,?,?,
?,?,?,?
)


--$rep_insert_account_group
insert into tt_account_group
values (
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?
)

--$rep_insert_ip_address_version
insert into tt_ip_address_version
values
(
?,?,?,?,
?,?,?,?,
?,?,?,?,
?,?
)

--$rep_insert_user_group_permission
insert into tt_user_group_permission
values
(
?,?,?,?,
?,?,?,?
)

--$rep_insert_user_group_sod_permission
insert into tt_user_group_sod_permission
values
(
?,?,?,?,
?,?,?
)

--$rep_insert_account_group_permission
insert into tt_account_group_permission
values
(
?,?,?,?,
?,?,?
)

--$rep_insert_account_group_group_permission
insert into tt_account_group_group_permission
values
(
?,?,?,?,
?,?,?
)

--$rep_insert_mgt_group_permission
insert into tt_mgt_group_permission
values
(
?,?,?,?,
?,?,?
)


--$rep_insert_market_product_group
insert into tt_market_product_group
values
(
?,?,?,?,
?,?,?,?,
?
)

--$rep_insert_user_product_group
insert into tt_user_product_group
values
(
?,?,?,?,
?,?,?,?
)

--$rep_insert_order_passing
insert into tt_ob_passing
values
(
?,?,?,?,
?,?,?
)

--$rep_insert_order_passing_mb
insert into tt_ob_passing_mb
values
(
?,?,?,?,
?,?,?
)
