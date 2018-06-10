update tt_db_version set dbv_version = 'converting to 7.17.30'
go

INSERT INTO tt_market_product_group ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id, mkpg_product_group_id, mkpg_product_group )
    VALUES ( now, 0, now, 0, 7, 15, 'CME Europe' )
go

ALTER TABLE tt_company ALTER COLUMN comp_name VARCHAR(64) NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_2fa_on BYTE NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_2fa_trust_days INT NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_2fa_expire_mins INT NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_2fa_problem_contact VARCHAR(128) NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_host VARCHAR(128) NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_port INT NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_auth_on BYTE NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_auth_account VARCHAR(128) NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_auth_password VARCHAR(128) NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_ssl_on BYTE NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_from_address VARCHAR(128) NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_from_name VARCHAR(128) NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_subject VARCHAR(128) NOT NULL
go

ALTER TABLE tt_login_server_settings ADD lss_smtp_additional_message VARCHAR(255) NOT NULL
go

UPDATE tt_login_server_settings
    SET lss_2fa_on = CByte(0),
        lss_2fa_trust_days = 30,
        lss_2fa_expire_mins = 10,
        lss_2fa_problem_contact = '',
        lss_smtp_host = '',
        lss_smtp_port = 25,
        lss_smtp_auth_on = CByte(0),
        lss_smtp_auth_account = '',
        lss_smtp_auth_password = '',
        lss_smtp_ssl_on = CByte(0),
        lss_smtp_from_address = '',
        lss_smtp_from_name = '',
        lss_smtp_subject = 'Two-factor Authentication Required',
        lss_smtp_additional_message = ''
go

ALTER TABLE tt_user ADD user_2fa_required BYTE NOT NULL
go

UPDATE tt_user
    SET user_2fa_required = CByte(0)
go

ALTER TABLE tt_user_company_permission ADD ucp_2fa_required BYTE NOT NULL
go

UPDATE tt_user_company_permission
    SET ucp_2fa_required = CByte(0)
go

ALTER TABLE tt_user ADD user_xtapi_allowed BYTE NOT NULL
go

ALTER TABLE tt_user ADD user_autotrader_allowed BYTE NOT NULL
go

ALTER TABLE tt_user ADD user_autospreader_allowed BYTE NOT NULL
go

UPDATE tt_user
    SET user_xtapi_allowed = CByte(1),
        user_autotrader_allowed = CByte(1),
        user_autospreader_allowed = CByte(1)
go

ALTER TABLE tt_user_company_permission ADD ucp_xtapi_allowed BYTE NOT NULL
go

ALTER TABLE tt_user_company_permission ADD ucp_autotrader_allowed BYTE NOT NULL
go

ALTER TABLE tt_user_company_permission ADD ucp_autospreader_allowed BYTE NOT NULL
go

UPDATE tt_user_company_permission
    SET ucp_xtapi_allowed = CByte(1),
        ucp_autotrader_allowed = CByte(1),
        ucp_autospreader_allowed = CByte(1)
go

ALTER TABLE tt_user_company_permission
    ADD ucp_can_manage_trader_based_product_limits BYTE NOT NULL
go

UPDATE tt_user_company_permission
    SET ucp_can_manage_trader_based_product_limits = CByte(0)
go

DROP VIEW tt_view_user_product_groups_for_cme
go
CREATE VIEW tt_view_user_product_groups_for_cme AS
SELECT
    sub1.mkpg_product_group,
    a.user_login,
    a.concurrent_logins,
    a.exch_member,
    a.user_display_name,
    a.user_address,
    a.user_city,
    a.user_id,
    a.user_postal_code,
    a.user_organization,
    a.user_def1,
    a.user_def2,
    a.user_def3,
    a.user_def4,
    a.user_def5,
    a.user_def6,
    a.ugrp_name,
    a.ugrp_group_id,
    a.country_code,
    a.country_name,
    a.state_abbrev,
    a.mgt_comp_id
