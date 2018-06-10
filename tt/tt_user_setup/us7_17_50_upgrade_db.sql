update tt_db_version set dbv_version = 'converting to 7.17.50'
go

DROP VIEW tt_view_get_report_accts_cusd
go
CREATE VIEW tt_view_get_report_accts_cusd AS
SELECT DISTINCT tt_user.user_id,
tt_account.acct_id,
tt_account.acct_name,
tt_account.acct_comp_id
FROM tt_account 
INNER JOIN (tt_user 
INNER JOIN tt_customer_default ON (tt_user.user_id = tt_customer_default.cusd_user_id) AND (tt_customer_default.cusd_user_id = tt_user.user_id)) ON tt_account.acct_id = tt_customer_default.cusd_account_id
WHERE tt_customer_default.cusd_account_id > 1;
go

DROP VIEW tt_view_get_report_accts_mgt
go
CREATE VIEW tt_view_get_report_accts_mgt AS
SELECT DISTINCT tt_user.user_id,
tt_account.acct_id,
tt_account.acct_name,
tt_account.acct_comp_id
FROM tt_account 
INNER JOIN (tt_mgt 
INNER JOIN (tt_gmgt 
INNER JOIN (tt_user 
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id) ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)) ON tt_account.acct_mgt_id = tt_mgt.mgt_id;
go

DROP VIEW tt_view_get_report_accts_uxa
go
CREATE VIEW tt_view_get_report_accts_uxa AS
SELECT
    user_id,
    acct_id,
    acct_name,
    acct_comp_id
FROM
(
SELECT DISTINCT tt_user.user_id,
tt_account.acct_id,
tt_account.acct_name,
tt_account.acct_comp_id
FROM tt_account 
INNER JOIN (tt_user 
INNER JOIN tt_user_account ON tt_user.user_id = tt_user_account.uxa_user_id ) ON tt_account.acct_id = tt_user_account.uxa_account_id
WHERE CByte(1) = tt_user.user_account_permissions_enabled
    AND CByte(0) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )

UNION

SELECT DISTINCT tt_user.user_id,
tt_account.acct_id,
tt_account.acct_name,
tt_account.acct_comp_id
FROM ((( tt_account 
INNER JOIN tt_company ON tt_account.acct_comp_id = tt_company.comp_id )
INNER JOIN tt_user_account ON tt_account.acct_id = tt_user_account.uxa_account_id )
INNER JOIN tt_user ON tt_user_account.uxa_user_id = tt_user.user_id )
INNER JOIN tt_user_company_permission [ucp] ON ( tt_user.user_id = ucp.ucp_user_id ) AND ( tt_company.comp_id = ucp.ucp_comp_id )
WHERE CByte(1) = ucp.ucp_account_permissions_enabled
    AND CByte(1) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
)
go

DROP VIEW tt_view_get_report_accts_all
go
CREATE VIEW tt_view_get_report_accts_all AS
SELECT
    user_id,
    acct_id,
    acct_name,
    acct_comp_id
FROM
(
    SELECT * FROM tt_view_get_report_accts_cusd 
UNION
    SELECT * FROM tt_view_get_report_accts_mgt
UNION
    SELECT * FROM tt_view_get_report_accts_uxa
)
GROUP BY
    user_id,
    acct_id,
    acct_name,
    acct_comp_id
go

DROP VIEW tt_view_get_report_accts_cusd_or_uxa
go
CREATE VIEW tt_view_get_report_accts_cusd_or_uxa AS
SELECT
    user_id,
    acct_id,
    acct_name,
    acct_comp_id
FROM
(
    SELECT * FROM tt_view_get_report_accts_cusd 
UNION
    SELECT * FROM tt_view_get_report_accts_uxa
)
GROUP BY
    user_id,
    acct_id,
    acct_name,
    acct_comp_id
go

DROP VIEW tt_view_users_and_their_accounts
go
CREATE VIEW tt_view_users_and_their_accounts AS
SELECT tt_user.user_login AS Username,
tt_user.user_id,
tt_user.user_display_name AS [Display Name],
IIF(tt_user.user_status=1,"Active","Inactive") AS Status,
tt_user_group.ugrp_name AS [User Group],
tt_user_group.ugrp_group_id AS [User Group Id],
tt_view_get_report_accts_all.acct_name AS [All Accts],
tt_view_get_report_accts_mgt.acct_name AS [Gateway Login Accts (XT 7_DOT_12)],
tt_view_get_report_accts_all.acct_comp_id,
tt_view_get_report_accts_cusd.acct_name AS [Customer Default Accts],
tt_view_get_report_accts_uxa.acct_name AS [User Permissioned Accts],
tt_view_get_report_accts_all.acct_id
FROM tt_user_group 
INNER JOIN ((((tt_view_get_report_accts_all 
LEFT JOIN tt_view_get_report_accts_cusd ON (tt_view_get_report_accts_all.user_id = tt_view_get_report_accts_cusd.user_id) AND (tt_view_get_report_accts_all.acct_id = tt_view_get_report_accts_cusd.acct_id)) 
LEFT JOIN tt_view_get_report_accts_mgt ON (tt_view_get_report_accts_all.user_id = tt_view_get_report_accts_mgt.user_id) AND (tt_view_get_report_accts_all.acct_id = tt_view_get_report_accts_mgt.acct_id)) 
LEFT JOIN tt_view_get_report_accts_uxa ON (tt_view_get_report_accts_all.user_id = tt_view_get_report_accts_uxa.user_id) AND (tt_view_get_report_accts_all.acct_id = tt_view_get_report_accts_uxa.acct_id)) 
INNER JOIN tt_user ON tt_view_get_report_accts_all.user_id = tt_user.user_id) ON tt_user_group.ugrp_group_id = tt_user.user_group_id;
go

DROP VIEW tt_view_users_and_their_uxa_or_cusd_accounts
go
CREATE VIEW tt_view_users_and_their_uxa_or_cusd_accounts AS
SELECT
    tt_user.user_id,
    tt_view_get_report_accts_cusd_or_uxa.acct_name AS [All Accts],
    tt_view_get_report_accts_cusd_or_uxa.acct_comp_id,
    tt_view_get_report_accts_cusd_or_uxa.acct_id,
    tt_view_get_report_accts_cusd.acct_name AS [Customer Default Accts],
    tt_view_get_report_accts_uxa.acct_name AS [User Permissioned Accts]
FROM (( tt_view_get_report_accts_cusd_or_uxa 
LEFT JOIN tt_view_get_report_accts_cusd ON (tt_view_get_report_accts_cusd_or_uxa.user_id = tt_view_get_report_accts_cusd.user_id) AND (tt_view_get_report_accts_cusd_or_uxa.acct_id = tt_view_get_report_accts_cusd.acct_id)) 
LEFT JOIN tt_view_get_report_accts_uxa ON (tt_view_get_report_accts_cusd_or_uxa.user_id = tt_view_get_report_accts_uxa.user_id) AND (tt_view_get_report_accts_cusd_or_uxa.acct_id = tt_view_get_report_accts_uxa.acct_id)) 
INNER JOIN tt_user ON tt_view_get_report_accts_cusd_or_uxa.user_id = tt_user.user_id
go

ALTER TABLE tt_user ADD user_fa_category_id INT NOT NULL DEFAULT 0
go

UPDATE tt_user
SET user_fa_category_id = 0
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.050.000'
go
