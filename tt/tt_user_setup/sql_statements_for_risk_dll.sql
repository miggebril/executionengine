-- used in XT 7.7.4, before there was a hub
--$get_trader_limits

SELECT 
      tt_mgt.mgt_member as [trdr_member],
      tt_mgt.mgt_group as [trdr_group],
      tt_mgt.mgt_trader as [trdr_trader],
      tt_mgt.mgt_credit as [trdr_credit],
      tt_mgt.mgt_currency as [trdr_currency],
      tt_mgt.mgt_allow_trading as [trdr_allow_trading], 
      tt_mgt.mgt_ignore_pl as [trdr_ignore_pl], 
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
      tt_product_limit.plim_allow_trading
FROM 
      tt_user INNER JOIN 
      (((tt_gmgt INNER JOIN tt_mgt ON 
      (tt_gmgt.gm_member = tt_mgt.mgt_member) AND 
      (tt_gmgt.gm_group = tt_mgt.mgt_group) AND 
      (tt_gmgt.gm_trader = tt_mgt.mgt_trader)) LEFT JOIN 
      tt_product_limit ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id) INNER JOIN 
      tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON 
      tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE tt_user.user_login = ?
and tt_product_limit.plim_for_simulation = 0
and tt_mgt.mgt_publish_to_guardian = 1
and tt_mgt.mgt_risk_on = 1  

