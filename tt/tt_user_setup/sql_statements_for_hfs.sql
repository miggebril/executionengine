--$get_mgts_by_user_id_for_hfs

SELECT tt_gmgt.gm_member as [mgt_member],
tt_gmgt.gm_group as [mgt_group],
tt_gmgt.gm_trader as [mgt_trader],
tt_gmgt.gm_gateway_id as [mgt_gateway_id],
tt_mgt.mgt_comp_id
FROM ( tt_gmgt
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader
WHERE tt_user_gmgt.uxg_automatically_login = 1
AND tt_user_gmgt.uxg_available_to_user = 1
AND tt_user_gmgt.uxg_user_id = ?
