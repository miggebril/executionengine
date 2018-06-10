update tt_db_version set dbv_version = 'converting to 7.4.10'
go

drop view tt_view_users_and_their_gateways_and_mgs
go
create view tt_view_users_and_their_gateways_and_mgs as
SELECT DISTINCT 
tt_user.user_id as other_user_id, 
tt_user.user_login as other_user_login, 
tt_user.user_display_name as other_user_display_name,
tt_user.user_fix_adapter_role as other_user_fix_adapter_role,
tt_gmgt.gm_member as other_member, 
tt_gmgt.gm_group as other_group, 
tt_gmgt.gm_gateway_id as other_gateway_id, 
tt_gmgt_1.gm_member as other_exch_member, 
tt_gmgt_1.gm_group as other_exch_group
FROM tt_gmgt AS tt_gmgt_1 INNER JOIN ((tt_user INNER JOIN (tt_gmgt INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) INNER JOIN (tt_mgt INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)) ON tt_gmgt_1.gm_id = tt_mgt_gmgt.mxg_gmgt_id
WHERE tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id
AND (tt_user_gmgt.uxg_available_to_user =1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user=1))
AND tt_user.user_status=1
go

delete from tt_product_limit where plim_product_limit_id in
(
  select plim_product_limit_id
  from
  (
    select plim_mgt_id, plim_gateway_id, plim_product_in_hex, plim_product_type, plim_for_simulation
    from tt_product_limit
    where plim_account_group_id is null or plim_account_group_id = 0
    group by plim_mgt_id, plim_gateway_id, plim_product_in_hex, plim_product_type, plim_for_simulation
    having count(plim_mgt_id) > 1
  ) plim
  INNER JOIN tt_product_limit ON
      plim.plim_mgt_id = tt_product_limit.plim_mgt_id AND
      plim.plim_gateway_id = tt_product_limit.plim_gateway_id AND
      plim.plim_product_in_hex = tt_product_limit.plim_product_in_hex AND
      plim.plim_product_type = tt_product_limit.plim_product_type AND
      plim.plim_for_simulation = tt_product_limit.plim_for_simulation
  WHERE tt_product_limit.plim_account_group_id is null
)
go

update tt_product_limit set plim_account_group_id = 0 where plim_account_group_id is null
go

delete from tt_product_limit where plim_product_limit_id in
(
  select plim_product_limit_id
  from
  (
    select plim_mgt_id, plim_gateway_id, plim_product_in_hex, plim_product_type, plim_for_simulation
    from tt_product_limit
    where plim_account_group_id = -12345678 or plim_account_group_id = 0
    group by plim_mgt_id, plim_gateway_id, plim_product_in_hex, plim_product_type, plim_for_simulation
    having count(plim_mgt_id) > 1
  ) plim
  INNER JOIN tt_product_limit ON
      plim.plim_mgt_id = tt_product_limit.plim_mgt_id AND
      plim.plim_gateway_id = tt_product_limit.plim_gateway_id AND
      plim.plim_product_in_hex = tt_product_limit.plim_product_in_hex AND
      plim.plim_product_type = tt_product_limit.plim_product_type AND
      plim.plim_for_simulation = tt_product_limit.plim_for_simulation
  WHERE tt_product_limit.plim_account_group_id = -12345678
)
go

update tt_product_limit set plim_account_group_id = 0 where plim_account_group_id = -12345678
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.010.000'
go