FROM
(
    SELECT DISTINCT
        tt_user.user_login,
        IIF( CByte( 1 ) = ( SELECT lss_enforce_ip_login_limit FROM tt_login_server_settings ), IIF( CByte( 1 ) = tt_user.user_enforce_ip_login_limit, tt_user.user_ip_login_limit, -1 ), -1 ) AS [concurrent_logins],
        IIF (tt_mgt.mgt_type = 2 or tt_gmgt_1.gm_member = '<No','No Member ID (View Only)',tt_gmgt_1.gm_member) AS exch_member,
        tt_user.user_display_name,
        tt_user.user_address,
        tt_user.user_city,
        tt_user.user_id,
        tt_user.user_postal_code,
        tt_user.user_def1,
        tt_user.user_def2,
        tt_user.user_def3,
        tt_user.user_def4,
        tt_user.user_def5,
        tt_user.user_def6,
        iif( ucp.ucp_organization is null or ucp.ucp_organization = '', IIF( tt_company.comp_id <> 0, tt_company.comp_name, tt_user.user_organization ), ucp.ucp_organization ) as [user_organization],
        tt_user_group.ugrp_name,
        tt_user_group.ugrp_group_id,
        tt_country.country_code,
        tt_country.country_name,
        tt_us_state.state_abbrev,
        tt_mgt.mgt_comp_id
    FROM ((((((((((( tt_user
        INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
        INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
        INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
        INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
        INNER JOIN tt_country ON tt_user.user_country_id = tt_country.country_id )
        INNER JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id )
        INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
        INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member) )
        INNER JOIN tt_mgt_gmgt ON tt_mgt.mgt_id = tt_mgt_gmgt.mxg_mgt_id )
        INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_mgt_gmgt.mxg_gmgt_id = tt_gmgt_1.gm_id )
        INNER JOIN tt_gateway AS tt_gateway_1 ON tt_gmgt_1.gm_gateway_id = tt_gateway_1.gateway_id )
        LEFT JOIN tt_user_company_permission AS ucp ON tt_user.user_id = ucp.ucp_user_id
    WHERE
        tt_gateway.gateway_market_id = 7
        AND tt_gateway_1.gateway_market_id = 7
        AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))
        AND ( ucp.ucp_comp_id is null or ucp.ucp_comp_id = tt_mgt.mgt_comp_id )
) a
LEFT JOIN tt_view_user_product_groups_for_cme_sub AS sub1 ON a.user_id = sub1.upg_user_id AND a.mgt_comp_id = sub1.upg_comp_id
go

ALTER TABLE tt_user_company_permission ADD ucp_ob_passing_group_id INT NOT NULL
go

UPDATE tt_user_company_permission
    SET ucp_ob_passing_group_id = 0
go

CREATE TABLE tt_ob_passing_group
(
    obpg_id                               COUNTER        NOT NULL   PRIMARY KEY,
    obpg_created_datetime                 DATETIME       NOT NULL,
    obpg_created_user_id                  INT            NOT NULL,
    obpg_last_updated_datetime            DATETIME       NOT NULL,
    obpg_last_updated_user_id             INT            NOT NULL,
    obpg_group_name                       VARCHAR(100)   NOT NULL,
    obpg_owning_comp_id                   INT            NOT NULL,
    obpg_assigned_comp_id                 INT            NOT NULL,
    obpg_allow_ob_passing_to_all          BYTE           NOT NULL,
    obpg_show_accounts_on_passed_orders   BYTE           NOT NULL
)
go

ALTER TABLE tt_ob_passing_group
    ADD CONSTRAINT fk_ob_passing_group_to_owning_company
    FOREIGN KEY( obpg_owning_comp_id )
    REFERENCES tt_company ( comp_id )
    ON DELETE CASCADE
go

ALTER TABLE tt_ob_passing_group
    ADD CONSTRAINT fk_ob_passing_group_to_assigned_company
    FOREIGN KEY( obpg_owning_comp_id )
    REFERENCES tt_company ( comp_id )
    ON DELETE CASCADE
go


CREATE TABLE tt_ob_passing_mb
(
    ob_id counter not null primary key,
    ob_created_datetime datetime not null,
    ob_created_user_id int not null,
    ob_last_updated_datetime datetime not null,
    ob_last_updated_user_id int not null,
    ob_obpg_id int not null,
    ob_obpg_id_allowed int not null
)
go

ALTER TABLE tt_ob_passing_mb 
    ADD CONSTRAINT fk_ob_passing_to_obpg1
    FOREIGN KEY ( ob_obpg_id )
    REFERENCES tt_ob_passing_group ( obpg_id )
    ON DELETE CASCADE
go

ALTER TABLE tt_ob_passing_mb 
    ADD CONSTRAINT fk_ob_passing_to_obpg2
    FOREIGN KEY ( ob_obpg_id_allowed )
    REFERENCES tt_ob_passing_group ( obpg_id )
    ON DELETE CASCADE
go

CREATE UNIQUE INDEX unique_ob_passing_key_mb ON tt_ob_passing_mb ( ob_obpg_id, ob_obpg_id_allowed )
go

DROP VIEW tt_view_users_and_their_mgts1
go
CREATE VIEW tt_view_users_and_their_mgts1 AS
SELECT
    tt_user.user_login,
    tt_mgt.mgt_member,
    tt_mgt.mgt_group,
    tt_mgt.mgt_trader,
    tt_mgt.mgt_comp_id,
    tt_gateway.gateway_name,
    tt_user.user_display_name,
    IIF(tt_user.user_status=1,"Active","Inactive") AS status,
    tt_user_group.ugrp_group_id,
    tt_user_group.ugrp_name,
    tt_mgt.mgt_description,
    tt_mgt.mgt_risk_on,
    tt_mgt.mgt_allow_trading,
    tt_mgt.mgt_credit,
    tt_market.market_name,
    tt_user_gmgt.uxg_automatically_login,
    tt_user_gmgt.uxg_available_to_user,
    tt_user_gmgt.uxg_available_to_fix_adapter_user,
    tt_fix_adapter_role.far_description AS fa_role,
    tt_mgt.mgt_id,
    tt_gmgt.gm_gateway_id,
    tt_company.comp_id,
    tt_company.comp_name,
    tt_user.user_def1,
    tt_user.user_def2,
    tt_user.user_def3,
    tt_user.user_def4,
    tt_user.user_def5,
    tt_user.user_def6,
    tt_country.country_name,
    tt_user.user_address,
    tt_user.user_city,
    tt_us_state.state_long_name,
    tt_user.user_postal_code,
    tt_user.user_email,
    tt_user.user_id,
    tt_user_gmgt.uxg_exchange_data1,
    tt_user_gmgt.uxg_exchange_data2,
    tt_user_gmgt.uxg_exchange_data3,
    tt_user_gmgt.uxg_exchange_data4,
    tt_user_gmgt.uxg_exchange_data5,
    tt_user_gmgt.uxg_exchange_data6,
    tt_user_gmgt.uxg_operator_id
FROM (((((((((( tt_user
INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id )
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member) )
INNER JOIN tt_gateway ON tt_gmgt.gm_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id )
INNER JOIN tt_fix_adapter_role ON tt_user.user_fix_adapter_role = tt_fix_adapter_role.far_role_id )
INNER JOIN tt_country ON tt_user.user_country_id = tt_country.country_id )
INNER JOIN tt_us_state ON tt_user.user_state_id = tt_us_state.state_id );
go

UPDATE tt_customer_default
SET cusd_gateway_id = -1
WHERE cusd_gateway_id = 0
    AND cusd_id NOT IN
(
    SELECT cd1.cusd_id
    FROM tt_customer_default cd1
   INNER JOIN tt_customer_default cd2 ON
        cd1.cusd_user_id = cd2.cusd_user_id AND
        cd1.cusd_comp_id = cd2.cusd_comp_id AND
        cd1.cusd_customer = cd2.cusd_customer AND
        cd1.cusd_market_id = cd2.cusd_market_id AND
        cd1.cusd_product_in_hex = cd2.cusd_product_in_hex AND
        cd1.cusd_product_type = cd2.cusd_product_type
    WHERE cd1.cusd_gateway_id = 0 AND
        cd2.cusd_gateway_id = -1
)
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.030.000'
go
