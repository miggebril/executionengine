-----------------------------------------------------------------------
-- sql used only by the User Setup Server itself starts here
-----------------------------------------------------------------------

--$private_get_work_item
select * from tt_work_item where wi_id = ?

--$private_update_user_gmgt_for_generated_mgts
update tt_user_gmgt set
uxg_last_updated_datetime = ?,
uxg_last_updated_user_id = ?,
uxg_available_to_user = ?,
uxg_automatically_login = ?
where uxg_user_gmgt_id = ?

--$private_mb_company_requires_exchange_mda_check
SELECT comp_requires_cme_mda, comp_requires_ice_mda, comp_requires_bvmf_mda, comp_requires_sfe_mda FROM tt_company WHERE comp_id = ?

--$private_get_users_and_their_cme_sub_agreement_group_names
SELECT
    tt_user.user_login,
    mkpg.mkpg_product_group
FROM (( tt_user
INNER JOIN tt_user_mpg_sub_agreement [umsa] ON tt_user.user_id = umsa.umsa_user_id )
INNER JOIN tt_market_product_group [mkpg] ON umsa.umsa_market_product_group_id = mkpg.mkpg_market_product_group_id )

--$private_get_generated_user_gmgts
SELECT 
tt_user_gmgt.uxg_user_gmgt_id, 
tt_user_gmgt.uxg_user_id, 
tt_user_gmgt.uxg_gmgt_id, 
tt_user_gmgt.uxg_available_to_user
FROM tt_user 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE tt_user.user_mgt_generation_method in (1,2)

--$private_get_ob_passing_group_count_by_id_and_name
SELECT g1.obpg_id
FROM tt_ob_passing_group g1
INNER JOIN ( SELECT obpg_owning_comp_id FROM tt_ob_passing_group WHERE obpg_id = ? ) g2 ON g1.obpg_owning_comp_id = g2.obpg_owning_comp_id
WHERE g1.obpg_group_name = ?

--$private_get_algo_types_count_by_id_and_name
SELECT g1.al_algo_id
FROM tt_algos g1
INNER JOIN ( SELECT al_comp_id FROM tt_algos WHERE al_algo_id = ? ) g2 ON g1.al_comp_id = g2.al_comp_id
WHERE g1.al_algo_name = ?

--$private_get_ob_passing_group_by_comp_id_and_name
SELECT *
FROM tt_ob_passing_group
WHERE obpg_owning_comp_id = ? AND obpg_group_name = ?

--$private_get_netting_organization_group_count_by_id_and_name
SELECT no1.no_id
FROM tt_netting_organization no1
INNER JOIN ( SELECT no_comp_id FROM tt_netting_organization WHERE no_id = ? ) no2 ON no1.no_comp_id = no2.no_comp_id
WHERE no1.no_name = ?

--$private_get_netting_organization_by_comp_id_and_name
SELECT *
FROM tt_netting_organization
WHERE no_comp_id = ? AND no_name = ?

--$private_get_upg_specifics
SELECT
    tt_user.user_id,
    tt_market.market_name,
    source_company.comp_name AS [source_comp_name],
    target_company.comp_name AS [target_comp_name],
    tt_market_product_group.mkpg_product_group
FROM ((((( tt_user_product_group
INNER JOIN tt_market_product_group ON tt_user_product_group.upg_market_product_group_id = tt_market_product_group.mkpg_market_product_group_id )
INNER JOIN tt_market ON tt_market_product_group.mkpg_market_id = tt_market.market_id )
INNER JOIN tt_user ON tt_user_product_group.upg_user_id = tt_user.user_id )
INNER JOIN tt_company AS [source_company] ON tt_user_product_group.upg_comp_id = source_company.comp_id )
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company AS [target_company] ON tt_user_group.ugrp_comp_id = target_company.comp_id
WHERE upg_user_product_group_id = ?

--$private_get_admin_gmgts
select gm_id, gm_member, gm_group, gm_trader, gm_gateway_id
from tt_gmgt
where gm_trader in ('MGR', 'VIEW')

--$private_get_blob_attributes
select
blb_id,
blb_created_datetime,
blb_created_user_id,
blb_last_updated_datetime,
blb_last_updated_user_id,
blb_key,
blb_description,
blb_group_permission,
blb_nongroup_permission
from tt_blob

--$private_get_blob_attributes_by_key
select
blb_id,
blb_created_datetime,
blb_created_user_id,
blb_last_updated_datetime,
blb_last_updated_user_id,
blb_description,
blb_group_permission,
blb_nongroup_permission
from tt_blob
where blb_key = ?

--$private_get_blob_by_key
select * from tt_blob where blb_key = ?

--$private_does_version_cache_exist
select count(*) as [cnt] from tt_blob where blb_key = 'ProductVersionInfo'

--$private_get_cached_version_string
select blb_data from tt_blob where blb_key = 'ProductVersionInfo' 

--$private_delete_blob_by_key
delete from tt_blob where blb_key = ?

--$private_update_blob_by_key
update tt_blob set
blb_last_updated_datetime = ?,
blb_last_updated_user_id = ?,
blb_description = ?,
blb_group_permission = ?,
blb_nongroup_permission = ?,
blb_data = ?
where blb_key = ?

--$private_update_blob_by_key_clean
update tt_blob set
blb_last_updated_datetime = ?,
blb_last_updated_user_id = ?,
blb_description = ?,
blb_group_permission = ?,
blb_nongroup_permission = ?,
blb_data = ?
where blb_key = ?

--$private_update_blob_attributes_by_key
update tt_blob set
blb_last_updated_datetime = ?,
blb_last_updated_user_id = ?,
blb_description = ?,
blb_group_permission = ?,
blb_nongroup_permission = ?
where blb_key = ?

--$private_delete_old_announce_self_rows
delete from tt_ip_address_version where ipv_last_updated_datetime < DateAdd("m",-18,Now())

--$private_update_txn_billing_flag
update tt_db_version set dbv_txn_billing = ?

--$private_get_tt_apps
select * from tt_tt_app

-- before, if we weren't publishing to guardian, we weren't risk checking

--$private_update_mgt_publish_to_guardian_flag
update tt_mgt set mgt_publish_to_guardian = 1, mgt_risk_on = 0 
where mgt_publish_to_guardian = 0
AND mgt_type <> 2

-- don't publish or turn on risk for admin mgts
--$private_update_mgt_publish_to_guardian_flag2
update tt_mgt set mgt_publish_to_guardian = 0, mgt_risk_on = 0, mgt_allow_trading = 0
where mgt_type = 2

--$private_get_user_product_groups_for_cme_restricted,1
SELECT user_login, user_display_name, user_address, user_city, user_postal_code,
    user_organization, mkpg_product_group, tt_view_user_product_groups_for_cme.ugrp_name, country_code, country_name, state_abbrev, comp_name,
    user_def1, user_def2, user_def3, user_def4, user_def5, user_def6, concurrent_logins,
    user_status, user_netting_cbot, user_netting_cme, user_netting_cme_europe, user_netting_comex, user_netting_nymex, user_netting_dme,
    user_netting_organization, user_created_datetime, user_most_recent_login_datetime,
    user_gf_cbot, user_gf_cme, user_gf_cme_europe, user_gf_comex, user_gf_nymex, user_gf_dme, netting_org_approved
FROM ((tt_view_user_product_groups_for_cme
INNER JOIN tt_user_group_permission ON tt_view_user_product_groups_for_cme.ugrp_group_id = tt_user_group_permission.ugp_group_id)
INNER JOIN tt_user_group ON tt_view_user_product_groups_for_cme.ugrp_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
WHERE tt_user_group_permission.ugp_user_id = ?
GROUP BY user_login, user_display_name, user_address, user_city, user_postal_code,
    user_organization, mkpg_product_group, tt_view_user_product_groups_for_cme.ugrp_name, country_code, country_name, state_abbrev, comp_name,
    tt_user_group.ugrp_name, user_def1, user_def2, user_def3, user_def4, user_def5, user_def6, concurrent_logins,
    user_status, user_netting_cbot, user_netting_cme, user_netting_cme_europe, user_netting_comex, user_netting_nymex, user_netting_dme,
    user_netting_organization, user_created_datetime, user_most_recent_login_datetime,
    user_gf_cbot, user_gf_cme, user_gf_cme_europe, user_gf_comex, user_gf_nymex, user_gf_dme, netting_org_approved
ORDER BY 1, 2

--$private_get_user_product_groups_for_cme_bycompany,1
SELECT user_login, user_display_name, user_address, user_city, user_postal_code,
    user_organization, mkpg_product_group, tt_view_user_product_groups_for_cme.ugrp_name, country_code, country_name, state_abbrev, comp_name,
    user_def1, user_def2, user_def3, user_def4, user_def5, user_def6, concurrent_logins,
    user_status,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cbot ) AS user_netting_cbot,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cme ) AS user_netting_cme,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cme_europe ) AS user_netting_cme_europe,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_comex ) AS user_netting_comex,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_nymex ) AS user_netting_nymex,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_dme ) AS user_netting_dme,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_organization ) AS user_netting_organization,
    IIF( CByte( 1 ) = ucp.ucp_gf_cbot, 'Yes', 'No' ) AS user_gf_cbot,
    IIF( CByte( 1 ) = ucp.ucp_gf_cme, 'Yes', 'No' ) AS user_gf_cme,
    IIF( CByte( 1 ) = ucp.ucp_gf_cme_europe, 'Yes', 'No' ) AS user_gf_cme_europe,
    IIF( CByte( 1 ) = ucp.ucp_gf_comex, 'Yes', 'No' ) AS user_gf_comex,
    IIF( CByte( 1 ) = ucp.ucp_gf_nymex, 'Yes', 'No' ) AS user_gf_nymex,
    IIF( CByte( 1 ) = ucp.ucp_gf_dme, 'Yes', 'No' ) AS user_gf_dme,
    user_created_datetime, user_most_recent_login_datetime, netting_org_approved
FROM ((((((tt_mgt
INNER JOIN tt_gmgt ON (tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader)) 
INNER JOIN tt_user_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id) 
INNER JOIN tt_view_user_product_groups_for_cme ON tt_user_gmgt.uxg_user_id = tt_view_user_product_groups_for_cme.user_id and
    ( ( tt_mgt.mgt_comp_id = tt_view_user_product_groups_for_cme.mgt_comp_id ) OR ( tt_mgt.mgt_comp_id = 0 ) ) )
INNER JOIN tt_user_group ON tt_view_user_product_groups_for_cme.ugrp_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
INNER JOIN tt_user_company_permission [ucp] ON ( tt_view_user_product_groups_for_cme.user_id = ucp.ucp_user_id ) AND ( tt_view_user_product_groups_for_cme.mgt_comp_id = ucp.ucp_comp_id ) )
WHERE tt_view_user_product_groups_for_cme.mgt_comp_id = ?
GROUP BY user_login, user_display_name, user_address, user_city, user_postal_code,
    user_organization, mkpg_product_group, tt_view_user_product_groups_for_cme.ugrp_name, country_code, country_name, state_abbrev, comp_name,
    tt_user_group.ugrp_name, user_def1, user_def2, user_def3, user_def4, user_def5, user_def6, concurrent_logins, user_status,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cbot ), 
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cme ), 
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cme_europe ), 
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_comex ), 
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_nymex ), 
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_dme ), 
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_organization ),
    IIF( CByte( 1 ) = ucp.ucp_gf_cbot, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_cme, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_cme_europe, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_comex, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_nymex, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_dme, 'Yes', 'No' ),
    user_created_datetime, user_most_recent_login_datetime, netting_org_approved
ORDER BY 1, 2

--$private_get_user_product_groups_for_cme_buyside,1
SELECT user_login, user_display_name, user_address, user_city, user_postal_code,
    user_organization, mkpg_product_group, tt_view_user_product_groups_for_cme.ugrp_name, country_code, country_name, state_abbrev,C.comp_name as comp_name,
    user_def1, user_def2, user_def3, user_def4, user_def5, user_def6, concurrent_logins,
    user_status,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cbot ) AS user_netting_cbot,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cme ) AS user_netting_cme,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cme_europe ) AS user_netting_cme_europe,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_comex ) AS user_netting_comex,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_nymex ) AS user_netting_nymex,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_dme ) AS user_netting_dme,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_organization ) AS user_netting_organization,
    IIF( CByte( 1 ) = ucp.ucp_gf_cbot, 'Yes', 'No' ) AS user_gf_cbot,
    IIF( CByte( 1 ) = ucp.ucp_gf_cme, 'Yes', 'No' ) AS user_gf_cme,
    IIF( CByte( 1 ) = ucp.ucp_gf_cme_europe, 'Yes', 'No' ) AS user_gf_cme_europe,
    IIF( CByte( 1 ) = ucp.ucp_gf_comex, 'Yes', 'No' ) AS user_gf_comex,
    IIF( CByte( 1 ) = ucp.ucp_gf_nymex, 'Yes', 'No' ) AS user_gf_nymex,
    IIF( CByte( 1 ) = ucp.ucp_gf_dme, 'Yes', 'No' ) AS user_gf_dme,
    user_created_datetime, user_most_recent_login_datetime, netting_org_approved
FROM ((((((tt_mgt
INNER JOIN tt_gmgt ON (tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader))
INNER JOIN tt_user_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id)
INNER JOIN tt_view_user_product_groups_for_cme ON tt_user_gmgt.uxg_user_id = tt_view_user_product_groups_for_cme.user_id and
    ( ( tt_mgt.mgt_comp_id = tt_view_user_product_groups_for_cme.mgt_comp_id ) OR ( tt_mgt.mgt_comp_id = 0 ) ) )
INNER JOIN tt_user_group ON tt_view_user_product_groups_for_cme.ugrp_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
INNER JOIN tt_user_company_permission [ucp] ON ( tt_view_user_product_groups_for_cme.user_id = ucp.ucp_user_id ) AND ( tt_view_user_product_groups_for_cme.mgt_comp_id = ucp.ucp_comp_id ) )
INNER JOIN tt_company [C] ON C.comp_id =  tt_view_user_product_groups_for_cme.mgt_comp_id
WHERE tt_company.comp_id = ?
GROUP BY user_login, user_display_name, user_address, user_city, user_postal_code,
    user_organization, mkpg_product_group, tt_view_user_product_groups_for_cme.ugrp_name, country_code, country_name, state_abbrev, C.comp_name,
    tt_user_group.ugrp_name, user_def1, user_def2, user_def3, user_def4, user_def5, user_def6, concurrent_logins, user_status,
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cbot ),
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cme ),
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_cme_europe ),
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_comex ),
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_nymex ),
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_dme ),
    IIF( tt_view_user_product_groups_for_cme.mgt_comp_id <> tt_company.comp_id, '', tt_view_user_product_groups_for_cme.user_netting_organization ),
    IIF( CByte( 1 ) = ucp.ucp_gf_cbot, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_cme, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_cme_europe, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_comex, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_nymex, 'Yes', 'No' ),
    IIF( CByte( 1 ) = ucp.ucp_gf_dme, 'Yes', 'No' ),
    user_created_datetime, user_most_recent_login_datetime, netting_org_approved
ORDER BY 1, 2

--$private_get_user_product_groups_for_cme_unrestricted
SELECT user_login, user_display_name, user_address, user_city, user_postal_code,
    user_organization, mkpg_product_group, tt_view_user_product_groups_for_cme.ugrp_name, country_code, country_name, state_abbrev, comp_name,
    user_def1, user_def2, user_def3, user_def4, user_def5, user_def6, concurrent_logins,
    user_status, user_netting_cbot, user_netting_cme, user_netting_cme_europe, user_netting_comex, user_netting_nymex, user_netting_dme,
    user_netting_organization, user_created_datetime, user_most_recent_login_datetime,
    user_gf_cbot, user_gf_cme, user_gf_cme_europe, user_gf_comex, user_gf_nymex, user_gf_dme, netting_org_approved
