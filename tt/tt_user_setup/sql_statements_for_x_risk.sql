
-- used in xr 7.4.0, 7.4.1
--$get_user_and_mgt_by_login
SELECT 
tt_user.user_login, 
tt_user.user_display_name, 
tt_user.user_status,
tt_user_group.ugrp_name, 
tt_gmgt.gm_member as [mgt_member],
tt_gmgt.gm_group as [mgt_group], 
tt_gmgt.gm_trader as [mgt_trader],
tt_gateway.gateway_name
FROM (tt_user_group 
INNER JOIN tt_user 
ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
INNER JOIN ((tt_gateway 
INNER JOIN tt_gmgt 
ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE (((tt_user.user_login)=?));

-- used in xr 7.4.0, 7.4.1
--$get_users_xrisk
SELECT 
tt_user.user_login, 
tt_user.user_display_name,
tt_user.user_status,
tt_user_group.ugrp_name, 
tt_gmgt.gm_member as [mgt_member], 
tt_gmgt.gm_group as [mgt_group], 
tt_gmgt.gm_trader as [mgt_trader], 
tt_gateway.gateway_name
FROM tt_gateway 
INNER JOIN (tt_gmgt 
INNER JOIN ((tt_user_group 
INNER JOIN tt_user 
ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
INNER JOIN tt_user_gmgt 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id;

--$get_user_info_by_login_xrisk_742
SELECT tt_user_group.ugrp_name, 
tt_user.user_display_name, 
tt_user.user_status,
-- obsolete
CBYTE(1) as [user_xrisk_allowed],
tt_user.user_xrisk_sods_allowed,
tt_user.user_xrisk_manual_fills_allowed,
tt_user.user_xrisk_prices_allowed,
tt_user.user_xrisk_instant_messages_allowed
FROM tt_user_group
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id
where tt_user.user_login = ?

--$get_single_user_xrisk_742
SELECT tt_user.user_login,
tt_user.user_display_name,
tt_user.user_status,
tt_user.user_id,
tt_user_group.ugrp_name,
tt_user_gmgt.uxg_gmgt_id as [gm_id],
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader,
tt_mgt.mgt_id,
tt_gmgt_1.gm_gateway_id,
tt_gmgt_1.gm_member,
tt_gmgt_1.gm_group,
tt_gmgt_1.gm_trader
FROM tt_user_group 
INNER JOIN (tt_user 
INNER JOIN (((tt_mgt 
INNER JOIN tt_gmgt ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)) 
INNER JOIN (tt_gmgt AS tt_gmgt_1 
INNER JOIN tt_mgt_gmgt ON tt_gmgt_1.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON (tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id) AND (tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id)) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id
WHERE tt_user_gmgt.uxg_available_to_user =1
AND tt_user.user_login = ?

--$get_users_xrisk_742
SELECT tt_user.user_login, tt_user.user_display_name, tt_user.user_status, tt_user_group.ugrp_name, tt_user.user_id
FROM tt_user_group INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id;

--$get_user_gateway_login_combos_xrisk_742
SELECT tt_user_gmgt.uxg_user_id as [user_id], tt_user_gmgt.uxg_gmgt_id as [mgt_id]
FROM tt_user_gmgt
WHERE tt_user_gmgt.uxg_available_to_user = 1 ORDER BY tt_user_gmgt.uxg_user_id;

--$get_mgts_xrisk_742a
SELECT 
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader, 
tt_gmgt.gm_member, 
tt_gmgt.gm_group, 
tt_gmgt.gm_trader, 
tt_gmgt.gm_gateway_id, 
tt_mgt.mgt_id,
CLNG(0) as gm_id
FROM tt_mgt 
INNER JOIN (tt_mgt_gmgt 
INNER JOIN tt_gmgt 
ON tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt.gm_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id;

--$get_mgts_xrisk_742b
SELECT 
tt_gmgt.gm_id,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
tt_gmgt.gm_gateway_id
FROM tt_gmgt;

--$get_trader_credit_xrisk_742
SELECT 
tt_mgt.mgt_credit, 
tt_mgt.mgt_currency, 
tt_mgt.mgt_allow_trading,
tt_mgt.mgt_ignore_pl, 
tt_mgt.mgt_risk_on, 
tt_mgt.mgt_publish_to_guardian
FROM tt_mgt
WHERE tt_mgt.mgt_id=?;

--$get_product_limits_xrisk_742
SELECT 
tt_product_limit.plim_gateway_id AS [gm_gateway_id],
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
tt_product_limit.plim_allow_trading
FROM tt_product_limit
WHERE tt_product_limit.plim_mgt_id = ? 
and tt_product_limit.plim_for_simulation = 0
