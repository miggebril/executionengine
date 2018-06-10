
--$update_mgt_credit
update tt_mgt set
mgt_last_updated_datetime = ?,
mgt_last_updated_user_id = ?,
mgt_credit = ?
where mgt_member = ?
and mgt_group = ?
and mgt_trader = ?