FROM ( tt_view_user_product_groups_for_cme
INNER JOIN tt_user_group ON tt_view_user_product_groups_for_cme.ugrp_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
GROUP BY user_login, user_display_name, user_address, user_city, user_postal_code,
    user_organization, mkpg_product_group, tt_view_user_product_groups_for_cme.ugrp_name, country_code, country_name, state_abbrev, comp_name,
    tt_user_group.ugrp_name, user_def1, user_def2, user_def3, user_def4, user_def5, user_def6, concurrent_logins,
    user_status, user_netting_cbot, user_netting_cme, user_netting_cme_europe, user_netting_comex, user_netting_nymex, user_netting_dme,
    user_netting_organization, user_created_datetime, user_most_recent_login_datetime,
    user_gf_cbot, user_gf_cme, user_gf_cme_europe, user_gf_comex, user_gf_nymex, user_gf_dme, netting_org_approved
ORDER BY 1, 2

--$private_get_directly_related_account_groups_by_account_id
SELECT ag_id
FROM tt_account_group
WHERE ag_is_auto_assigned = 1 AND ag_id IN ( SELECT acct_account_group_id FROM tt_account WHERE acct_id = ? )

--$private_get_directly_related_account_by_account_group_id
SELECT acct_id
FROM tt_account
INNER JOIN tt_account_group ON tt_account.acct_account_group_id = tt_account_group.ag_id
WHERE tt_account_group.ag_id = ? and tt_account_group.ag_is_auto_assigned = 1

--$private_get_users_and_their_gateways_and_mgs_for_product_groups_restricted,1
SELECT DISTINCT v.user_id, v.gm_member, v.gm_group, v.gm_gateway_id, v.exch_member, v.exch_group, v.gateway_market_id, u1.user_display_name, v.mgt_comp_id
FROM ( tt_view_users_and_their_gateways_and_mgs_for_product_groups v
INNER JOIN tt_user as u1 on v.user_id = u1.user_id )
INNER JOIN tt_user_group_permission ON u1.user_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?

--$private_get_users_and_their_gateways_and_mgs_for_product_groups_bycompany,1
select v.user_id, v.gm_member, v.gm_group, v.gm_gateway_id, v.exch_member, v.exch_group, v.gateway_market_id, u1.user_display_name, v.mgt_comp_id
from tt_view_users_and_their_gateways_and_mgs_for_product_groups v
inner join tt_user as u1 on v.user_id = u1.user_id
where v.mgt_comp_id = ?

--$private_get_users_and_their_gateways_and_mgs_for_product_groups_unrestricted
select v.user_id, v.gm_member, v.gm_group, v.gm_gateway_id, v.exch_member, v.exch_group, v.gateway_market_id, u1.user_display_name, v.mgt_comp_id
from tt_view_users_and_their_gateways_and_mgs_for_product_groups v
inner join tt_user as u1 on v.user_id = u1.user_id

--$private_get_all_product_group_restrictions_bycompany,1
select upg_user_id, upg_comp_id, upg_market_product_group_id, mkpg_product_group, mkpg_market_id
    from tt_user_product_group
    inner join tt_market_product_group on tt_user_product_group.upg_market_product_group_id = tt_market_product_group.mkpg_market_product_group_id
    where tt_user_product_group.upg_comp_id = ?

--$private_get_all_product_group_restrictions_unrestricted
select upg_user_id, upg_comp_id, upg_market_product_group_id, mkpg_product_group, mkpg_market_id
    from tt_user_product_group
    inner join tt_market_product_group on tt_user_product_group.upg_market_product_group_id = tt_market_product_group.mkpg_market_product_group_id

--$private_get_cme_product_groups
SELECT 
tt_market_product_group.mkpg_product_group_id,
tt_market_product_group.mkpg_product_group
FROM tt_market_product_group
where tt_market_product_group.mkpg_market_id = 7
order by tt_market_product_group.mkpg_product_group

--$private_get_hkex_product_groups
SELECT
tt_market_product_group.mkpg_product_group_id,
tt_market_product_group.mkpg_product_group
FROM tt_market_product_group
where tt_market_product_group.mkpg_market_id = 97
order by tt_market_product_group.mkpg_product_group

--$private_get_sgx_product_groups
SELECT
tt_market_product_group.mkpg_product_group_id,
tt_market_product_group.mkpg_product_group
FROM tt_market_product_group
where tt_market_product_group.mkpg_market_id = 64
order by tt_market_product_group.mkpg_product_group

--$private_get_nyse_liffe_product_groups
SELECT
tt_market_product_group.mkpg_product_group_id,
tt_market_product_group.mkpg_product_group
FROM tt_market_product_group
where tt_market_product_group.mkpg_market_id = 3
order by tt_market_product_group.mkpg_product_group

--$private_get_most_recent_user_ip_address_combos
select ipv_user_login, ipv_ip_address, max(ipv_last_updated_datetime) as most_recent_date
from tt_ip_address_version
where ipv_user_login <> '' and ipv_last_updated_datetime > DateAdd("d",-15,Now())
group by ipv_user_login, ipv_ip_address

--$private_get_used_currencies
select user_currency from tt_user
union
select mgt_currency from tt_mgt

--$private_get_report_users_and_their_mgts1_restricted,1
select user_login, mgt_member, mgt_group, mgt_trader, gateway_name, user_display_name,
[status], ugrp_name, mgt_description, mgt_risk_on, mgt_allow_trading, mgt_credit,
market_name, uxg_automatically_login, uxg_available_to_user, uxg_available_to_fix_adapter_user,
fa_role, mgt_id, gm_gateway_id, comp_id, comp_name, user_def1, user_def2, user_def3, user_def4,
user_def5, user_def6, country_name, user_address, user_city, state_long_name, user_postal_code,
user_email, user_id, uxg_exchange_data1, uxg_exchange_data2, uxg_exchange_data3, uxg_exchange_data4,
uxg_exchange_data5, uxg_exchange_data6, uxg_operator_id, uxg_max_orders_per_second_on,
uxg_max_orders_per_second, uxg_market_orders
from (tt_view_users_and_their_mgts1 inner join tt_user_group_permission 
on tt_view_users_and_their_mgts1.ugrp_group_id = tt_user_group_permission.ugp_group_id)
where tt_user_group_permission.ugp_user_id = ? order by 1,2,3,4,5

--$private_get_report_users_and_their_mgts1_bycompany,1
select user_login, mgt_member, mgt_group, mgt_trader, gateway_name, user_display_name,
[status], ugrp_name, mgt_description, mgt_risk_on, mgt_allow_trading, mgt_credit,
market_name, uxg_automatically_login, uxg_available_to_user, uxg_available_to_fix_adapter_user,
fa_role, mgt_id, gm_gateway_id, comp_id, comp_name, user_def1, user_def2, user_def3, user_def4,
user_def5, user_def6, country_name, user_address, user_city, state_long_name, user_postal_code,
user_email, user_id, uxg_exchange_data1, uxg_exchange_data2, uxg_exchange_data3, uxg_exchange_data4,
uxg_exchange_data5, uxg_exchange_data6, uxg_operator_id, tt_user_company_permission.ucp_billing1,
tt_user_company_permission.ucp_billing2, tt_user_company_permission.ucp_billing3, uxg_max_orders_per_second_on,
uxg_max_orders_per_second, uxg_market_orders
from tt_view_users_and_their_mgts1 
inner join tt_user_company_permission ON tt_view_users_and_their_mgts1.mgt_comp_id = tt_user_company_permission.ucp_comp_id
    and tt_view_users_and_their_mgts1.user_id = tt_user_company_permission.ucp_user_id
where mgt_comp_id = ? order by 1,2,3,4,5

--$private_get_report_users_and_their_mgts1_buyside,1
select user_login, mgt_member, mgt_group, mgt_trader, gateway_name, user_display_name,
[status], ugrp_name, mgt_description, mgt_risk_on, mgt_allow_trading, mgt_credit,
market_name, uxg_automatically_login, uxg_available_to_user, uxg_available_to_fix_adapter_user,
fa_role, mgt_id, gm_gateway_id, view_users.comp_id, C.comp_name, user_def1, user_def2, user_def3, user_def4,
user_def5, user_def6, country_name, user_address, user_city, state_long_name, user_postal_code,
user_email, user_id, uxg_exchange_data1, uxg_exchange_data2, uxg_exchange_data3, uxg_exchange_data4,
uxg_exchange_data5, uxg_exchange_data6, uxg_operator_id, tt_user_company_permission.ucp_billing1,
tt_user_company_permission.ucp_billing2, tt_user_company_permission.ucp_billing3, uxg_max_orders_per_second_on,
uxg_max_orders_per_second, uxg_market_orders
from (tt_view_users_and_their_mgts1 [view_users]
inner join tt_user_company_permission ON view_users.mgt_comp_id = tt_user_company_permission.ucp_comp_id
    and view_users.user_id = tt_user_company_permission.ucp_user_id)
inner join tt_company [C] ON C.comp_id = view_users.mgt_comp_id
where view_users.comp_id = ? order by 1,2,3,4,5

--$private_get_report_users_and_their_mgts1_unrestricted
select user_login, mgt_member, mgt_group, mgt_trader, gateway_name, user_display_name,
[status], ugrp_name, mgt_description, mgt_risk_on, mgt_allow_trading, mgt_credit,
market_name, uxg_automatically_login, uxg_available_to_user, uxg_available_to_fix_adapter_user,
fa_role, mgt_id, gm_gateway_id, comp_id, comp_name, user_def1, user_def2, user_def3, user_def4,
user_def5, user_def6, country_name, user_address, user_city, state_long_name, user_postal_code,
user_email, user_id, uxg_exchange_data1, uxg_exchange_data2, uxg_exchange_data3, uxg_exchange_data4,
uxg_exchange_data5, uxg_exchange_data6, uxg_operator_id, uxg_max_orders_per_second_on,
uxg_max_orders_per_second, uxg_market_orders
from tt_view_users_and_their_mgts1 order by 1,2,3,4,5

--$private_get_report_users_and_their_mgts2_restricted,1
select gm_member, gm_group, gm_trader, mgt_id, gm_gateway_id 
from (tt_view_users_and_their_mgts2 
inner join tt_view_mgt_group_permission_all on tt_view_users_and_their_mgts2.mgt_id = tt_view_mgt_group_permission_all.mgp_mgt_id) 
inner join tt_user_group_permission on tt_view_mgt_group_permission_all.mgp_group_id = tt_user_group_permission.ugp_group_id
where tt_user_group_permission.ugp_user_id = ?

--$private_get_report_users_and_their_mgts2_bycompany,1
select gm_member, gm_group, gm_trader, mgt_id, gm_gateway_id from tt_view_users_and_their_mgts2 where mgt_comp_id = ? 

--$private_get_report_users_and_their_mgts2_unrestricted
select gm_member, gm_group, gm_trader, mgt_id, gm_gateway_id from tt_view_users_and_their_mgts2


--$private_get_previously_heartbeating_gateways
select * from tt_previously_heartbeating_gateways

--$private_delete_previously_heartbeating_gateways
delete from tt_previously_heartbeating_gateways

--$insert_previously_heartbeating_gateways
insert into tt_previously_heartbeating_gateways  values(?,?,?,?)

--$private_update_db_version

update tt_db_version set
dbv_last_updated_datetime = now,
dbv_last_updated_ttus_server_version = ?,
dbv_last_notification_sequence_number = ?

--$private_delete_uxg_when_switching_to_generated
delete from tt_user_gmgt where uxg_user_id = ?

--$private_get_currencies
select crn_currency_id, crn_abbrev from tt_currency

--$private_get_currency_exchange_rates
SELECT 
tt_currency.crn_abbrev as [from_currency], 
tt_currency_1.crn_abbrev as [to_currency], 
tt_currency_exchange_rate.cex_rate_times_10000, 
tt_currency_exchange_rate.cex_exchange_rate_id
FROM (tt_currency_exchange_rate 
INNER JOIN tt_currency ON tt_currency_exchange_rate.cex_from_currency_id = tt_currency.crn_currency_id) 
INNER JOIN tt_currency AS tt_currency_1 ON tt_currency_exchange_rate.cex_to_currency_id = tt_currency_1.crn_currency_id;

--$private_get_routing_keys
SELECT pak
FROM
(
	SELECT 
		'' as acct_name_in_hex,
		str( gm_gateway_id ) + ' ' +
		tt_mgt.mgt_member + ' ' +
		tt_mgt.mgt_group + ' ' +
		tt_mgt.mgt_trader + ' ' +
		tt_gmgt.gm_member + ' ' +
		tt_gmgt.gm_group + ' ' +
		tt_gmgt.gm_trader + ' ' +
		str(tt_mgt.mgt_id) + ',' as pak
	FROM tt_mgt INNER JOIN (tt_gmgt INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
	WHERE mgt_type = 1
	UNION
	SELECT  
		tt_account.acct_name_in_hex,
		str( gm_gateway_id ) + ' ' +
		tt_mgt.mgt_member + ' ' +
		tt_mgt.mgt_group + ' ' +
		tt_mgt.mgt_trader + ' ' +
		tt_gmgt.gm_member + ' ' +
		tt_gmgt.gm_group + ' ' +
		tt_gmgt.gm_trader + ' ' +
		tt_account.acct_name as pak
	FROM tt_gmgt 
	INNER JOIN ((tt_mgt 
	INNER JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id) 
	INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id
	WHERE mgt_type = 1
)

--$private_get_recent_ice_related_versions
SELECT 
tt_ip_address_version.ipv_tt_product_name,
tt_ip_address_version.ipv_tt_product_id,
tt_ip_address_version.ipv_version,
tt_ip_address_version.ipv_lang_id,
tt_gateway.gateway_name,
Max(tt_ip_address_version.ipv_last_updated_datetime) as [last_seen_datetime]
FROM tt_ip_address_version 
LEFT JOIN tt_gateway ON tt_ip_address_version.ipv_gateway_id = tt_gateway.gateway_id
WHERE ipv_last_updated_datetime > DateAdd("d",-60,Now())
AND (tt_gateway.gateway_id is null or tt_gateway.gateway_market_id = 32)
GROUP BY 
tt_ip_address_version.ipv_tt_product_name, 
tt_ip_address_version.ipv_tt_product_id,
tt_ip_address_version.ipv_version, 
tt_ip_address_version.ipv_lang_id,
tt_gateway.gateway_name
ORDER BY 1, 2, 3, 4, 5

--$private_get_recent_ice_related_versions_filtered_by_broker_id
SELECT 
    tt_ip_address_version.ipv_tt_product_name,
    tt_ip_address_version.ipv_tt_product_id,
    tt_ip_address_version.ipv_version,
    tt_ip_address_version.ipv_lang_id,
    tt_gateway.gateway_name,
    Max( tt_ip_address_version.ipv_last_updated_datetime ) as [last_seen_datetime]
FROM ((( tt_ip_address_version 
    LEFT JOIN tt_gateway ON tt_ip_address_version.ipv_gateway_id = tt_gateway.gateway_id )
    LEFT JOIN tt_user ON tt_ip_address_version.ipv_user_login = tt_user.user_login )
    LEFT JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
    LEFT JOIN tt_view_companies_with_ice_gw_assignments vi ON tt_user_group.ugrp_comp_id = vi.assigned_comp_id
WHERE
    ipv_last_updated_datetime > DateAdd("d",-60,Now())
    AND ( tt_gateway.gateway_id is null or tt_gateway.gateway_market_id = 32 )
    AND ( tt_gateway.gateway_id is not null OR vi.broker_comp_id = 2 )
GROUP BY 
    tt_ip_address_version.ipv_tt_product_name, 
    tt_ip_address_version.ipv_tt_product_id,
    tt_ip_address_version.ipv_version, 
    tt_ip_address_version.ipv_lang_id,
    tt_gateway.gateway_name
ORDER BY 1, 2, 3, 4, 5

--$private_get_ice_users_and_their_mgts
SELECT 
    tt_user.user_id,
    tt_user.user_login,
    iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( tt_company.comp_id <> 0, tt_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ) as [customer],
    IIF( tt_mgt.mgt_type = 2 or tt_gmgt_1.gm_trader = 'Record>', 'No Trader ID (View Only)', tt_gmgt_1.gm_trader ) as [exch_trader], 
    tt_user.user_most_recent_login_datetime, 
    tt_user.user_fix_adapter_role, 
    tt_user.user_last_updated_datetime, 
    MAX(tt_user_gmgt.uxg_last_updated_datetime) as [uxg_last_updated_datetime],
    tt_view_user_blacklist_counts.cnt as [blacklist_count],
    CByte(0) as [auto_gen],
    broker_company.comp_id as [broker_comp_id],
    broker_company.comp_name as [broker]
FROM ((tt_company
    INNER JOIN tt_user_group ON tt_company.comp_id = tt_user_group.ugrp_comp_id)
    INNER JOIN ((tt_view_user_blacklist_counts
    RIGHT JOIN tt_user ON tt_view_user_blacklist_counts.upg_user_id = tt_user.user_id)
    INNER JOIN ((tt_company AS broker_company
    INNER JOIN ((tt_mgt_gmgt
    INNER JOIN ((tt_gmgt
    INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member))
    INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id) ON (tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) AND (tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt_1.gm_id))
    LEFT JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id) ON broker_company.comp_id = tt_mgt.mgt_comp_id)
    INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id)
    LEFT JOIN tt_user_company_permission AS ucp ON tt_user.user_id = ucp.ucp_user_id
WHERE
    tt_gateway.gateway_market_id = 32
    AND tt_user.user_mgt_generation_method = 0
    AND tt_user.user_status = 1
    AND ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) ) 
    AND ( 0 <> tt_mgt.mgt_comp_id OR 0 = ( select lss_multibroker_mode from tt_login_server_settings ) )
    AND ( ucp.ucp_comp_id is null or ucp.ucp_comp_id = broker_company.comp_id )
GROUP BY
    tt_user.user_id,
    tt_user.user_login, 
    iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( tt_company.comp_id <> 0, tt_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ),
    IIF( tt_mgt.mgt_type = 2 or tt_gmgt_1.gm_trader = 'Record>', 'No Trader ID (View Only)', tt_gmgt_1.gm_trader ),
    tt_user.user_most_recent_login_datetime, 
    tt_user.user_fix_adapter_role, 
    tt_user.user_last_updated_datetime, 
    tt_view_user_blacklist_counts.cnt,
    broker_company.comp_id,
    broker_company.comp_name

UNION

SELECT
    tt_user.user_id,
    tt_user.user_login,
    iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( assigned_company.comp_id <> 0, assigned_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ) as [customer],
    'No Trader ID (View Only)' as [exch_trader], 
    tt_user.user_most_recent_login_datetime, 
    tt_user.user_fix_adapter_role, 
    tt_user.user_last_updated_datetime, 
    tt_user.user_last_updated_datetime as [uxg_last_updated_datetime], 
    tt_view_user_blacklist_counts.cnt as [blacklist_count],
    CByte(1) as [auto_gen],
    vi.broker_comp_id,
    broker_company.comp_name as [broker]
FROM (((((((( tt_user
    INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
    INNER JOIN tt_view_companies_with_ice_gw_assignments vi ON tt_user_group.ugrp_comp_id = vi.assigned_comp_id )
    INNER JOIN tt_company as assigned_company ON tt_user_group.ugrp_comp_id = assigned_company.comp_id )
    INNER JOIN tt_company as broker_company ON vi.broker_comp_id = broker_company.comp_id )
    INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
    INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
    INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
    LEFT JOIN tt_view_user_blacklist_counts ON tt_view_user_blacklist_counts.upg_user_id = tt_user.user_id )
    LEFT JOIN tt_user_company_permission AS ucp ON tt_user.user_id = ucp.ucp_user_id
WHERE
    tt_user.user_status = 1
    AND tt_user.user_mgt_generation_method <> 0
    AND gateway_market_id = 32
    AND ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
    AND ( ucp.ucp_comp_id is null or ucp.ucp_comp_id = broker_company.comp_id )
GROUP BY
    tt_user.user_login, 
    tt_user.user_id,
    iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( assigned_company.comp_id <> 0, assigned_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ),
    tt_user.user_most_recent_login_datetime, 
    tt_user.user_fix_adapter_role, 
    tt_user.user_last_updated_datetime, 
    'No Trader ID (View Only)', 
    tt_view_user_blacklist_counts.cnt,
    vi.broker_comp_id,
    broker_company.comp_name
ORDER BY 1, 2


--$private_get_ice_users_and_their_mgts_filtered_by_broker_id
SELECT *
FROM
(
SELECT 
    tt_user.user_id,
    tt_user.user_login,
    iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( tt_company.comp_id <> 0, tt_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ) as [customer],
    IIF( tt_mgt.mgt_type = 2 or tt_gmgt_1.gm_trader = 'Record>', 'No Trader ID (View Only)', tt_gmgt_1.gm_trader ) as [exch_trader], 
    tt_user.user_most_recent_login_datetime, 
    tt_user.user_fix_adapter_role, 
    tt_user.user_last_updated_datetime, 
    MAX(tt_user_gmgt.uxg_last_updated_datetime) as [uxg_last_updated_datetime],
    tt_view_user_blacklist_counts.cnt as [blacklist_count],
    CByte(0) as [auto_gen],
    broker_company.comp_id as [broker_comp_id],
    broker_company.comp_name as [broker]
FROM ((tt_company
    INNER JOIN tt_user_group ON tt_company.comp_id = tt_user_group.ugrp_comp_id)
    INNER JOIN ((tt_view_user_blacklist_counts
    RIGHT JOIN tt_user ON tt_view_user_blacklist_counts.upg_user_id = tt_user.user_id)
    INNER JOIN ((tt_company AS broker_company
    INNER JOIN ((tt_mgt_gmgt
    INNER JOIN ((tt_gmgt
    INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member))
    INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id) ON (tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) AND (tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt_1.gm_id))
    LEFT JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id) ON broker_company.comp_id = tt_mgt.mgt_comp_id)
    INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id)
    LEFT JOIN tt_user_company_permission AS ucp ON tt_user.user_id = ucp.ucp_user_id
WHERE
    tt_gateway.gateway_market_id = 32
    AND tt_user.user_mgt_generation_method = 0
    AND tt_user.user_status = 1
    AND ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) ) 
    AND ( 0 <> tt_mgt.mgt_comp_id OR 0 = ( select lss_multibroker_mode from tt_login_server_settings ) )
    AND ( ucp.ucp_comp_id is null or ucp.ucp_comp_id = broker_company.comp_id )
GROUP BY
    tt_user.user_id,
    tt_user.user_login, 
    iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( tt_company.comp_id <> 0, tt_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ),
    IIF( tt_mgt.mgt_type = 2 or tt_gmgt_1.gm_trader = 'Record>', 'No Trader ID (View Only)', tt_gmgt_1.gm_trader ),
    tt_user.user_most_recent_login_datetime, 
    tt_user.user_fix_adapter_role, 
    tt_user.user_last_updated_datetime, 
    tt_view_user_blacklist_counts.cnt,
    broker_company.comp_id,
    broker_company.comp_name

UNION

SELECT
    tt_user.user_id,
    tt_user.user_login,
    iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( assigned_company.comp_id <> 0, assigned_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ) as [customer],
    'No Trader ID (View Only)' as [exch_trader], 
    tt_user.user_most_recent_login_datetime, 
    tt_user.user_fix_adapter_role, 
    tt_user.user_last_updated_datetime, 
    tt_user.user_last_updated_datetime as [uxg_last_updated_datetime], 
    tt_view_user_blacklist_counts.cnt as [blacklist_count],
    CByte(1) as [auto_gen],
    vi.broker_comp_id,
    broker_company.comp_name as [broker]
FROM (((((((( tt_user
    INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
    INNER JOIN tt_view_companies_with_ice_gw_assignments vi ON tt_user_group.ugrp_comp_id = vi.assigned_comp_id )
    INNER JOIN tt_company as assigned_company ON tt_user_group.ugrp_comp_id = assigned_company.comp_id )
    INNER JOIN tt_company as broker_company ON vi.broker_comp_id = broker_company.comp_id )
    INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
    INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
    INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
    LEFT JOIN tt_view_user_blacklist_counts ON tt_view_user_blacklist_counts.upg_user_id = tt_user.user_id )
    LEFT JOIN tt_user_company_permission AS ucp ON tt_user.user_id = ucp.ucp_user_id
WHERE
    tt_user.user_status = 1
    AND tt_user.user_mgt_generation_method <> 0
    AND gateway_market_id = 32
    AND ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
    AND ( ucp.ucp_comp_id is null or ucp.ucp_comp_id = broker_company.comp_id )
GROUP BY
    tt_user.user_login, 
    tt_user.user_id,
    iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( assigned_company.comp_id <> 0, assigned_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ),
    tt_user.user_most_recent_login_datetime, 
    tt_user.user_fix_adapter_role, 
    tt_user.user_last_updated_datetime, 
    'No Trader ID (View Only)', 
    tt_view_user_blacklist_counts.cnt,
    vi.broker_comp_id,
    broker_company.comp_name
)
WHERE
  broker_comp_id = ?
ORDER BY 1, 2

--$private_get_ice_blacklist
SELECT 
    tt_user.user_login,
    tt_market_product_group.mkpg_product_group, 
    tt_user_product_group.upg_comp_id,
    tt_user_product_group.upg_created_datetime 
FROM ( tt_market_product_group 
    INNER JOIN tt_user_product_group ON tt_market_product_group.mkpg_market_product_group_id = tt_user_product_group.upg_market_product_group_id )
    INNER JOIN tt_user ON tt_user_product_group.upg_user_id = tt_user.user_id
WHERE
    mkpg_market_id = 32
ORDER BY
    tt_user.user_login,
    tt_market_product_group.mkpg_product_group

--$private_get_ice_product_groups
SELECT
    mkpg_product_group 
FROM tt_market_product_group
WHERE
    mkpg_market_id = 32
ORDER BY
    mkpg_product_group

--$private_get_user_company_by_user_and_company
select ucp_id from tt_user_company_permission
where ucp_user_id = ? and ucp_comp_id = ?


-- used when we tie an exchange trader to a ttord, to make sure there's not an orderbook sharing problem
--$private_get_exch_traders_mgs_for_ttord_mgs
SELECT DISTINCT 
tt_gmgt.gm_member AS exch_member, tt_gmgt.gm_group AS exch_group,
tt_gmgt_1.gm_member AS new_exch_member, tt_gmgt_1.gm_group as new_exch_group, tt_gmgt_1.gm_trader as new_exch_trader, tt_gmgt_1.gm_gateway_id
FROM tt_gmgt AS tt_gmgt_1 
INNER JOIN (tt_gmgt INNER JOIN (tt_mgt 
INNER JOIN (tt_mgt AS tt_mgt_1 
INNER JOIN tt_mgt_gmgt ON tt_mgt_1.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
ON (tt_mgt.mgt_member = tt_mgt_1.mgt_member) AND (tt_mgt.mgt_group = tt_mgt_1.mgt_group)) 
ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_gmgt_1.gm_gateway_id = tt_gmgt.gm_gateway_id
WHERE tt_mgt.mgt_id = ?
AND  tt_gmgt_1.gm_id = ? 
AND (tt_gmgt.gm_member <> tt_gmgt_1.gm_member or  tt_gmgt.gm_group <> tt_gmgt_1.gm_group)


---------------------------------------------------------
-- The following used when we delete a company permission  
---------------------------------------------------------

--$private_delete_customer_defaults_by_user_company
delete from tt_customer_default where cusd_user_id = ? and cusd_comp_id = ?

--$private_delete_account_defaults_by_user_company
delete from tt_account_default where acctd_user_id = ? and acctd_comp_id = ?

--$private_delete_user_product_groups_by_user_company
delete from tt_user_product_group where upg_user_id = ? and upg_comp_id = ?

--$private_delete_user_gmgts_by_user_company
delete from tt_user_gmgt where uxg_user_gmgt_id in (
SELECT tt_user_gmgt.uxg_user_gmgt_id
FROM (tt_gmgt INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)
where tt_user_gmgt.uxg_user_id = ? and  tt_mgt.mgt_comp_id = ?
)

--$private_delete_user_accounts_by_user_company
delete from tt_user_account where uxa_user_account_id in
(
  select tt_user_account.uxa_user_account_id
  from tt_user_account
  inner join tt_account on tt_user_account.uxa_account_id = tt_account.acct_id
  where tt_user_account.uxa_user_id = ? and tt_account.acct_comp_id = ?
)

--$private_get_users_marked_for_deletion
select user_id from tt_user 
where user_marked_for_deletion_datetime > #1970-01-02 00:00:00# 
and user_marked_for_deletion_datetime < DateAdd("d",-35,Now)

--$private_get_app_version_rules
SELECT 
    tt_app_version_rule.*, 
    tt_tt_app.*, 
    tt_user.user_login,
    tt_user_group.ugrp_name as [user_group],
    tt_user_last_updated.user_login AS last_updated_user_login 
FROM ((( tt_tt_app 
INNER JOIN tt_app_version_rule ON tt_tt_app.ttapp_app_id = tt_app_version_rule.avr_tt_app_id )
LEFT JOIN tt_user ON tt_app_version_rule.avr_user_id = tt_user.user_id ) 
LEFT JOIN tt_user AS tt_user_last_updated ON tt_app_version_rule.avr_last_updated_user_id = tt_user_last_updated.user_id )
LEFT JOIN tt_user_group ON tt_app_version_rule.avr_user_group_id = tt_user_group.ugrp_group_id

--$private_delete_orphan_user_specific_app_version_rules
DELETE FROM tt_app_version_rule WHERE avr_id IN
(
    SELECT avr_id
    FROM (( tt_tt_app
    INNER JOIN tt_app_version_rule ON tt_tt_app.ttapp_app_id = tt_app_version_rule.avr_tt_app_id ) 
    LEFT JOIN tt_user ON tt_app_version_rule.avr_user_id = tt_user.user_id )
    LEFT JOIN tt_user_group ON tt_app_version_rule.avr_user_group_id = tt_user_group.ugrp_group_id
    WHERE ( tt_app_version_rule.avr_user_id <> 0 OR tt_app_version_rule.avr_user_group_id <> 0 )
        AND ( tt_user.user_login IS null AND tt_user_group.ugrp_name IS NULL )
)

--$private_convert_gmgt_gateway_id
update tt_gmgt set 
gm_gateway_id = ?,
gm_gateway_mgt_key = CStr(?) + ';' + gm_member + gm_group + gm_trader
where gm_gateway_id = ?

--$private_convert_product_limit_gateway_id
update tt_product_limit set plim_gateway_id = ? where plim_gateway_id = ?

--$private_convert_customer_default_gateway_id
update tt_customer_default set cusd_gateway_id = ? where cusd_gateway_id = ?
        
--$private_delete_gateway
delete from tt_gateway where gateway_id = ?


--$private_get_fa_server_mgts_for_validation
SELECT 
tt_gmgt.gm_gateway_id, 
tt_gmgt.gm_member,
tt_gmgt.gm_group 
FROM tt_gmgt 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
WHERE uxg_available_to_user = 1
and uxg_user_id = ?
            
--$private_check_if_fa_server_is_badly_configured
select count(1) 
from tt_view_users_with_multiple_available_to_user_gateways
where [Username] = ?

--$private_get_fix_adapter_rules_broken_by_gmgt_deletion
SELECT * from tt_view_fix_client_server_mgt_dependencies
where server_mgt_id = ?
and server_gm_id = ?

--$private_get_fix_adapter_rules_broken_by_mgt_deletion
SELECT * from tt_view_fix_client_server_mgt_dependencies
where server_mgt_id = ?

--$private_get_fix_adapter_rules_broken_by_exchange_trader_mgt_deletion
SELECT distinct 
tt_user_1.user_login as [client_user_login], 
tt_user.user_login as [server_user_login],
tt_gmgt.gm_gateway_id as [server_gm_gateway_id],
tt_gmgt_1.gm_member as [server_gm_member],
tt_gmgt_1.gm_group as [server_gm_group],
tt_gmgt_1.gm_trader as [server_gm_trader]
FROM tt_mgt_gmgt AS tt_mgt_gmgt_1 
INNER JOIN (((tt_user 
INNER JOIN ((tt_mgt 
INNER JOIN tt_gmgt ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)) 
INNER JOIN (tt_user_gmgt 
INNER JOIN ((tt_mgt_gmgt 
INNER JOIN tt_mgt AS tt_mgt_1 ON tt_mgt_gmgt.mxg_mgt_id = tt_mgt_1.mgt_id) 
INNER JOIN tt_gmgt AS tt_gmgt_1 ON (tt_mgt_1.mgt_member = tt_gmgt_1.gm_member) AND (tt_mgt_1.mgt_group = tt_gmgt_1.gm_group) AND (tt_mgt_1.mgt_trader = tt_gmgt_1.gm_trader)) ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt_1.gm_id) ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
INNER JOIN ((tt_user_gmgt AS tt_user_gmgt_1 
INNER JOIN (tt_user AS tt_user_1 
INNER JOIN tt_user_user_relationship ON tt_user_1.user_id = tt_user_user_relationship.uur_user_id1) ON tt_user_gmgt_1.uxg_user_id = tt_user_1.user_id) 
INNER JOIN tt_gmgt AS tt_gmgt_2 ON tt_user_gmgt_1.uxg_gmgt_id = tt_gmgt_2.gm_id) ON tt_user.user_id = tt_user_user_relationship.uur_user_id2) 
INNER JOIN tt_mgt AS tt_mgt_2 ON (tt_gmgt_2.gm_trader = tt_mgt_2.mgt_trader) AND (tt_gmgt_2.gm_group = tt_mgt_2.mgt_group) AND (tt_gmgt_2.gm_member = tt_mgt_2.mgt_member)) ON (tt_mgt_gmgt_1.mxg_id = tt_mgt_2.mgt_id) AND (tt_mgt_gmgt_1.mxg_id = tt_mgt_2.mgt_id)
WHERE tt_mgt.mgt_id = ?
And left(tt_mgt_1.mgt_member,5)  = 'TTORD'
And tt_user_gmgt.uxg_available_to_user = 1
And tt_user.user_status = 1
And tt_user_1.user_status = 1
And tt_user_gmgt_1.uxg_available_to_fix_adapter_user  = 1
And tt_gmgt_1.gm_gateway_id = tt_gmgt_2.gm_gateway_id
And tt_gmgt.gm_id <> tt_mgt_gmgt_1.mxg_gmgt_id

--$private_get_fix_adapter_rules_broken_by_exchange_trader_gmgt_deletion
SELECT distinct 
tt_user_1.user_login as [client_user_login], 
tt_user.user_login as [server_user_login],
tt_gmgt.gm_gateway_id as [server_gm_gateway_id],
tt_gmgt_1.gm_member as [server_gm_member],
tt_gmgt_1.gm_group as [server_gm_group],
tt_gmgt_1.gm_trader as [server_gm_trader]
FROM tt_mgt_gmgt AS tt_mgt_gmgt_1 
INNER JOIN (((tt_user 
INNER JOIN ((tt_mgt 
INNER JOIN tt_gmgt ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)) 
INNER JOIN (tt_user_gmgt 
INNER JOIN ((tt_mgt_gmgt 
INNER JOIN tt_mgt AS tt_mgt_1 ON tt_mgt_gmgt.mxg_mgt_id = tt_mgt_1.mgt_id) 
INNER JOIN tt_gmgt AS tt_gmgt_1 ON (tt_mgt_1.mgt_member = tt_gmgt_1.gm_member) AND (tt_mgt_1.mgt_group = tt_gmgt_1.gm_group) AND (tt_mgt_1.mgt_trader = tt_gmgt_1.gm_trader)) ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt_1.gm_id) ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
INNER JOIN ((tt_user_gmgt AS tt_user_gmgt_1 
INNER JOIN (tt_user AS tt_user_1 
INNER JOIN tt_user_user_relationship ON tt_user_1.user_id = tt_user_user_relationship.uur_user_id1) ON tt_user_gmgt_1.uxg_user_id = tt_user_1.user_id) 
INNER JOIN tt_gmgt AS tt_gmgt_2 ON tt_user_gmgt_1.uxg_gmgt_id = tt_gmgt_2.gm_id) ON tt_user.user_id = tt_user_user_relationship.uur_user_id2) 
INNER JOIN tt_mgt AS tt_mgt_2 ON (tt_gmgt_2.gm_trader = tt_mgt_2.mgt_trader) AND (tt_gmgt_2.gm_group = tt_mgt_2.mgt_group) AND (tt_gmgt_2.gm_member = tt_mgt_2.mgt_member)) ON (tt_mgt_gmgt_1.mxg_id = tt_mgt_2.mgt_id) AND (tt_mgt_gmgt_1.mxg_id = tt_mgt_2.mgt_id)
WHERE tt_mgt.mgt_id = ?
And tt_mgt_gmgt.mxg_gmgt_id = ?
And left(tt_mgt_1.mgt_member,5)  = 'TTORD'
And tt_user_gmgt.uxg_available_to_user = 1
And tt_user.user_status = 1
And tt_user_1.user_status = 1
And tt_user_gmgt_1.uxg_available_to_fix_adapter_user  = 1
And tt_gmgt_1.gm_gateway_id = tt_gmgt_2.gm_gateway_id
And tt_gmgt.gm_id <> tt_mgt_gmgt_1.mxg_gmgt_id

--$private_get_company_market_products_for_cache
select cmkp_comp_market_product_id,
cmkp_comp_id,
cmkp_market_id,
cmkp_product_type,
cmkp_product,
cmkp_margin_times_100,
cmkp_last_updated_datetime
from tt_company_market_product

--$private_get_product_limits_for_cache
select 
plim_product_limit_id,
plim_gateway_id,
plim_product_type,
plim_product,
plim_mgt_id,
plim_account_group_id,
plim_for_simulation
from tt_product_limit

--$private_get_users_for_cache
select
user_id,
user_login,
user_display_name,
user_status,
user_user_setup_user_type,
user_password,
user_on_behalf_of_allowed,
user_cross_orders_allowed,
user_enforce_ip_login_limit,
user_fmds_allowed,
user_force_logoff_switch,
user_must_change_password_next_login,
user_password_never_expires,
user_quoting_allowed,
user_ttapi_allowed,
user_wholesale_trades_allowed,
user_wholesale_orders_with_undefined_accounts_allowed,
user_xrisk_instant_messages_allowed,
user_xrisk_manual_fills_allowed,
user_xrisk_prices_allowed,
user_xrisk_sods_allowed,
user_failed_login_attempts_count,
user_fix_adapter_role,
user_group_id,
user_ip_login_limit,
user_login_attempt_key,
user_created_datetime,
user_most_recent_login_datetime,
user_most_recent_login_datetime_for_inactivity,
user_most_recent_password_change_datetime,
ugrp_comp_id,
user_mgt_generation_method,
user_mgt_generation_method_member,
user_mgt_generation_method_group,
user_staged_order_creation_allowed,
user_staged_order_claiming_allowed,
user_dma_order_creation_allowed,
user_fix_staged_order_creation_allowed,
user_fix_dma_order_creation_allowed,
user_use_pl_risk_algo,
user_xrisk_update_trading_allowed_allowed,
user_ttapi_admin_edition_allowed,
user_allow_trading,
user_non_simulation_allowed,
user_simulation_allowed,
user_machine_gun_orders_allowed,
user_algo_deployment_allowed,
user_algo_sharing_allowed,
user_persist_orders_on_eurex,
user_liquidate_exceeding_position_limits_allowed,
user_never_locked_by_inactivity,
user_country_id,
user_postal_code,
user_prevent_orders_based_on_price_ticks,
int_user_prevent_orders_price_ticks,
user_enforce_price_limit_on_buysell_only,
user_prevent_orders_based_on_rate,
int_user_prevent_orders_rate,
user_gtc_orders_allowed,
user_individually_select_admin_logins,
user_undefined_accounts_allowed,
user_account_changes_allowed,
user_no_sod_user_group_restrictions,
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
user_x_trader_mode,
user_2fa_required,
user_email,
user_xtapi_allowed,
user_autotrader_allowed,
user_autospreader_allowed,
user_sms_number,
user_2fa_required_mode,
user_mgt_auto_login,
user_aggregator_allowed,
user_sniper_orders_allowed,
user_eu_config_1_allowed,
user_eu_config_1,
user_eu_config_2_allowed,
user_eu_config_2
FROM tt_user 
INNER JOIN tt_user_group on tt_user_group.ugrp_group_id = tt_user.user_group_id

--$private_does_mb_user_require_2fa
SELECT MAX( ucp_2fa_required_mode ) AS [2fa_required]
FROM tt_user_company_permission
WHERE ucp_user_id = ?
GROUP BY ucp_user_id

--$private_mb_get_company_password_rules_override
SELECT comp_password_rules_override_on,
comp_2fa_trust_days,
comp_enforce_password_expiration,
comp_expiration_period_days
FROM tt_company
WHERE comp_id = ?

--$private_get_company_by_user
SELECT tt_user_group.ugrp_comp_id
FROM tt_user_group 
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id
WHERE tt_user.user_id = ?

--$private_get_gmgt_member_group_by_id
SELECT 
tt_gmgt.gm_member, 
tt_gmgt.gm_group, 
tt_gmgt.gm_gateway_id, 
tt_gmgt_1.gm_member as [exch_member], 
tt_gmgt_1.gm_group as [exch_group]
FROM ((tt_gmgt INNER JOIN tt_mgt 
ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)) 
INNER JOIN tt_mgt_gmgt 
ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
INNER JOIN tt_gmgt AS tt_gmgt_1 
ON (tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id) AND (tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt_1.gm_id)
WHERE tt_gmgt.gm_id = ?

--$private_update_product_limit_for_import
update tt_product_limit set
plim_last_updated_datetime = ?,
plim_last_updated_user_id = ?,
plim_gateway_id = ?,
plim_product = ?,
plim_product_type = ?,
plim_additional_margin_pct = ?,
plim_max_order_qty = ?,
plim_max_position = ?,
plim_allow_tradeout = ?,
plim_max_long_short = ?,
plim_product_in_hex = ?,
plim_allow_trading = ?
where plim_product_limit_id = ?

--$private_get_user_setup_user_type
select user_user_setup_user_type 
from tt_user
where user_id = ?

--$private_is_account_referenced

SELECT tt_account.acct_name
FROM tt_account INNER JOIN tt_customer_default ON tt_account.acct_id = tt_customer_default.cusd_account_id
where tt_account.acct_id = ?
union
SELECT tt_account.acct_name
FROM tt_account INNER JOIN tt_customer_default ON tt_account.acct_id = tt_customer_default.cusd_on_behalf_of_account_id
where tt_account.acct_id = ?
union
select tt_account.acct_name
from tt_account where acct_mgt_id <> 0
and tt_account.acct_id = ?
union
SELECT tt_account.acct_name
FROM tt_account INNER JOIN tt_user_account ON tt_account.acct_id = tt_user_account.uxa_account_id
where tt_account.acct_id = ?

--$private_is_account_group_referenced
SELECT
    tt_account_group.ag_name,
    count(*) as acct_count
FROM tt_account_group
INNER JOIN tt_account ON tt_account_group.ag_id = tt_account.acct_account_group_id
WHERE tt_account_group.ag_id = ?
GROUP BY tt_account_group.ag_name

--$private_is_user_referenced

SELECT tt_user.user_login
FROM tt_user INNER JOIN tt_customer_default ON tt_user.user_id = tt_customer_default.cusd_on_behalf_of_user_id
where tt_user.user_id = ?

--$private_is_mgt_referenced_by_cusd
SELECT cusd_user_id
FROM tt_customer_default
where cusd_default_gmgt_id in
  ( select tt_gmgt.gm_id
    from tt_mgt
    inner join tt_gmgt on tt_mgt.mgt_member = tt_gmgt.gm_member and tt_mgt.mgt_group = tt_gmgt.gm_group and tt_mgt.mgt_trader = tt_gmgt.gm_trader
    where tt_mgt.mgt_id = ?
  )
or cusd_on_behalf_of_mgt_id = ?


--$private_get_gmgt_mapped_to_unseen_users
SELECT COUNT(tt_user.user_login) as mapped_to_unseen_users
FROM ((tt_user_gmgt INNER JOIN tt_user
ON tt_user_gmgt.uxg_user_id = tt_user.user_id)
INNER JOIN tt_view_user_group_cartesian_join AS cartesian
ON tt_user.user_group_id = cartesian.ugrp_group_id)
LEFT JOIN tt_user_group_permission
ON cartesian.user_id = tt_user_group_permission.ugp_user_id
AND cartesian.ugrp_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_gmgt.uxg_gmgt_id = ? 
AND cartesian.user_id = ?
AND tt_user_group_permission.ugp_group_id IS NULL

--$private_get_mgt_mapped_to_unseen_users
SELECT count(tt_user.user_login) AS mapped_to_unseen_users
FROM ((((tt_mgt INNER JOIN tt_gmgt 
         ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader
	    )INNER JOIN tt_user_gmgt 
	    ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id)
INNER JOIN tt_user 
ON tt_user_gmgt.uxg_user_id = tt_user.user_id)
INNER JOIN tt_view_user_group_cartesian_join AS cartesian
ON tt_user.user_group_id = cartesian.ugrp_group_id)
LEFT JOIN tt_user_group_permission
ON cartesian.user_id = tt_user_group_permission.ugp_user_id
AND cartesian.ugrp_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_mgt.mgt_id = ?
AND cartesian.user_id = ?
AND tt_user_group_permission.ugp_group_id IS NULL

--$private_update_lss_initial_guardian_import_done
update tt_login_server_settings set lss_initial_guardian_import_done = 1;

--$private_get_user_group_permissions_by_user_id

SELECT tt_user_group_permission.ugp_automatically_add
FROM tt_user 
INNER JOIN tt_user_group_permission ON tt_user.user_id = tt_user_group_permission.ugp_user_id
WHERE ugp_user_id = ?;

--$private_update_user_group_permissions_by_user_id

UPDATE tt_user_group_permission
SET ugp_automatically_add = 1
WHERE ugp_user_id = ?;

--$private_get_same_ttord_m_but_different_broker
select count(1) as [cnt]
from tt_mgt
where tt_mgt.mgt_member = ? 
and tt_mgt.mgt_comp_id <> ?

--$private_get_users_count_by_group

SELECT count(*) as user_count
FROM tt_user
WHERE user_group_id = ?;

--$private_update_mgt

update tt_mgt set
mgt_last_updated_datetime = ?,
mgt_last_updated_user_id = ?,
mgt_description = ?,
mgt_credit = ?,
mgt_currency = ?,
mgt_allow_trading = ?,
mgt_ignore_pl = ?,
mgt_risk_on = ?,
mgt_publish_to_guardian = ?
where mgt_id = ?

--$private_get_user_by_login_restricted,1

SELECT DISTINCT tt_user.user_id
FROM tt_user
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?
and tt_user.user_login = ?

--$private_get_user_by_login_bycompany,1

SELECT DISTINCT tt_view_user_company_relationships.user_id
FROM tt_view_user_company_relationships 
INNER JOIN tt_user ON tt_view_user_company_relationships.user_id = tt_user.user_id
where tt_view_user_company_relationships.ugrp_comp_id = ?
and tt_user.user_login = ?

--$private_get_user_logins_restricted,1

SELECT tt_user.user_login
FROM tt_user
INNER JOIN tt_user_group_permission 
ON tt_user.user_group_id = tt_user_group_permission.ugp_group_id
WHERE tt_user_group_permission.ugp_user_id = ?

--$private_get_user_by_login

SELECT tt_user.*,ugrp_comp_id
FROM tt_user 
INNER JOIN tt_user_group on tt_user_group.ugrp_group_id = tt_user.user_group_id
WHERE user_login = ?

--$private_get_gmgts_by_gateway_id_and_mgt

SELECT *
FROM tt_gmgt
WHERE tt_gmgt.gm_gateway_id=? AND tt_gmgt.gm_member=? AND tt_gmgt.gm_group=? AND tt_gmgt.gm_trader=?;


--$private_get_users_by_gateway_mgt
SELECT distinct tt_user_gmgt.uxg_user_id
FROM tt_gmgt INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id
WHERE tt_gmgt.gm_member = ?
  AND tt_gmgt.gm_group = ? 
  AND tt_gmgt.gm_trader = ? 
  AND tt_gmgt.gm_gateway_id <> ?;


--$private_update_account_blank_mgt_id_by_mgt_id
update tt_account set
acct_last_updated_datetime = ?,
acct_last_updated_user_id = ?,
acct_mgt_id = 0
where acct_mgt_id = ?

--$private_update_account_mgt_id_by_acct_id
update tt_account set
acct_last_updated_datetime = ?,
acct_last_updated_user_id = ?,
acct_mgt_id = ?
where acct_id = ?


--$private_get_user
select user_login, user_display_name from tt_user where user_id = ?

--$private_insert_market

insert into tt_market
(market_id, market_name)
values (?,?)

--$private_update_market

update tt_market
set market_name = ?
where market_id = ?


--$insert_market_product_group
insert into tt_market_product_group 
(mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group,mkpg_requires_subscription_agreement)
values(?,?,?,?,?,?,?,?)

--$private_delete_market_product_group
delete from tt_market_product_group where mkpg_market_product_group_id = ?

--$private_update_market_product_group
update tt_market_product_group
set mkpg_product_group = ?
where mkpg_market_product_group_id = ?


--$private_insert_user_product_group
insert into tt_user_product_group
(
upg_created_datetime,
upg_created_user_id,
upg_last_updated_datetime,
upg_last_updated_user_id,
upg_user_id,
upg_comp_id,
upg_market_product_group_id
) 
values
(
now,0,now,
0,?,?,?
)


  
  
--$private_insert_gateway

insert into tt_gateway
(gateway_id, gateway_name, gateway_market_id)
values (?,?,?)

--$private_get_used_gateways

select gm_gateway_id as [gateway_id] from tt_gmgt
union
select plim_gateway_id from tt_product_limit
union
select cusd_gateway_id from tt_customer_default 
union
select gateway_id from tt_gateway where gateway_id < 1 

--$private_get_unused_markets
select tt_market.market_id, tt_market.market_name 
from tt_market 
left join tt_view_used_markets on tt_market.market_id = tt_view_used_markets.gateway_market_id 
where tt_view_used_markets.gateway_market_id is null
and tt_market.market_id > 0

--$private_update_market

update tt_market
set market_name = ?
where market_id = ?

--$private_update_gateway

update tt_gateway set 
gateway_name = ?,
gateway_market_id = ?
where gateway_id = ?

--$private_update_cusd_market

update tt_customer_default set 
cusd_market_id = ?
where cusd_gateway_id = ?

--$private_get_password_history

select password_history_id, password_history_password
from tt_password_history2
where password_history_user_id = ?
order by password_history_created_datetime desc

--$private_insert_blob

insert into tt_blob
(
blb_created_datetime,
blb_created_user_id,
blb_last_updated_datetime,
blb_last_updated_user_id,

blb_key,
blb_description,
blb_group_permission,
blb_nongroup_permission,
blb_data 
)
values
(
?,?,?,?,
?,?,?,?,
?
)

--$private_insert_password_history

insert into tt_password_history2
(
password_history_created_datetime,
password_history_created_user_id,
password_history_last_updated_datetime,
password_history_last_updated_user_id,
password_history_user_id,
password_history_password
)
values
(
?,?,?,?,
?,?
)

--$private_delete_password_history

delete from tt_password_history2 where password_history_id = ?

--$private_get_tt_gmgt_gateway_id_by_mgt
select gm_gateway_id from tt_gmgt 
where gm_member = ?
  and gm_group = ?
  and gm_trader = ?

--$private_delete_tt_gmgt_by_mgt

delete from tt_gmgt 
where gm_member = ?
  and gm_group = ?
  and gm_trader = ?
  
--$private_delete_tt_gmgt_by_mgt_id

delete from tt_gmgt 
where gm_id = ?

--$private_delete_tt_gmgt_by_mgt_gateway
delete from tt_gmgt 
where gm_member = ?
  and gm_group = ?
  and gm_trader = ?
  and gm_gateway_id = ?
  

-------------------------------------------------------
-- This sql is called as a result of us deleting a non
-- ttord gateway login ( M G T and gateway)
-- This sql will delete all TTORD synthesize records
-- that are mapped to this gateway login.
-------------------------------------------------------

--$private_delete_synthesized_gmgts_by_exchange_gmgt
DELETE FROM tt_gmgt 
WHERE gm_gateway_mgt_key IN (-9999)

--$private_get_synthesized_gmgts_by_exchange_gmgt
SELECT CStr(?) + ';' + tt_mgt.mgt_member + tt_mgt.mgt_group + tt_mgt.mgt_trader AS sKey,
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader
FROM (tt_mgt INNER JOIN tt_mgt_gmgt 
	  ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
	 )INNER JOIN tt_gmgt
	 ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id
WHERE tt_mgt.mgt_type = 1
AND tt_gmgt.gm_id = ?

--$private_delete_synthesized_gmgts_by_exchange_mgt
DELETE FROM tt_gmgt
WHERE gm_gateway_mgt_key IN (-9999)

--$private_get_synthesized_gmgts_by_exchange_mgt
SELECT CStr(tt_gmgt.gm_gateway_id) + ';' + tt_mgt.mgt_member + tt_mgt.mgt_group + tt_mgt.mgt_trader AS sKey,
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader
FROM (tt_mgt INNER JOIN tt_mgt_gmgt
	  ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
	 )INNER JOIN tt_gmgt
	 ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id
WHERE tt_mgt.mgt_type = 1
AND tt_gmgt.gm_member = ?
AND tt_gmgt.gm_group = ?
AND tt_gmgt.gm_trader = ?


--$private_get_logins_by_userid

SELECT 
tt_gmgt.gm_gateway_id, 
tt_gmgt.gm_member, 
tt_gmgt.gm_group, 
tt_gmgt.gm_trader, 
tt_mgt.mgt_password,
tt_user_gmgt.uxg_automatically_login, 
tt_user_gmgt.uxg_preferred_ip, 
tt_user_gmgt.uxg_default_account, 
tt_user_gmgt.uxg_clearing_member
FROM (tt_user 
INNER JOIN (tt_gmgt 
INNER JOIN tt_user_gmgt 
ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
INNER JOIN tt_mgt 
ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)
WHERE tt_user.user_id =? 
AND tt_user_gmgt.uxg_available_to_user = 1

--$private_get_logins_by_userid_sim
-- special handling of TTORDs and ASE/SSE/AlgoSE
SELECT 
tt_gmgt.gm_gateway_id, 
iif(tt_mgt.mgt_type = 1,'SIMRD' + mid(tt_gmgt.gm_member,6), tt_gmgt.gm_member) as [gm_member],	  
tt_gmgt.gm_group, 
tt_gmgt.gm_trader, 
tt_mgt.mgt_password,
tt_user_gmgt.uxg_automatically_login, 
tt_user_gmgt.uxg_preferred_ip, 
tt_user_gmgt.uxg_default_account, 
tt_user_gmgt.uxg_clearing_member
FROM tt_gateway 
INNER JOIN (tt_user 
INNER JOIN ((tt_gmgt 
INNER JOIN tt_mgt 
ON (tt_gmgt.gm_member = tt_mgt.mgt_member) 
AND (tt_gmgt.gm_group = tt_mgt.mgt_group) 
AND (tt_gmgt.gm_trader = tt_mgt.mgt_trader)) 
INNER JOIN tt_user_gmgt 
ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id
WHERE tt_user.user_id =? 
AND tt_user_gmgt.uxg_available_to_user = 1
AND tt_gateway.gateway_market_id not in (84, 85, 88)
UNION
SELECT 834,"ASE","SIM","GEN","",CBYTE(1),"","","" from tt_db_version
UNION
SELECT 861,"SSE","SIM","GEN","",CBYTE(1),"","","" from tt_db_version
UNION
SELECT 1029,"ALGOSE","SIM","GEN","",CBYTE(1),"","","" from tt_db_version



--$private_get_version_by_ip_product_gateway_for_servers
select ipv_version,
ipv_lang_id
from tt_ip_address_version
where ipv_ip_address = ?
and ipv_tt_product_id = ?
and ipv_gateway_id = ?
order by ipv_last_updated_datetime desc
-- get the freshest one

-- for view connected clients
--$private_get_version_by_ip_user_product_for_clients
select ipv_version,
ipv_lang_id
from tt_ip_address_version
where ipv_ip_address = ?
and ipv_user_login = ?
and ipv_tt_product_id = ?
and ipv_gateway_id = 0
order by ipv_last_updated_datetime desc
-- get the freshest one

-- check for dupe key
--$private_get_ip_address_version
select * from tt_ip_address_version
where ipv_ip_address = ?
and ipv_version = ?
and ipv_tt_product_id = ?
and ipv_user_login = ?
and ipv_exe_path = ?
and ipv_gateway_id = ?

--$private_update_ip_address_version
update tt_ip_address_version set 
ipv_last_updated_datetime = ?,
ipv_last_updated_user_id = ?,
ipv_lang_id = ?,
ipv_tt_product_name = ?,
ipv_update_count = ipv_update_count + 1
where ipv_id = ?

--$private_get_mgts

select
mgt_id,
mgt_last_updated_datetime,
mgt_last_updated_user_id,
mgt_member,
mgt_group,
mgt_trader,
mgt_description,
mgt_credit,
mgt_currency,
mgt_allow_trading,
mgt_ignore_pl,
mgt_risk_on,
mgt_publish_to_guardian
from tt_mgt
where mgt_id <> 0

--$private_get_mgts2

select
mgt_id,
mgt_last_updated_datetime,
mgt_last_updated_user_id,
mgt_member,
mgt_group,
mgt_trader,
mgt_description,
mgt_credit,
mgt_currency,
mgt_allow_trading,
mgt_ignore_pl,
mgt_risk_on,
mgt_publish_to_guardian
from tt_mgt
where mgt_id <> 0
and mgt_type = 1

--$private_get_mxgs

SELECT mgt_id, 
gm_gateway_id,
gm_member,
gm_group,
gm_trader
FROM tt_mgt
INNER JOIN (tt_mgt_gmgt 
INNER JOIN tt_gmgt
ON tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt.gm_id) 
ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
WHERE mgt_id <> 0

--$private_get_mxgs2

SELECT mgt_id, 
gm_gateway_id,
gm_member,
gm_group,
gm_trader
FROM tt_mgt
INNER JOIN (tt_mgt_gmgt 
INNER JOIN tt_gmgt
ON tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt.gm_id) 
ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
WHERE mgt_id <> 0
and mgt_type = 1

--$private_get_mgts_accounts_for_guardian_diff

select acct_mgt_id, acct_name 
from tt_account
where acct_mgt_id <> 0

--$private_get_mgts_accounts_for_guardian_diff2

select acct_mgt_id, acct_name 
from tt_account
inner join tt_mgt on tt_account.acct_mgt_id = tt_mgt.mgt_id
where acct_mgt_id <> 0
and mgt_type = 1

--$private_get_mgts_product_limits_for_guardian_diff

SELECT 
tt_product_limit.plim_mgt_id, 
tt_product_limit.plim_product_limit_id, 
tt_product_limit.plim_gateway_id, 
tt_product_limit.plim_product, 
tt_product_limit.plim_product_type, 
tt_product_limit.plim_additional_margin_pct, 
tt_product_limit.plim_max_order_qty, 
tt_product_limit.plim_max_position, 
tt_product_limit.plim_allow_tradeout,
tt_product_limit.plim_allow_trading
FROM tt_product_limit 
where plim_for_simulation = 0
order by 1,2,3,4;


--for import
--$private_get_accounts_and_their_mgts

SELECT 
tt_account.acct_id, 
tt_account.acct_name, 
tt_account.acct_mgt_id, 
tt_account.acct_account_group_id,
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader
FROM tt_mgt 
RIGHT JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id

--$private_get_accounts_and_their_mgts2

SELECT 
tt_account.acct_id, 
tt_account.acct_name, 
tt_account.acct_mgt_id, 
tt_account.acct_account_group_id,
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader
FROM tt_mgt 
RIGHT JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id
WHERE mgt_type = 1

--for import
--$private_get_gmgts
SELECT gm_id, 
gm_gateway_id,
gm_member,
gm_group,
gm_trader
FROM tt_gmgt

--$private_delete_mxg
delete from tt_mgt_gmgt where mxg_id = ?;

--$private_get_direct_gmgt_id_from_synthesized_gmgt_id
SELECT tt_view_ttords_and_their_gateways.gm_id 
FROM tt_gmgt INNER JOIN tt_view_ttords_and_their_gateways 
ON tt_gmgt.gm_member = tt_view_ttords_and_their_gateways.mgt_member
AND tt_gmgt.gm_group = tt_view_ttords_and_their_gateways.mgt_group 
AND tt_gmgt.gm_trader = tt_view_ttords_and_their_gateways.mgt_trader 
AND tt_gmgt.gm_gateway_id = tt_view_ttords_and_their_gateways.gm_gateway_id
WHERE tt_gmgt.gm_id = ?;

--$private_delete_mxg_by_gmgt_id_and_mgt_id
delete from tt_mgt_gmgt 
where mxg_gmgt_id = ?
  and mxg_mgt_id = ?;


--$private_get_mgt_by_mgt_and_gateway
SELECT tt_gmgt.gm_member, tt_gmgt.gm_group, tt_gmgt.gm_trader
FROM tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN tt_mgt_gmgt 
ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) 
ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
where tt_mgt.mgt_member = ?
and tt_mgt.mgt_group = ?
and tt_mgt.mgt_trader = ?
and tt_gmgt.gm_gateway_id = ?

--$private_get_gmgt_count_by_mgt
SELECT count(*) as num_of_records
FROM tt_gmgt
WHERE gm_member = ?
  AND gm_group = ?
  AND gm_trader = ?


-- string to int, int to string caches
  
--$private_cache_get_user_user_relationship_ids_and_names
SELECT uur_id, tt_user_1.user_login + "," +  tt_user.user_login + ", " +  tt_user_user_relationship.uur_relationship_type as name
FROM (tt_user_user_relationship 
INNER JOIN tt_user AS tt_user_1 ON tt_user_user_relationship.uur_user_id1 = tt_user_1.user_id) 
INNER JOIN tt_user ON tt_user_user_relationship.uur_user_id2 = tt_user.user_id;

--$private_cache_get_app_version_rule_ids_and_names
SELECT 
tt_app_version_rule.avr_id,
tt_tt_app.ttapp_app_name_on_wire + ' ' + 
tt_app_version_rule.avr_comparison_operator + ' ' +
tt_app_version_rule.avr_version as name
FROM tt_tt_app 
INNER JOIN tt_app_version_rule 
ON tt_tt_app.ttapp_app_id = tt_app_version_rule.avr_tt_app_id;
  
--$private_cache_get_user_ids_and_logins
select user_id, user_login from tt_user

--$private_cache_get_mgt_ids_and_mgts
select mgt_id, mgt_member + ' ' + mgt_group + ' ' + mgt_trader as name from tt_mgt

--$private_cache_get_gm_ids_and_names
select gm_id, gm_member + ' ' + gm_group + ' ' + gm_trader as name from tt_gmgt

--$private_cache_get_uxg_ids_and_names
SELECT uxg_user_gmgt_id, tt_user.user_login 
+ ' ' +  tt_gmgt.gm_member 
+ ' ' +  tt_gmgt.gm_group
+ ' ' +  tt_gmgt.gm_trader
+ ' ' +  tt_gateway.gateway_name as name
FROM ((( tt_user
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )

--$private_cache_get_acct_ids_and_names
select acct_id, acct_name from tt_account

--$private_cache_get_acct_group_ids_and_names
select ag_id, ag_name from tt_account_group

--$private_cache_get_acct_ids_and_names_multibroker
select acct_id, acct_name + ";" + comp_name from tt_account
inner join tt_company on tt_account.acct_comp_id = tt_company.comp_id

--$private_cache_get_acct_group_ids_and_names_multibroker
select ag_id, ag_name + ";" + comp_name from tt_account_group
inner join tt_company on tt_account_group.ag_comp_id = tt_company.comp_id

--$private_cache_get_user_group_ids_and_names
select ugrp_group_id, ugrp_name from tt_user_group

--$private_cache_get_company_ids_and_names
select comp_id, comp_name from tt_company

--$private_cache_get_company_ids_and_abbreviations
select comp_id, comp_abbrev from tt_company

--$private_cache_get_company_ids_and_isbrokers
select comp_id, comp_is_broker from tt_company

--$private_cache_get_company_ids_and_isbrokers_by_user
SELECT DISTINCT * FROM
(
SELECT
    tt_company.comp_id,
    tt_company.comp_is_broker
FROM ( tt_company
INNER JOIN tt_user_group ON tt_company.comp_id = tt_user_group.ugrp_comp_id )
INNER JOIN tt_user ON tt_user_group.ugrp_group_id = tt_user.user_group_id
WHERE tt_user.user_login = ? and tt_user.user_user_setup_user_type <> 1 and tt_company.comp_is_broker = 1
 
UNION
 
SELECT
    tt_company.comp_id,
    tt_company.comp_is_broker
FROM tt_user, tt_company
WHERE tt_user.user_login = ? AND tt_user.user_user_setup_user_type = 1
 
UNION
 
SELECT
    broker_company.comp_id,
    broker_company.comp_is_broker
FROM (((( tt_user as [buyside_user]
INNER JOIN tt_user_group ON buyside_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company as [buyside_company] ON tt_user_group.ugrp_comp_id = buyside_company.comp_id )
INNER JOIN tt_company_company_permission [ccp] ON buyside_company.comp_id = ccp.ccp_buyside_comp_id )
INNER JOIN tt_company as [broker_company] ON ccp.ccp_broker_comp_id = broker_company.comp_id )
WHERE buyside_user.user_login = ? and buyside_user.user_mgt_generation_method <> 0
 
UNION
 
SELECT
    broker_company.comp_id,
    broker_company.comp_is_broker
FROM (((( tt_user as [buyside_user]
INNER JOIN tt_user_group ON buyside_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company as [buyside_company] ON tt_user_group.ugrp_comp_id = buyside_company.comp_id )
INNER JOIN tt_user_company_permission as [ucp] ON buyside_user.user_id = ucp.ucp_user_id )
INNER JOIN tt_company as [broker_company] ON ucp.ucp_comp_id = broker_company.comp_id )
WHERE buyside_user.user_login = ? and buyside_user.user_mgt_generation_method = 0 and buyside_company.comp_is_broker = 0
)

--$private_cache_get_gateway_ids_and_names
select gateway_id, gateway_name from tt_gateway

--$private_cache_get_market_ids_and_names
select market_id, market_name from tt_market

--$private_cache_get_product_type_ids_and_names
select product_id, product_description from tt_product_type

--$private_cache_get_acctd_id_to_user_id_mappings
select acctd_id, acctd_user_id from tt_account_default

--$private_cache_get_uxg_id_to_user_id_mappings
select uxg_user_gmgt_id, uxg_user_id from tt_user_gmgt

--$private_cache_get_cusd_id_to_user_id_mappings
select cusd_id, cusd_user_id from tt_customer_default

--$private_cache_get_group_id_to_comp_id_mappings
select ugrp_group_id, ugrp_comp_id from tt_user_group

--$private_cache_get_mgt_id_to_comp_id_mappings
select mgt_id, mgt_comp_id from tt_mgt

--$private_cache_get_market_product_group_ids_and_names
SELECT tt_market_product_group.mkpg_market_product_group_id, tt_market.market_name + ' ' + tt_market_product_group.mkpg_product_group as name 
FROM tt_market INNER JOIN tt_market_product_group ON tt_market.market_id = tt_market_product_group.mkpg_market_id;

--$private_cache_get_upg_id_to_mkpg_id_mappings
select upg_user_product_group_id, upg_market_product_group_id from tt_user_product_group



--$private_get_mgts_with_too_many_product_limits

-- 50 is the base size of a tt_core_ns::LCProductLimitList
-- The ? is the length of the Guardian Admin login used by the server,
-- TTADMXXXMGR, usually.
-- The 32768 is the TTM limit.

SELECT 
tt_mgt.mgt_member as [Member],
tt_mgt.mgt_group as [Group],
tt_mgt.mgt_trader as [Trader],
count(1) as row_count,
CLNG((count(1) * (50 + ?)) + sum(len(tt_product_limit.plim_product))) as [Bytes]
FROM tt_mgt 
INNER JOIN tt_product_limit 
ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id
WHERE tt_product_limit.plim_for_simulation = 0
GROUP BY 
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader
HAVING (count(1) * (50 + ?)) + sum(len(tt_product_limit.plim_product)) > ?


--$private_generate_ttords
insert into tt_mgt(

mgt_created_datetime,   
mgt_created_user_id,
mgt_last_updated_datetime,
mgt_last_updated_user_id,

mgt_member,
mgt_group,      
mgt_trader,
mgt_description,

mgt_credit,
mgt_currency,
mgt_allow_trading,
mgt_ignore_pl,
mgt_risk_on,

mgt_publish_to_guardian,
mgt_mgt_key,

mgt_password,
mgt_can_associate_with_user_directly,
mgt_comp_id,
mgt_enable_sods,
mgt_use_simulation_credit,
mgt_simulation_credit,
mgt_type
)
SELECT distinct now, 0, now, 0, 
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
'',
0,'USD',0,0,0,
-- publish
1,
tt_gmgt.gm_member +
tt_gmgt.gm_group +
tt_gmgt.gm_trader,
'',1,0,1,
0,0,1
FROM tt_gmgt 
LEFT JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)
WHERE tt_mgt.mgt_id IS NULL
AND (
	 LEFT(tt_gmgt.gm_member,5) = 'TTORD'
	 AND tt_gmgt.gm_group <> 'XXX' 
	 AND LEFT(tt_gmgt.gm_trader,4) <> 'VIEW' 
	 AND LEFT(tt_gmgt.gm_trader,3) <> 'MGR'
	);


--$private_generate_non_ttords
insert into tt_mgt(

mgt_created_datetime,   
mgt_created_user_id,
mgt_last_updated_datetime,
mgt_last_updated_user_id,

mgt_member,
mgt_group,      
mgt_trader,
mgt_description,

mgt_credit,
mgt_currency,
mgt_allow_trading,
mgt_ignore_pl,

mgt_risk_on,
mgt_publish_to_guardian,
mgt_mgt_key,
mgt_password,
mgt_can_associate_with_user_directly,
mgt_comp_id,
mgt_enable_sods,
mgt_use_simulation_credit,
mgt_simulation_credit,
mgt_type
)
SELECT distinct now, 0, now, 0, 
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
'',
0,'USD',0,0,0,
-- do not publish
0,
tt_gmgt.gm_member +
tt_gmgt.gm_group +
tt_gmgt.gm_trader,
'',1,0,1,
0,0,
IIF( tt_gmgt.gm_member = 'TTADM'
	 OR tt_gmgt.gm_group = 'XXX' 
	 OR LEFT(tt_gmgt.gm_trader,3) = 'MGR' 
	 OR LEFT(tt_gmgt.gm_trader,4) = 'VIEW',2,0)
FROM tt_gmgt 
LEFT JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)
WHERE tt_mgt.mgt_id IS NULL 
AND (
	 LEFT(tt_gmgt.gm_member,5) <> 'TTORD'
	 OR tt_gmgt.gm_group = 'XXX' 
	 OR LEFT(tt_gmgt.gm_trader,3) = 'MGR' 
	 OR LEFT(tt_gmgt.gm_trader,4) = 'VIEW'
	);


-- generate the link between tt_mgt and tt_gmgt for non-proxy traders
--$private_generate_mxgs
insert into tt_mgt_gmgt (
mxg_created_datetime,
mxg_created_user_id,
mxg_last_updated_datetime,
mxg_last_updated_user_id,
mxg_mgt_id,
mxg_gmgt_id
)
SELECT now, 0, now, 0, 
tt_view_mgts_and_mxgs.mgt_id,
tt_gmgt.gm_id
FROM tt_view_mgts_and_mxgs 
INNER JOIN tt_gmgt ON (tt_view_mgts_and_mxgs.mgt_trader = tt_gmgt.gm_trader) AND (tt_view_mgts_and_mxgs.mgt_group = tt_gmgt.gm_group) AND (tt_view_mgts_and_mxgs.mgt_member = tt_gmgt.gm_member)
WHERE tt_view_mgts_and_mxgs.mxg_gmgt_id is null
AND (
	 LEFT(tt_gmgt.gm_member,5) <> 'TTORD'
	 OR tt_gmgt.gm_group = 'XXX' 
	 OR LEFT(tt_gmgt.gm_trader,3) = 'MGR' 
	 OR LEFT(tt_gmgt.gm_trader,4) = 'VIEW'
	);


-- get the orphan tt_gmgt records(like "FIX TTORD X Y") that are resulted from upgrade from 7.0.3
--$private_get_orphan_ttord_mgts
SELECT tt_gmgt.gm_id, tt_gmgt.gm_gateway_id, tt_gmgt.gm_member, tt_gmgt.gm_group, tt_gmgt.gm_trader 
FROM tt_gmgt LEFT JOIN tt_view_ttords_and_their_gateways 
ON tt_gmgt.gm_member = tt_view_ttords_and_their_gateways.mgt_member
AND tt_gmgt.gm_group = tt_view_ttords_and_their_gateways.mgt_group 
AND tt_gmgt.gm_trader = tt_view_ttords_and_their_gateways.mgt_trader 
AND tt_gmgt.gm_gateway_id = tt_view_ttords_and_their_gateways.gm_gateway_id
WHERE 
(	
	LEFT(tt_gmgt.gm_member,5) = 'TTORD'
	AND tt_gmgt.gm_group <> 'XXX' 
	AND LEFT(tt_gmgt.gm_trader,4) <> 'VIEW' 
	AND LEFT(tt_gmgt.gm_trader,3) <> 'MGR'
)
AND tt_view_ttords_and_their_gateways.mxg_id IS NULL 

--$private_get_mxg
select mxg_id 
from tt_mgt_gmgt 
where mxg_mgt_id = ? and mxg_gmgt_id = ?


--$private_get_users_without_default_customer_defaults
SELECT tt_user.user_id as [id]
FROM tt_user 
LEFT JOIN tt_view_default_customer_defaults 
ON tt_user.user_id = tt_view_default_customer_defaults.cusd_user_id
where tt_view_default_customer_defaults.cusd_user_id is null


--$private_get_users_company_combos_without_default_customer_defaults
SELECT 
tt_user_company_permission.ucp_comp_id, 
tt_user_company_permission.ucp_user_id
FROM tt_company 
INNER JOIN (tt_user_group 
INNER JOIN (tt_user 
INNER JOIN (tt_user_company_permission 
LEFT JOIN tt_view_default_customer_defaults 
ON (tt_user_company_permission.ucp_user_id = tt_view_default_customer_defaults.cusd_user_id) AND (tt_user_company_permission.ucp_comp_id = tt_view_default_customer_defaults.cusd_comp_id)) 
ON tt_user.user_id = tt_user_company_permission.ucp_user_id) 
ON tt_user_group.ugrp_group_id = tt_user.user_group_id) 
ON tt_company.comp_id = tt_user_group.ugrp_comp_id
where tt_view_default_customer_defaults.cusd_user_id is null
and tt_company.comp_is_broker = 0


--$private_generate_missing_default_customer_defaults
insert into tt_customer_default
(
cusd_created_datetime,
cusd_created_user_id,
cusd_last_updated_datetime,
cusd_last_updated_user_id,

cusd_user_id,
cusd_customer,
cusd_selected,
cusd_market_id,

cusd_product,
cusd_product_type,
cusd_account_id,
cusd_account_type,

cusd_give_up,
cusd_fft2,
cusd_fft3,
cusd_first_default,

cusd_product_in_hex,
cusd_gateway_id,
-- 6 obsolete, not obsolete fields
cusd_max_order_qty,
cusd_open_close,
cusd_order_type,
cusd_restriction,
cusd_time_in_force,
cusd_use_max_order_qty,

cusd_comp_id,
cusd_on_behalf_of_mgt_id,
cusd_on_behalf_of_user_id,
cusd_on_behalf_of_account_id,
cusd_default_gmgt_id,

cusd_fft4,
cusd_fft5,
cusd_fft6,
cusd_investment_decision,
cusd_execution_decision,
cusd_client,

cusd_dea,
cusd_trading_capacity,
cusd_liquidity_provision,
cusd_cdi,
cusd_al_algo_id
)

select 
now,0,now,0,

tt_user.user_id,
"<DEFAULT>",
1,
-1,

"*",
"*",
1,
"A1",

"",
"",
"",
1,"2A",-1,
-- 6 obsolete, not obsolete fields
1,'Open','Limit','<None>','GTD',CBYTE(0),
0,0,0,1,0,
"","","","","","",
"N","N","N","N",0
from tt_user
where tt_user.user_id in (-9999)

--$private_insert_missing_default_customer_defaults_multibroker
insert into tt_customer_default
(
cusd_created_datetime,
cusd_created_user_id,
cusd_last_updated_datetime,
cusd_last_updated_user_id,

cusd_user_id,
cusd_customer,
cusd_selected,
cusd_market_id,

cusd_product,
cusd_product_type,
cusd_account_id,
cusd_account_type,

cusd_give_up,
cusd_fft2,
cusd_fft3,
cusd_first_default,

cusd_product_in_hex,
cusd_gateway_id,
-- 6 obsolete, not obsolete fields
cusd_max_order_qty,
cusd_open_close,
cusd_order_type,
cusd_restriction,
cusd_time_in_force,
cusd_use_max_order_qty,

cusd_comp_id,
cusd_on_behalf_of_mgt_id,
cusd_on_behalf_of_user_id,
cusd_on_behalf_of_account_id,
cusd_default_gmgt_id,

cusd_fft4,
cusd_fft5,
cusd_fft6,
cusd_investment_decision,
cusd_execution_decision,
cusd_client,

cusd_dea,
cusd_trading_capacity,
cusd_liquidity_provision,
cusd_cdi,
cusd_al_algo_id
)

values
(
?,?,?,?,

?,
"<DEFAULT>",
1,
-1,

"*",
"*",
1,
"A1",

"",
"",
"",
1,"2A",-1,
-- 6 obsolete, not obsolete fields
1,'Open','Limit','<None>','GTD',CBYTE(0),
?,0,0,1,0,"","","","","","","N","N","N","N",0)

--$private_get_user_user_relationship_by_id
select * from tt_user_user_relationship where uur_id = ?

--$private_get_product_limit_by_id
select * from tt_product_limit where plim_product_limit_id = ?

--$private_get_margin_limit_by_id
select * from tt_margin_limit where mlim_margin_limit_id = ?

--$private_get_account_by_id
select * from tt_account where acct_id = ?

--$private_get_account_group_by_id
select * from tt_account_group where ag_id = ?

--$private_get_mgt_by_id
select * from tt_mgt where mgt_id = ?

--$private_get_mgt_by_mgt_key
SELECT mgt_id, mgt_member, mgt_group, mgt_trader
FROM tt_mgt 
WHERE tt_mgt.mgt_mgt_key = ?;


--$private_get_mgt_by_mxg_id
select tt_mgt.* from tt_mgt
inner join tt_mgt_gmgt on tt_mgt_gmgt.mxg_mgt_id = tt_mgt.mgt_id
where tt_mgt_gmgt.mxg_id = ?

--$private_update_duplicate_gateway_names
update tt_gateway
set gateway_name = gateway_name + ":" + CStr(gateway_id) + ":DUPLICATE NAME"
where gateway_name in (
select gateway_name from tt_gateway
group by gateway_name
having count(1) > 1)

--$private_get_duplicate_gateway_names
select gateway_name from tt_gateway
group by gateway_name
having count(1) > 1

--$private_generate_missing_user_gmgts
insert into tt_user_gmgt
(
uxg_created_datetime,
uxg_created_user_id,
uxg_last_updated_datetime,
uxg_last_updated_user_id,

uxg_user_id,
uxg_gmgt_id,
uxg_automatically_login,
uxg_preferred_ip,

uxg_clearing_member,
uxg_default_account,
uxg_available_to_user,
uxg_available_to_fix_adapter_user,
uxg_mandatory_login,

uxg_exchange_data1,
uxg_exchange_data2,
uxg_exchange_data3,
uxg_exchange_data4,
uxg_exchange_data5,
uxg_exchange_data6,

uxg_market_orders
)
SELECT
now, 0, now, 0,
[tt_view_missing_uxgs_what_users_should_have].uxg_user_id,
[tt_view_missing_uxgs_what_users_should_have].gm_id,
1,'',
'','A1',0,0,0,'','','','','','',0
FROM (tt_view_missing_uxgs_what_users_should_have LEFT JOIN tt_view_missing_uxgs_what_users_have ON ([tt_view_missing_uxgs_what_users_should_have].gm_gateway_id=[tt_view_missing_uxgs_what_users_have].gm_gateway_id) AND ([tt_view_missing_uxgs_what_users_should_have].uxg_user_id=[tt_view_missing_uxgs_what_users_have].uxg_user_id) AND ([tt_view_missing_uxgs_what_users_should_have].mgt_id=[tt_view_missing_uxgs_what_users_have].mgt_id)) INNER JOIN tt_gmgt ON [tt_view_missing_uxgs_what_users_should_have].gm_id=tt_gmgt.gm_id
where tt_view_missing_uxgs_what_users_have.gm_gateway_id is null


--$private_update_target_acctd_sequence_number_by_userid
update tt_account_default
set acctd_sequence_number = ?
where acctd_sequence_number = ?
and acctd_user_id = ?
and acctd_comp_id = ?

--$private_get_missing_mgt_gmgts
SELECT count(1) as cnt
FROM tt_view_synthesized_but_missing_mgt_gmgts

--$private_insert_no_mgt_record_mgt
insert into tt_mgt (
mgt_created_datetime,
mgt_created_user_id,      
mgt_last_updated_datetime,
mgt_last_updated_user_id,
mgt_member,
mgt_group,
mgt_trader,
mgt_description,
mgt_credit,
mgt_currency,
mgt_allow_trading,
mgt_ignore_pl,
mgt_risk_on,
mgt_publish_to_guardian,
mgt_mgt_key,
mgt_password,
mgt_can_associate_with_user_directly,
mgt_comp_id,
mgt_enable_sods,
mgt_use_simulation_credit,
mgt_simulation_credit,
mgt_type)
SELECT
now,1,now,1,
"<No","MGT","Record>",
"",0,"USD",0,0,0,0,
"<NoMGTRecord>",
"",
0,0,1,
0,0,0
-- tt_login_server_settings is just there to satisfy the syntax and to return exactly one row.
from tt_login_server_settings
where not exists (select mgt_id from tt_mgt where tt_mgt.mgt_member = '<No' and tt_mgt.mgt_group = "MGT" and tt_mgt.mgt_trader = "Record>")


--$private_insert_no_mgt_record_gmgts
insert into tt_gmgt (gm_created_datetime, gm_created_user_id, gm_last_updated_datetime, gm_last_updated_user_id,  
gm_gateway_id, 
gm_member, 
gm_group, 
gm_trader, gm_gateway_mgt_key)
SELECT distinct  now, 1, now, 1, 
tt_view_synthesized_but_missing_mgt_gmgts.gm_gateway_id, 
"<No", 
"MGT",
"Record>",
CSTR(tt_view_synthesized_but_missing_mgt_gmgts.gm_gateway_id) + ";<NoMGTRecord>"
FROM (tt_view_synthesized_but_missing_mgt_gmgts LEFT JOIN tt_view_No_MGT_Records ON 
tt_view_synthesized_but_missing_mgt_gmgts.gm_gateway_id = tt_view_No_MGT_Records.gm_gateway_id) INNER JOIN tt_mgt ON 
(tt_view_synthesized_but_missing_mgt_gmgts.gm_trader = tt_mgt.mgt_trader) AND (tt_view_synthesized_but_missing_mgt_gmgts.gm_group = 
tt_mgt.mgt_group) AND (tt_view_synthesized_but_missing_mgt_gmgts.gm_member = tt_mgt.mgt_member)
where tt_view_No_MGT_Records.gm_id is null

--$private_insert_missing_mgt_gmgts
insert into tt_mgt_gmgt (mxg_created_datetime, mxg_created_user_id, mxg_last_updated_datetime, mxg_last_updated_user_id, mxg_mgt_id, 
mxg_gmgt_id)
SELECT now, 1, now, 1,  tt_mgt.mgt_id, tt_view_No_MGT_Records.gm_id
FROM (tt_view_synthesized_but_missing_mgt_gmgts LEFT JOIN tt_view_No_MGT_Records ON 
tt_view_synthesized_but_missing_mgt_gmgts.gm_gateway_id = tt_view_No_MGT_Records.gm_gateway_id) INNER JOIN tt_mgt ON 
(tt_view_synthesized_but_missing_mgt_gmgts.gm_trader = tt_mgt.mgt_trader) AND (tt_view_synthesized_but_missing_mgt_gmgts.gm_group = 
tt_mgt.mgt_group) AND (tt_view_synthesized_but_missing_mgt_gmgts.gm_member = tt_mgt.mgt_member)
where tt_view_No_MGT_Records.gm_id is not null

--$private_get_gateway_mgt_data

SELECT 
tt_gmgt.gm_gateway_id,
tt_mgt.mgt_id,
tt_account.acct_name,
tt_mgt.mgt_member,
tt_mgt.mgt_group,
tt_mgt.mgt_trader,
tt_mgt.mgt_comp_id,
tt_account.acct_last_updated_datetime
FROM (tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
INNER JOIN tt_account ON tt_mgt.mgt_id = tt_account.acct_mgt_id
where tt_mgt.mgt_publish_to_guardian = 1

union

SELECT str(tt_gmgt.gm_gateway_id) + chr(9) +  tt_mgt.mgt_member + chr(9) +  tt_mgt.mgt_group + chr(9) +  tt_mgt.mgt_trader 
	+ chr(9) + "m" + chr(9) +  tt_gmgt.gm_member  + chr(9) + tt_gmgt.gm_group  + chr(9) +  tt_gmgt.gm_trader
	
FROM tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id
where tt_mgt.mgt_publish_to_guardian = 1


-----------------------------------------------------------------------
-- sql used only by the User Setup Server itself ends here
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- Get Affected Users

-- When the database is updated, we broadcast what users are affected
-- by the update.  These are the sql statements that get the affected
-- users.  They all should have two columns, user_id user_logon.
-----------------------------------------------------------------------


--$get_affected_users_for_update_user
select user_id, user_login
from tt_user
where user_id in (-9999)

--$get_affected_users_for_update_mgt_by_mgt_id
SELECT DISTINCT *
FROM
(
    SELECT
        tt_user.user_id,
        tt_user.user_login
    FROM (( tt_mgt
    INNER JOIN tt_gmgt ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader )
    INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
    INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id
    WHERE tt_mgt.mgt_id = ?

    UNION

    SELECT
        tt_user.user_id,
        tt_user.user_login
    FROM ((((( tt_mgt
    INNER JOIN tt_gmgt ON tt_mgt.mgt_member = tt_gmgt.gm_member AND tt_mgt.mgt_group = tt_gmgt.gm_group AND tt_mgt.mgt_trader = tt_gmgt.gm_trader )
    INNER JOIN tt_mgt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id )
    INNER JOIN tt_mgt AS proxy_mgt ON tt_mgt_gmgt.mxg_mgt_id = proxy_mgt.mgt_id )
    INNER JOIN tt_gmgt AS proxy_gmgt ON proxy_mgt.mgt_member = proxy_gmgt.gm_member AND proxy_mgt.mgt_group = proxy_gmgt.gm_group AND proxy_mgt.mgt_trader = proxy_gmgt.gm_trader )
    INNER JOIN tt_user_gmgt ON proxy_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
    INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id
    WHERE tt_mgt.mgt_id = ?
)

--$get_affected_users_for_update_user_account
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_user
INNER JOIN tt_user_account
ON tt_user.user_id = tt_user_account.uxa_user_id
where tt_user_account.uxa_user_account_id in (-9999)

--$get_affected_users_for_update_user_gmgt
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_user
INNER JOIN tt_user_gmgt
ON tt_user.user_id = tt_user_gmgt.uxg_user_id
where tt_user_gmgt.uxg_user_gmgt_id in (-9999)
-- don't test the available flags because maybe it's the flags that are changing

--$get_affected_users_for_update_gmgt
SELECT tt_user.user_id, tt_user.user_login
FROM tt_user
INNER JOIN tt_user_gmgt
ON tt_user.user_id = tt_user_gmgt.uxg_user_id
where tt_user_gmgt.uxg_gmgt_id in (-9999)

--$get_affected_users_for_delete_user_gmgt
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_user
INNER JOIN tt_user_gmgt
ON tt_user.user_id = tt_user_gmgt.uxg_user_id
where tt_user_gmgt.uxg_user_gmgt_id in (-9999)
AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))

--$get_affected_users_for_update_mgt
-- use for deleting a proxy mgt too
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_mgt 
INNER JOIN (tt_user 
INNER JOIN (tt_gmgt 
INNER JOIN tt_user_gmgt 
ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
ON (tt_mgt.mgt_trader = tt_gmgt.gm_trader) 
AND (tt_mgt.mgt_group = tt_gmgt.gm_group) 
AND (tt_mgt.mgt_member = tt_gmgt.gm_member)
where tt_mgt.mgt_id in (-9999)
AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))

--$get_affected_users_for_delete_nonproxy_mgt
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_user 
INNER JOIN ((tt_gmgt 
INNER JOIN (tt_mgt 
INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) 
INNER JOIN (tt_user_gmgt 
INNER JOIN ((tt_mgt_gmgt AS tt_mgt_gmgt_1 
INNER JOIN tt_mgt AS tt_mgt_1 ON tt_mgt_gmgt_1.mxg_mgt_id = tt_mgt_1.mgt_id) 
INNER JOIN tt_gmgt AS tt_gmgt_1 ON (tt_mgt_1.mgt_member = tt_gmgt_1.gm_member) AND (tt_mgt_1.mgt_group = tt_gmgt_1.gm_group) AND (tt_mgt_1.mgt_trader = tt_gmgt_1.gm_trader)) 
ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt_1.gm_id) 
ON (tt_gmgt_1.gm_gateway_id = tt_gmgt.gm_gateway_id) AND (tt_gmgt.gm_id = tt_mgt_gmgt_1.mxg_gmgt_id)) 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE tt_mgt.mgt_id in (-9999)
AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))

--$get_affected_users_for_delete_proxy_gmgt
SELECT DISTINCT tt_user.user_id, tt_user.user_login
FROM tt_user 
INNER JOIN (tt_gmgt 
INNER JOIN tt_user_gmgt 
ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE tt_gmgt.gm_id in (-9999)
AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))

--$get_affected_users_for_delete_nonproxy_gmgt
SELECT distinct tt_user.user_id, tt_user.user_login
FROM (tt_user 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
INNER JOIN ((tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN tt_mgt_gmgt 
ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id) 
ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id) 
INNER JOIN tt_gmgt AS tt_gmgt_1 
ON (tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id) AND (tt_mgt.mgt_trader = tt_gmgt_1.gm_trader) AND (tt_mgt.mgt_group = tt_gmgt_1.gm_group) AND (tt_mgt.mgt_member = tt_gmgt_1.gm_member)) 
ON (tt_user_gmgt.uxg_gmgt_id = tt_gmgt_1.gm_id) AND (tt_user_gmgt.uxg_gmgt_id = tt_gmgt_1.gm_id)
where tt_gmgt.gm_id in (-9999)
AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))


--$get_affected_users_for_update_user_group
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_user_group 
INNER JOIN tt_user 
ON tt_user_group.ugrp_group_id = tt_user.user_group_id
where user_group_id in (-9999)

--$get_affected_users_for_update_customer_default
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_customer_default 
INNER JOIN tt_user 
ON tt_customer_default.cusd_user_id = tt_user.user_id
where cusd_id  in (-9999)

--$get_affected_users_for_update_user_company
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_user_company_permission 
INNER JOIN tt_user 
ON tt_user_company_permission.ucp_user_id = tt_user.user_id
where ucp_id  in (-9999)

--$get_affected_users_for_update_account_default
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_account_default 
INNER JOIN tt_user 
ON tt_account_default.acctd_user_id = tt_user.user_id
where acctd_id  in (-9999)

--$get_affected_users_for_user_product_group
SELECT distinct tt_user.user_id, tt_user.user_login
FROM tt_user_product_group
INNER JOIN tt_user 
ON tt_user_product_group.upg_user_id = tt_user.user_id
where upg_user_product_group_id  in (-9999)

--$get_affected_users_for_update_account
SELECT tt_user.user_id, tt_user.user_login
FROM (tt_user 
INNER JOIN ((tt_mgt 
INNER JOIN tt_gmgt 
ON (tt_mgt.mgt_trader = tt_gmgt.gm_trader) 
AND (tt_mgt.mgt_group = tt_gmgt.gm_group) 
AND (tt_mgt.mgt_member = tt_gmgt.gm_member)) 
INNER JOIN tt_user_gmgt 
ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
INNER JOIN tt_account 
ON tt_mgt.mgt_id = tt_account.acct_mgt_id
where tt_account.acct_id in (-9999)
AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))
union
SELECT tt_user.user_id, tt_user.user_login
FROM tt_user 
INNER JOIN (tt_account 
INNER JOIN tt_customer_default 
ON tt_account.acct_id = tt_customer_default.cusd_account_id) 
ON tt_user.user_id = tt_customer_default.cusd_user_id
where tt_account.acct_id in (-9999)
union
SELECT tt_user.user_id, tt_user.user_login
FROM tt_user 
INNER JOIN (tt_account 
INNER JOIN tt_account_default 
ON tt_account.acct_id = tt_account_default.acctd_account_id) 
ON tt_user.user_id = tt_account_default.acctd_user_id
where tt_account.acct_id in (-9999)

--$get_affected_users_for_update_product_limit
SELECT distinct tt_user.user_id, tt_user.user_login
FROM (tt_mgt 
INNER JOIN tt_product_limit 
ON tt_mgt.mgt_id = tt_product_limit.plim_mgt_id) 
INNER JOIN (tt_gmgt INNER JOIN (tt_user 
INNER JOIN tt_user_gmgt 
ON tt_user.user_id = tt_user_gmgt.uxg_user_id) 
ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) 
ON (tt_mgt.mgt_trader = tt_gmgt.gm_trader) 
AND (tt_mgt.mgt_group = tt_gmgt.gm_group) 
AND (tt_mgt.mgt_member = tt_gmgt.gm_member)
where plim_product_limit_id in (-9999)
AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))

--$get_affected_users_for_update_user_user_relationship
SELECT tt_user.user_id, tt_user.user_login
FROM tt_user_user_relationship INNER JOIN tt_user ON tt_user_user_relationship.uur_user_id1 = tt_user.user_id
where uur_id in (-9999)
union
SELECT tt_user.user_id, tt_user.user_login
FROM tt_user_user_relationship INNER JOIN tt_user ON tt_user_user_relationship.uur_user_id2 = tt_user.user_id
where uur_id in (-9999)

-----------------------------------------------------------------------
-- Get Affected Users ends here
-----------------------------------------------------------------------

-- for mix and match, batch enabled get_revision_info.  Not called directly.

--$get_revision_info_acctd
SELECT
    tt_user.user_login,
    count(tt_account_default.acctd_id) as row_cnt, 
    max(tt_account_default.acctd_last_updated_datetime) as max_date
FROM tt_user
LEFT JOIN tt_account_default ON tt_user.user_id = tt_account_default.acctd_user_id
WHERE tt_user.user_login in ('??')
GROUP BY tt_user.user_login

--$get_revision_info_cusd
SELECT tt_user.user_login, Count(1) as row_cnt, 
MAX(iif(cusd_last_updated_datetime > acct_last_updated_datetime, cusd_last_updated_datetime, acct_last_updated_datetime)) as max_date
FROM tt_account 
INNER JOIN (tt_user 
INNER JOIN tt_customer_default ON tt_user.user_id = tt_customer_default.cusd_user_id) ON tt_account.acct_id = tt_customer_default.cusd_account_id
WHERE tt_user.user_login in ('??')
GROUP BY tt_user.user_login

--$get_revision_info_ugps
SELECT tt_user.user_login, Count(tt_user_group_sod_permission.ugps_user_id) AS row_cnt, 
Max(tt_user_group_sod_permission.ugps_last_updated_datetime) AS max_date
FROM tt_user LEFT JOIN tt_user_group_sod_permission ON tt_user.user_id = tt_user_group_sod_permission.ugps_user_id
WHERE tt_user.user_login in ('??')
GROUP BY tt_user.user_login;

--$get_revision_info_ares
SELECT tt_user.user_login, Count(tt_user_account.uxa_user_id) AS row_cnt, 
Max(tt_user_account.uxa_last_updated_datetime) AS max_date
FROM tt_user LEFT JOIN tt_user_account ON tt_user.user_id = tt_user_account.uxa_user_id
WHERE tt_user.user_login in ('??')
GROUP BY tt_user.user_login;

--$get_revision_info_user
SELECT tt_user.user_login, Count(1) as row_cnt, 
Max(iif(user_last_updated_datetime > lss_last_updated_datetime, user_last_updated_datetime, lss_last_updated_datetime)) as max_date
FROM tt_user, tt_login_server_settings
WHERE tt_user.user_login in ('??')
GROUP BY tt_user.user_login

--$get_revision_info_upg
SELECT
    tt_user.user_login,
    count(tt_user_product_group.upg_user_product_group_id) AS row_cnt, 
    max(tt_user_product_group.upg_last_updated_datetime) AS max_date
FROM tt_user
LEFT JOIN tt_user_product_group ON tt_user.user_id = tt_user_product_group.upg_user_id
WHERE tt_user.user_login in ('??')
GROUP BY tt_user.user_login

--$get_revision_info_uur
SELECT
    tt_user.user_login,
    count(tt_user_user_relationship.uur_id) as row_cnt,
    max(tt_user_user_relationship.uur_last_updated_datetime) as max_date
FROM tt_user
LEFT JOIN tt_user_user_relationship ON tt_user.user_id = tt_user_user_relationship.uur_user_id2
WHERE ( tt_user_user_relationship.uur_relationship_type = 'fix' or tt_user_user_relationship.uur_relationship_type is null )
    AND tt_user.user_login in ('??')
GROUP BY tt_user.user_login

--$get_revision_info_ucomp
SELECT
    tt_user.user_login,
    count(tt_user_company_permission.ucp_id) AS row_cnt, 
    max(tt_user_company_permission.ucp_last_updated_datetime) AS max_date
FROM tt_user
LEFT JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id
WHERE tt_user.user_login in ('??')
GROUP BY tt_user.user_login

-- no args
--$get_revision_info_comp
SELECT count(1) as row_cnt,
MAX(comp_last_updated_datetime) as max_date
FROM tt_company

-- no args
--$get_revision_info_cmkp
SELECT count(1) as row_cnt,
MAX(cmkp_last_updated_datetime) as max_date
FROM tt_company_market_product
WHERE tt_company_market_product.cmkp_margin_times_100 <> 0

-- no args
--$get_revision_info_bvmf
SELECT count(1) as row_cnt,
MAX(bvmf_last_updated_datetime) as max_date
FROM tt_bvmf_participant

--$get_revision_info_gateway_routing
SELECT count(1) as row_cnt,
MAX(last_updated_datetime) as max_date
FROM tt_view_routing_keys_for_revision_info
WHERE gm_gateway_id = ?

--$get_revision_info_gateway_password
SELECT count(1) as row_cnt,
MAX(last_updated_datetime) as max_date
FROM tt_view_mgts_with_passwords_for_revision_info
WHERE gm_gateway_id = ?

--$get_revision_info_gateway_acct
SELECT count(1) as row_cnt,
MAX(acct_last_updated_datetime) as max_date
FROM tt_account 
WHERE acct_include_in_auto_sods = 0
AND acct_id > 1

--$get_revision_info_users_who_can_connect_to_gateway
SELECT
    count( tt_user.user_id ) as row_cnt,
    max( user_last_updated_datetime ) as max_date
FROM (( tt_gateway
LEFT JOIN tt_gmgt ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id )
LEFT JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
LEFT JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id
WHERE tt_gmgt.gm_gateway_id = ?
    AND ( uxg_available_to_user = 1 or ( user_fix_adapter_role = 1 and uxg_available_to_fix_adapter_user = 1 ) )


--$private_get_last_inserted_id

select @@IDENTITY

--$private_get_mgt_gmgts_nonMB
SELECT distinct
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader,
tt_gmgt.gm_member,
tt_gmgt.gm_group,
tt_gmgt.gm_trader,
0 as broker_id,
0 as company_id,
tt_gmgt.gm_gateway_id
FROM ((tt_mgt 
  INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id)
  INNER JOIN tt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id and (tt_gmgt.gm_trader <> tt_mgt.mgt_trader OR tt_gmgt.gm_group <> tt_mgt.mgt_group OR tt_gmgt.gm_member <> tt_mgt.mgt_member))

--$private_get_mgt_sod_bc
SELECT distinct
tt_mgt.mgt_member, 
tt_mgt.mgt_group, 
tt_mgt.mgt_trader,
tt_mgt.mgt_enable_sods,
tt_gmgt.gm_gateway_id
FROM ((tt_mgt 
  INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id)
  INNER JOIN tt_gmgt ON tt_gmgt.gm_id = tt_mgt_gmgt.mxg_gmgt_id)

--$private_get_broker_ids_for_user
select c.comp_id
    from (( tt_user u
        inner join tt_user_company_permission ucp on u.user_id = ucp.ucp_user_id )
        inner join tt_company c on ucp.ucp_comp_id = c.comp_id )
    where u.user_login = ? and c.comp_is_broker = 1

--$private_get_broker_ids_and_markets_for_user
select tt_company.comp_id, tt_gateway.gateway_market_id
from ((((( tt_user
inner join tt_user_company_permission on tt_user.user_id = tt_user_company_permission.ucp_user_id )
inner join tt_company on tt_user_company_permission.ucp_comp_id = tt_company.comp_id )
inner join tt_user_gmgt on tt_user.user_id = tt_user_gmgt.uxg_user_id )
inner join tt_gmgt on tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
inner join tt_mgt on tt_gmgt.gm_member = tt_mgt.mgt_member and tt_gmgt.gm_group = tt_mgt.mgt_group and tt_gmgt.gm_trader = tt_mgt.mgt_trader )
inner join tt_gateway on tt_gmgt.gm_gateway_id = tt_gateway.gateway_id
where ( tt_user_gmgt.uxg_available_to_user = 1 or ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
    and tt_user.user_login = ?
    and tt_company.comp_is_broker = 1
    and tt_company.comp_id = tt_mgt.mgt_comp_id
    and 1 = ( select lss_multibroker_mode from tt_login_server_settings )
    and 0 = tt_user.user_mgt_generation_method
    and tt_user.user_fix_adapter_role NOT IN ( 2, 3, 4, 5 )
group by tt_company.comp_id, tt_gateway.gateway_market_id

UNION

select tt_user_group.ugrp_comp_id as [comp_id], market_id as [gateway_market_id]
from tt_market, ( tt_user
inner join tt_user_group on tt_user.user_group_id = tt_user_group.ugrp_group_id )
where tt_user.user_login = ?
    and ( 0 = ( select lss_multibroker_mode from tt_login_server_settings ) or tt_user.user_fix_adapter_role in ( 2, 3, 4, 5 ) )

UNION

select tt_user_company_permission.ucp_comp_id as [comp_id], market_id as [gateway_market_id]
from tt_market, ( tt_user
inner join tt_user_company_permission on tt_user.user_id = tt_user_company_permission.ucp_user_id )
where 1 = ( select lss_multibroker_mode from tt_login_server_settings )
      and 0 <> tt_user.user_mgt_generation_method
      and tt_user.user_login = ?

--$private_get_product_group_restrictions_for_user
select u.user_login,
    mkpg.mkpg_market_id, 
    mkpg.mkpg_product_group_id,
    upg.upg_comp_id
from (( tt_user u
    inner join tt_user_product_group upg on u.user_id = upg.upg_user_id )
    inner join tt_market_product_group mkpg on upg.upg_market_product_group_id = mkpg.mkpg_market_product_group_id )
where u.user_login = ?

--$private_get_orphaned_account_groups
SELECT
    tt_account_group.ag_id,
    tt_account_group.ag_is_auto_assigned
FROM tt_account_group
LEFT JOIN tt_account ON tt_account_group.ag_id = tt_account.acct_account_group_id
WHERE tt_account.acct_id IS NULL

--$private_get_aggps_for_assigned_ag_deletion
SELECT aggp_account_group_id, aggp_group_id
FROM tt_account_group_group_permission
WHERE aggp_account_group_id = ? AND aggp_account_group_id IN
    ( SELECT ag_id FROM tt_account_group where ag_is_auto_assigned = 0 )

--$private_get_automatic_user_groups_for_user
SELECT ugp_group_id
FROM tt_user_group_permission
WHERE ugp_user_id = ? AND ugp_automatically_add = 1

--$get_users_with_gw_logins_for_gateway
SELECT tt_user.user_id, tt_user.user_login
FROM tt_user 
INNER JOIN ((tt_gmgt 
INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) 
AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member)) 
INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON tt_user.user_id = tt_user_gmgt.uxg_user_id
WHERE (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))
AND tt_gmgt.gm_gateway_id = ?
GROUP BY tt_user.user_id, tt_user.user_login

--$private_get_multi_connection_logins_for_user_id
SELECT
    tt_company.comp_name,
    tt_gateway.gateway_name,
    count(*) as [logins]
FROM (((((( tt_user
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
INNER JOIN tt_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader )
INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id )
INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt_1.gm_id )
INNER JOIN tt_company ON tt_mgt.mgt_comp_id = tt_company.comp_id )
INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id
WHERE
    tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id
    AND tt_user_gmgt.uxg_available_to_user = 1
    AND tt_user.user_fix_adapter_role <> 1
    AND tt_user.user_id = ?
GROUP BY
    tt_company.comp_name,
    tt_gateway.gateway_name
HAVING
    count(*) > 1

--$private_reset_gateway_active_state
update tt_gateway set gateway_is_active = CByte(0)

--$private_get_all_accounts_and_account_groups
SELECT
    tt_account.acct_id,
    tt_account.acct_name,
    tt_account_group.ag_id,
    tt_account_group.ag_name
FROM tt_account
INNER JOIN tt_account_group ON tt_account.acct_account_group_id = tt_account_group.ag_id
ORDER BY tt_account.acct_name_in_hex

--$private_get_all_account_id_visibility_by_comp_id
SELECT
    acct_comp_id AS [comp_id],
    acct_id
FROM tt_account
UNION
SELECT
    ccp.ccp_buyside_comp_id AS [comp_id],
    tt_account.acct_id
FROM tt_account
INNER JOIN tt_company_company_permission [ccp] ON tt_account.acct_comp_id = ccp.ccp_broker_comp_id


--$private_get_user_compliance_data_by_exchange_id
SELECT DISTINCT
    gm_gateway_id,
    user_id,
    user_login,
    broker_id,
    user_prevent_orders_based_on_price_ticks,
    int_user_prevent_orders_price_ticks,
    user_enforce_price_limit_on_buysell_only,
    user_prevent_orders_based_on_rate,
    int_user_prevent_orders_rate,
    user_gtc_orders_allowed,
    user_persist_orders_on_eurex,
    user_undefined_accounts_allowed,
    user_account_changes_allowed,
    user_wholesale_orders_with_undefined_accounts_allowed,
    user_can_submit_market_orders
FROM
(
  SELECT
      tt_gmgt.gm_gateway_id,
      tt_user.user_id,
      tt_user.user_login,
      0 as broker_id,
      tt_user.user_prevent_orders_based_on_price_ticks,
      tt_user.int_user_prevent_orders_price_ticks,
      tt_user.user_enforce_price_limit_on_buysell_only,
      tt_user.user_prevent_orders_based_on_rate,
      tt_user.int_user_prevent_orders_rate,
      tt_user.user_gtc_orders_allowed,
      tt_user.user_persist_orders_on_eurex,
      tt_user.user_undefined_accounts_allowed,
      tt_user.user_account_changes_allowed,
      tt_user.user_wholesale_orders_with_undefined_accounts_allowed,
      CByte( MIN( IIF( 0 = tt_user_gmgt.uxg_market_orders, tt_user.user_can_submit_market_orders,
          IIF( 1 = tt_user_gmgt.uxg_market_orders, 1, 0 ) ) ) ) as user_can_submit_market_orders
  FROM ( tt_gmgt 
  INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
  INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id
  WHERE (uxg_available_to_user = 1 or (user_fix_adapter_role = 1 and uxg_available_to_fix_adapter_user = 1))
      AND 0 = ( select lss_multibroker_mode from tt_login_server_settings )
      AND tt_gmgt.gm_gateway_id = ?
  GROUP BY
      tt_gmgt.gm_gateway_id,
      tt_user.user_id,
      tt_user.user_login,
      tt_user.user_prevent_orders_based_on_price_ticks,
      tt_user.int_user_prevent_orders_price_ticks,
      tt_user.user_enforce_price_limit_on_buysell_only,
      tt_user.user_prevent_orders_based_on_rate,
      tt_user.int_user_prevent_orders_rate,
      tt_user.user_gtc_orders_allowed,
      tt_user.user_persist_orders_on_eurex,
      tt_user.user_undefined_accounts_allowed,
      tt_user.user_account_changes_allowed,
      tt_user.user_wholesale_orders_with_undefined_accounts_allowed
UNION
  SELECT
      tt_gmgt.gm_gateway_id,
      tt_user.user_id,
      tt_user.user_login,
      tt_user_company_permission.ucp_comp_id as broker_id,
      tt_user_company_permission.ucp_prevent_orders_based_on_price_ticks as user_prevent_orders_based_on_price_ticks,
      tt_user_company_permission.ucp_prevent_orders_price_ticks as int_user_prevent_orders_price_ticks,
      tt_user_company_permission.ucp_enforce_price_limit_on_buysell_only as user_enforce_price_limit_on_buysell_only,
      tt_user_company_permission.ucp_prevent_orders_based_on_rate as user_prevent_orders_based_on_rate,
      tt_user_company_permission.ucp_prevent_orders_rate as int_user_prevent_orders_rate,
      tt_user_company_permission.ucp_gtc_orders_allowed as user_gtc_orders_allowed,
      tt_user_company_permission.ucp_persist_orders_on_eurex as user_persist_orders_on_eurex,
      tt_user_company_permission.ucp_undefined_accounts_allowed as user_undefined_accounts_allowed,
      tt_user_company_permission.ucp_account_changes_allowed as user_account_changes_allowed,
      tt_user_company_permission.ucp_wholesale_orders_with_undefined_accounts_allowed as user_wholesale_orders_with_undefined_accounts_allowed,
      CByte( MIN( IIF( 0 = tt_user_gmgt.uxg_market_orders, tt_user_company_permission.ucp_can_submit_market_orders,
          IIF( 1 = tt_user_gmgt.uxg_market_orders, 1, 0 ) ) ) ) as user_can_submit_market_orders
  FROM ((( tt_gmgt 
  INNER JOIN tt_user_gmgt ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id )
  INNER JOIN tt_mgt ON tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader )
  INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id )
  INNER JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id
  WHERE (uxg_available_to_user = 1 or (user_fix_adapter_role = 1 and uxg_available_to_fix_adapter_user = 1))
      AND 1 = ( select lss_multibroker_mode from tt_login_server_settings )
      AND tt_user_company_permission.ucp_comp_id = tt_mgt.mgt_comp_id
      AND tt_gmgt.gm_gateway_id = ?
  GROUP BY
      tt_gmgt.gm_gateway_id,
      tt_user.user_id,
      tt_user.user_login,
      tt_user_company_permission.ucp_comp_id,
      tt_user_company_permission.ucp_prevent_orders_based_on_price_ticks,
      tt_user_company_permission.ucp_prevent_orders_price_ticks,
      tt_user_company_permission.ucp_enforce_price_limit_on_buysell_only,
      tt_user_company_permission.ucp_prevent_orders_based_on_rate,
      tt_user_company_permission.ucp_prevent_orders_rate,
      tt_user_company_permission.ucp_gtc_orders_allowed,
      tt_user_company_permission.ucp_persist_orders_on_eurex,
      tt_user_company_permission.ucp_undefined_accounts_allowed,
      tt_user_company_permission.ucp_account_changes_allowed,
      tt_user_company_permission.ucp_wholesale_orders_with_undefined_accounts_allowed
)

--$private_get_order_rate_overrides_by_exchange_id
SELECT
    tt_user_gmgt.uxg_user_id as [user_id],
    tt_gmgt.gm_gateway_id as [gateway_id],
    min( tt_user_gmgt.uxg_max_orders_per_second ) as [order_rate],
    tt_mgt.mgt_comp_id as [broker_id]
FROM (( tt_user_gmgt
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id )
INNER JOIN tt_mgt ON tt_gmgt.gm_trader = tt_mgt.mgt_trader AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_member = tt_mgt.mgt_member
WHERE tt_user_gmgt.uxg_max_orders_per_second_on = CByte(1)
    AND tt_user_gmgt.uxg_max_orders_per_second <> 0
    AND ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
    AND tt_gmgt.gm_gateway_id = ?
GROUP BY
    tt_user_gmgt.uxg_user_id,
    tt_gmgt.gm_gateway_id,
    tt_mgt.mgt_comp_id

--$private_get_order_rate_overrides_by_exchange_id_list
SELECT
    tt_user_gmgt.uxg_user_id as [user_id],
    tt_gmgt.gm_gateway_id as [gateway_id],
    min( tt_user_gmgt.uxg_max_orders_per_second ) as [order_rate],
    tt_mgt.mgt_comp_id as [broker_id]
FROM (( tt_user_gmgt
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_user ON tt_user_gmgt.uxg_user_id = tt_user.user_id )
INNER JOIN tt_mgt ON tt_gmgt.gm_trader = tt_mgt.mgt_trader AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_member = tt_mgt.mgt_member
WHERE tt_user_gmgt.uxg_max_orders_per_second_on = CByte(1)
    AND tt_user_gmgt.uxg_max_orders_per_second <> 0
    AND ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
    AND tt_gmgt.gm_gateway_id in ('??')
GROUP BY
    tt_user_gmgt.uxg_user_id,
    tt_gmgt.gm_gateway_id,
    tt_mgt.mgt_comp_id

--$private_get_markets_with_product_groups
SELECT
    mkpg_market_id as [market_id]
FROM
    tt_market_product_group
GROUP BY
    mkpg_market_id

--$private_get_users_and_company_relationships
SELECT
    tt_user.user_id,
    tt_user_company_permission.ucp_comp_id as [broker_id]
FROM tt_user
INNER JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id
WHERE CByte( 1 ) = ( select lss_multibroker_mode from tt_login_server_settings )

--$private_get_user_ids
SELECT tt_user.user_id
FROM tt_user
WHERE CByte( 0 ) = ( select lss_multibroker_mode from tt_login_server_settings )

--$get_other_company_ttord_members_bycompany,1
SELECT mgt_member FROM tt_mgt WHERE LEFT( mgt_member, 5 ) = 'TTORD' AND mgt_comp_id <> ? GROUP BY mgt_member

--$private_get_count_of_sms_2fa_users
SELECT COUNT(*)
FROM tt_user
WHERE 2 = user_2fa_required_mode

--$private_get_count_of_email_2fa_users
SELECT COUNT(*)
FROM tt_user
WHERE 1 = user_2fa_required_mode

--$private_get_count_of_sms_2fa_users_mb
SELECT COUNT(*)
FROM tt_user
INNER JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id
WHERE 2 = tt_user_company_permission.ucp_2fa_required_mode

--$private_get_count_of_email_2fa_users_mb
SELECT COUNT(*)
FROM tt_user
INNER JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id
WHERE 1 = tt_user_company_permission.ucp_2fa_required_mode

--$private_sync_user_group_and_company_names
UPDATE tt_user_group
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
SET tt_user_group.ugrp_name = tt_company.comp_name
WHERE tt_user_group.ugrp_comp_id <> 0
    AND tt_user_group.ugrp_name <> tt_company.comp_name

--$private_get_enforceable_bvmf_gateway_login_count
SELECT COUNT(*) as [num]
FROM ((( tt_user
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id
WHERE tt_user.user_id = ?
    AND tt_market.market_name = 'BVMF'
    AND tt_user_gmgt.uxg_available_to_user = CByte(1)
    AND tt_user.user_fix_adapter_role = 0
    AND tt_user.user_password_never_expires = CByte(0)

--$private_get_markets_requiring_subscription_agreements
SELECT
    market.market_id,
    market.market_name
FROM tt_market [market]
INNER JOIN tt_market_product_group [mkpg] ON market.market_id = mkpg.mkpg_market_id
WHERE mkpg.mkpg_requires_subscription_agreement
GROUP BY
    market.market_id,
    market.market_name
ORDER BY
    market.market_name

--$private_get_cme_epgs_requiring_subscription_agreements
SELECT
    mkpg_market_product_group_id,
    mkpg_market_id,
    mkpg_product_group,
    mkpg_product_group_id
FROM tt_market_product_group
WHERE CByte( 1 ) = mkpg_requires_subscription_agreement
    AND mkpg_market_id = 7

--$private_get_ice_epgs_requiring_subscription_agreements
SELECT
    mkpg_market_product_group_id,
    mkpg_market_id,
    mkpg_product_group,
    mkpg_product_group_id
FROM tt_market_product_group
WHERE CByte( 1 ) = mkpg_requires_subscription_agreement
   AND mkpg_market_id = 32

--$private_get_bvmf_epgs_requiring_subscription_agreements
SELECT
    mkpg_market_product_group_id,
    mkpg_market_id,
    mkpg_product_group,
    mkpg_product_group_id
FROM tt_market_product_group
WHERE CByte( 1 ) = mkpg_requires_subscription_agreement
   AND mkpg_market_id = 90

--$private_get_sfe_epgs_requiring_subscription_agreements
SELECT
    mkpg_market_product_group_id,
    mkpg_market_id,
    mkpg_product_group,
    mkpg_product_group_id
FROM tt_market_product_group
WHERE CByte( 1 ) = mkpg_requires_subscription_agreement
   AND mkpg_market_id = 24

--$private_get_all_epgs_requiring_subscription_agreements
SELECT
    mkpg_market_product_group_id,
    mkpg_market_id,
    mkpg_product_group,
    mkpg_product_group_id
FROM tt_market_product_group
WHERE CByte( 1 ) = mkpg_requires_subscription_agreement

--$private_get_user_epgs_subscription_agreements
SELECT
    umsa_market_product_group_id
FROM tt_user_mpg_sub_agreement
WHERE umsa_user_id = ?

--$private_does_user_have_unsigned_subscription_agreements
SELECT
    IIF( 0 < COUNT( IIF( umsa.umsa_user_id IS NULL, 1, 0 ) ), CByte( 1 ), CByte( 0 ) ) AS [unsigned_count]
FROM ( tt_user_product_group AS [upg]
INNER JOIN tt_market_product_group AS [mkpg] ON upg.upg_market_product_group_id = mkpg.mkpg_market_product_group_id )
LEFT JOIN tt_user_mpg_sub_agreement AS [umsa] ON upg.upg_user_id = umsa.umsa_user_id
    AND upg.upg_market_product_group_id = umsa.umsa_market_product_group_id
WHERE upg.upg_user_id = ?

--$private_get_mkpgs_by_user_id
SELECT DISTINCT
    upg_comp_id,
    upg_market_product_group_id
FROM tt_user_product_group
WHERE upg_user_id = ?


--$private_get_mb_compids_for_user_id_with_cme_gateway_logins
SELECT
    ucp.ucp_comp_id AS [comp_id],
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_cbot, CByte( 0 ) ) ) AS [user_netting_cbot],
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_cme, CByte( 0 ) ) ) AS [user_netting_cme],
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_cme_europe, CByte( 0 ) ) ) AS [user_netting_cme_europe],
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_comex, CByte( 0 ) ) ) AS [user_netting_comex],
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_nymex, CByte( 0 ) ) ) AS [user_netting_nymex],
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_dme, CByte( 0 ) ) ) AS [user_netting_dme]
FROM (((((( tt_user
INNER JOIN tt_user_company_permission AS [ucp] ON tt_user.user_id = ucp.ucp_user_id )
INNER JOIN tt_user_gmgt AS [uxg] ON ucp.ucp_user_id = uxg.uxg_user_id )
INNER JOIN tt_gmgt ON uxg.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_mgt ON ( ucp.ucp_comp_id = tt_mgt.mgt_comp_id OR tt_mgt.mgt_comp_id = 0 ) AND ( tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader ) )
LEFT JOIN tt_netting_organization AS [no] ON tt_user.user_netting_organization_id = [no].no_id )
WHERE tt_user.user_fix_adapter_role = 0
    AND uxg.uxg_available_to_user = CByte( 1 )
    AND tt_gateway.gateway_market_id = 7
    AND tt_user.user_id = ?
GROUP BY
    ucp.ucp_comp_id,
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_cbot, CByte( 0 ) ) ),
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_cme, CByte( 0 ) ) ),
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_cme_europe, CByte( 0 ) ) ),
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_comex, CByte( 0 ) ) ),
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_nymex, CByte( 0 ) ) ),
    CByte( IIF( [no].no_tt_approved = CByte( 1 ), tt_user.user_netting_dme, CByte( 0 ) ) )


--$private_get_mb_compids_for_user_id_with_ice_gateway_logins
SELECT
    ucp.ucp_comp_id AS [comp_id]
FROM ((((( tt_user
INNER JOIN tt_user_company_permission AS [ucp] ON tt_user.user_id = ucp.ucp_user_id )
INNER JOIN tt_user_gmgt AS [uxg] ON ucp.ucp_user_id = uxg.uxg_user_id )
INNER JOIN tt_gmgt ON uxg.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_mgt ON ( ucp.ucp_comp_id = tt_mgt.mgt_comp_id OR tt_mgt.mgt_comp_id = 0 ) AND ( tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader ) )
WHERE tt_user.user_fix_adapter_role = 0
    AND uxg.uxg_available_to_user = CByte( 1 )
    AND tt_gateway.gateway_market_id = 32
    AND tt_user.user_id = ?

--$private_get_mb_compids_for_user_id_with_bvmf_gateway_logins
SELECT
    ucp.ucp_comp_id AS [comp_id]
FROM ((((( tt_user 
INNER JOIN tt_user_company_permission AS [ucp] ON tt_user.user_id = ucp.ucp_user_id )
INNER JOIN tt_user_gmgt AS [uxg] ON ucp.ucp_user_id = uxg.uxg_user_id )
INNER JOIN tt_gmgt ON uxg.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_mgt ON ( ucp.ucp_comp_id = tt_mgt.mgt_comp_id OR tt_mgt.mgt_comp_id = 0 ) AND ( tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader ) )
WHERE tt_user.user_fix_adapter_role = 0
    AND uxg.uxg_available_to_user = CByte( 1 )
    AND tt_gateway.gateway_market_id = 90
    AND tt_user.user_id = ?

--$private_get_mb_compids_for_user_id_with_sfe_gateway_logins
SELECT
    ucp.ucp_comp_id AS [comp_id]
FROM ((((( tt_user
INNER JOIN tt_user_company_permission AS [ucp] ON tt_user.user_id = ucp.ucp_user_id )
INNER JOIN tt_user_gmgt AS [uxg] ON ucp.ucp_user_id = uxg.uxg_user_id )
INNER JOIN tt_gmgt ON uxg.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_mgt ON ( ucp.ucp_comp_id = tt_mgt.mgt_comp_id OR tt_mgt.mgt_comp_id = 0 ) AND ( tt_gmgt.gm_member = tt_mgt.mgt_member AND tt_gmgt.gm_group = tt_mgt.mgt_group AND tt_gmgt.gm_trader = tt_mgt.mgt_trader ) )
WHERE tt_user.user_fix_adapter_role = 0
    AND uxg.uxg_available_to_user = CByte( 1 )
    AND tt_gateway.gateway_market_id = 24
    AND tt_user.user_id = ?

--$private_get_mb_mkpg_ids_for_user_id
SELECT
    ucp.ucp_comp_id AS [comp_id],
    mkpg.mkpg_product_group_id
FROM ((( tt_user
INNER JOIN tt_user_company_permission AS [ucp] ON tt_user.user_id = ucp.ucp_user_id )
INNER JOIN tt_user_product_group AS [upg] ON ( tt_user.user_id = upg.upg_user_id ) AND ( ucp.ucp_comp_id = upg.upg_comp_id ) )
INNER JOIN tt_market_product_group AS [mkpg] ON upg.upg_market_product_group_id = mkpg.mkpg_market_product_group_id )
WHERE mkpg.mkpg_market_id = 7
    AND mkpg.mkpg_product_group_id IN ( 2, 3, 4, 5, 8, 12, 15 )
    AND tt_user.user_id = ?
GROUP BY
    ucp.ucp_comp_id,
    mkpg.mkpg_product_group_id
