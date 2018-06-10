update tt_db_version set dbv_version = 'converting to 7.17.40'
go


alter table tt_user add user_can_submit_iceberg_orders byte not null
go

alter table tt_user add user_can_submit_time_sliced_orders byte not null
go

alter table tt_user add user_can_submit_volume_sliced_orders byte not null
go

alter table tt_user add user_can_submit_time_duration_orders byte not null
go

alter table tt_user add user_can_submit_volume_duration_orders byte not null
go

update tt_user set
    user_can_submit_iceberg_orders = CByte(1),
    user_can_submit_time_sliced_orders = CByte(1),
    user_can_submit_volume_sliced_orders = CByte(1),
    user_can_submit_time_duration_orders = CByte(1),
    user_can_submit_volume_duration_orders = CByte(1)
go


alter table tt_user_company_permission add ucp_can_submit_iceberg_orders byte not null
go

alter table tt_user_company_permission add ucp_can_submit_time_sliced_orders byte not null
go

alter table tt_user_company_permission add ucp_can_submit_volume_sliced_orders byte not null
go

alter table tt_user_company_permission add ucp_can_submit_time_duration_orders byte not null
go

alter table tt_user_company_permission add ucp_can_submit_volume_duration_orders byte not null
go

alter table tt_user_company_permission add ucp_machine_gun_orders_allowed byte not null
go

update tt_user_company_permission set
    ucp_can_submit_iceberg_orders = CByte(1),
    ucp_can_submit_time_sliced_orders = CByte(1),
    ucp_can_submit_volume_sliced_orders = CByte(1),
    ucp_can_submit_time_duration_orders = CByte(1),
    ucp_can_submit_volume_duration_orders = CByte(1),
    ucp_machine_gun_orders_allowed = CByte(1)
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
    a.user_status,
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
        tt_user.user_status,
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

DELETE FROM tt_market_product_group WHERE mkpg_market_id IN ( SELECT market_id FROM tt_market WHERE market_name IN ( 'Xetra', 'NYSE_Liffe_US' ) )
go

ALTER TABLE tt_user_gmgt ADD uxg_market_orders int not null default 0
go

UPDATE tt_user_gmgt SET uxg_market_orders = 0
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
    tt_user_gmgt.uxg_operator_id,
    tt_user_gmgt.uxg_max_orders_per_second_on,
    tt_user_gmgt.uxg_max_orders_per_second,
    tt_user_gmgt.uxg_market_orders
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

DROP VIEW tt_view_max_x_trader_user_date
go
CREATE VIEW tt_view_max_x_trader_user_date AS
SELECT tt_ip_address_version.ipv_user_login,
Max(tt_ip_address_version.ipv_last_updated_datetime) AS ipv_last_datetime
FROM tt_ip_address_version
WHERE tt_ip_address_version.ipv_user_login <> '' 
and tt_ip_address_version.ipv_tt_product_id in (8,30) 
and tt_ip_address_version.ipv_gateway_id = 0
GROUP BY tt_ip_address_version.ipv_user_login;
go


ALTER TABLE tt_product_limit add plim_outright_apply_during_non_matching_states_on byte default 0 not null
go

ALTER TABLE tt_product_limit add plim_spread_apply_during_non_matching_states_on byte default 0 not null
go

ALTER TABLE tt_product_limit add plim_outright_reject_orders_when_no_market_data_on byte default 0 not null
go

ALTER TABLE tt_product_limit add plim_spread_reject_orders_when_no_market_data_on byte default 0 not null
go


UPDATE tt_product_limit SET
    plim_outright_apply_during_non_matching_states_on = 0,
    plim_spread_apply_during_non_matching_states_on = 0,
    plim_outright_reject_orders_when_no_market_data_on = 0,
    plim_spread_reject_orders_when_no_market_data_on = 0
go

ALTER TABLE tt_login_server_settings ALTER COLUMN lss_2fa_on int
go

ALTER TABLE tt_login_server_settings ADD lss_2fa_state int not null default 0
go

UPDATE tt_login_server_settings SET lss_2fa_state = lss_2fa_on
go

ALTER TABLE tt_login_server_settings DROP COLUMN lss_2fa_on
go

ALTER TABLE tt_user ADD user_sms_number VARCHAR(64) NOT NULL DEFAULT ''
go

UPDATE tt_user SET user_sms_number = ''
go

CREATE TABLE temp_cd ( id int not null )
go

INSERT INTO temp_cd ( id )
SELECT MIN( cusd_id )
FROM tt_customer_default
GROUP BY cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_type, cusd_product
HAVING COUNT(*) > 1
go

DELETE FROM tt_customer_default
WHERE cusd_id IN
(
    SELECT id FROM temp_cd
)
go

DROP TABLE temp_cd
go

UPDATE tt_customer_default
SET cusd_product_in_hex = '2A'
WHERE cusd_product = '*'
    AND cusd_product_in_hex = ''
go

UPDATE tt_user
SET user_allow_trading = CByte(1)
WHERE user_id IN
(
    SELECT
        tt_user.user_id
    FROM ( tt_user
    INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
    INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
    WHERE
        tt_company.comp_is_broker = CByte(1) AND
        tt_user.user_allow_trading = CByte(0) AND
        1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
)
go

UPDATE tt_market_product_group
SET mkpg_product_group = 'ICE Futures Canada'
WHERE mkpg_market_id = 32
    AND mkpg_product_group_id = 2
go

UPDATE tt_market_product_group
SET mkpg_product_group = 'ICE Phys Env'
WHERE mkpg_market_id = 32
    AND mkpg_product_group_id = 3
go

UPDATE tt_market_product_group
SET mkpg_product_group = 'IFUS Energy Div Gas'
WHERE mkpg_market_id = 32
    AND mkpg_product_group_id = 4
go

UPDATE tt_market_product_group
SET mkpg_product_group = 'IFEU Energy Div Oil'
WHERE mkpg_market_id = 32
    AND mkpg_product_group_id = 5
go

UPDATE tt_market_product_group
SET mkpg_product_group = 'IFUS Energy Div Pwr'
WHERE mkpg_market_id = 32
    AND mkpg_product_group_id = 6
go

UPDATE tt_market_product_group
SET mkpg_product_group = 'IFEU Commodities'
WHERE mkpg_market_id = 32
    AND mkpg_product_group_id = 7
go

UPDATE tt_market_product_group
SET mkpg_product_group = 'ICE Futures U.S.'
WHERE mkpg_market_id = 32
    AND mkpg_product_group_id = 8
go

DELETE FROM tt_user_product_group
WHERE upg_user_product_group_id IN
(
    SELECT
        usFutUPG.upg_user_product_group_id
    FROM ( tt_user_product_group [usFutUPG]
    INNER JOIN tt_market_product_group [usFutMPG] ON usFutUPG.upg_market_product_group_id = usFutMPG.mkpg_market_product_group_id )
    LEFT JOIN
    (
        SELECT
            upg.upg_comp_id,
            upg.upg_user_id
        FROM tt_user_product_group [upg]
        INNER JOIN tt_market_product_group [mpg] on upg.upg_market_product_group_id = mpg.mkpg_market_product_group_id
        WHERE
            mpg.mkpg_market_id = 32 AND
            mpg.mkpg_product_group_id = 9
    ) [usIndUPG] ON usFutUPG.upg_user_id = usIndUPG.upg_user_id AND usFutUPG.upg_comp_id = usIndUPG.upg_comp_id
    WHERE
        usFutMPG.mkpg_market_id = 32 AND
        usFutMPG.mkpg_product_group_id = 8 AND
        usIndUPG.upg_comp_id IS NULL AND
        1 = ( SELECT COUNT(*) FROM tt_market_product_group WHERE mkpg_market_id = 32 AND mkpg_product_group_id = 9 )
)
go


DELETE FROM tt_user_product_group
WHERE upg_user_product_group_id IN
(
    SELECT
        s2fGasUPG.upg_user_product_group_id
    FROM ( tt_user_product_group [s2fGasUPG]
    INNER JOIN tt_market_product_group [s2fGasMPG] ON s2fGasUPG.upg_market_product_group_id = s2fGasMPG.mkpg_market_product_group_id )
    LEFT JOIN
    (
        SELECT
            upg.upg_comp_id,
            upg.upg_user_id
        FROM tt_user_product_group [upg]
        INNER JOIN tt_market_product_group [mpg] on upg.upg_market_product_group_id = mpg.mkpg_market_product_group_id
        WHERE
            mpg.mkpg_market_id = 32 AND
            mpg.mkpg_product_group_id = 10
    ) [heatUPG] ON s2fGasUPG.upg_user_id = heatUPG.upg_user_id AND s2fGasUPG.upg_comp_id = heatUPG.upg_comp_id
    WHERE
        s2fGasMPG.mkpg_market_id = 32 AND
        s2fGasMPG.mkpg_product_group_id = 4 AND
        heatUPG.upg_comp_id IS NULL AND
        1 = ( SELECT COUNT(*) FROM tt_market_product_group WHERE mkpg_market_id = 32 AND mkpg_product_group_id = 10 )
)
go

DELETE FROM tt_market_product_group WHERE mkpg_market_id = 32 AND mkpg_product_group_id = 9
go

DELETE FROM tt_market_product_group WHERE mkpg_market_id = 32 AND mkpg_product_group_id = 10
go

INSERT INTO tt_market_product_group
    ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id,
      mkpg_product_group_id, mkpg_product_group )
    SELECT now, 0, now, 0, 32, 11, 'IFEU Financials'
    FROM tt_login_server_settings
    WHERE 0 =
    (
        SELECT COUNT(*)
        FROM tt_market_product_group
        WHERE mkpg_market_id = 32 AND mkpg_product_group_id = 11
    )
go

INSERT INTO tt_market_product_group
    ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id,
      mkpg_product_group_id, mkpg_product_group )
    SELECT now, 0, now, 0, 32, 12, 'ICE Endex'
    FROM tt_login_server_settings
    WHERE 0 =
    (
        SELECT COUNT(*)
        FROM tt_market_product_group
        WHERE mkpg_market_id = 32 AND mkpg_product_group_id = 12
    )
go

INSERT INTO tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
SELECT now, 1, now, 1, c.ucp_user_id, c.ucp_comp_id, c.mkpg_market_product_group_id
FROM
(
    SELECT a.ucp_user_id, a.ucp_comp_id, b.mkpg_market_product_group_id
    FROM
    (
        SELECT ucp.ucp_user_id, ucp.ucp_comp_id
        FROM (( tt_user_company_permission [ucp]
        INNER JOIN tt_user ON ucp.ucp_user_id = tt_user.user_id )
        INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
        INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
        WHERE CByte(1) = ( select lss_multibroker_mode from tt_login_server_settings)
            AND tt_company.comp_is_broker = CByte(0)
            AND tt_company.comp_id <> 0
    )  AS a, (SELECT mkpg_market_product_group_id
        FROM tt_market_product_group
        WHERE mkpg_market_id = 32 AND mkpg_product_group_id = 11
    )  AS b
) c
LEFT JOIN tt_user_product_group [upg] ON c.ucp_user_id = upg.upg_user_id AND c.ucp_comp_id = upg.upg_comp_id AND c.mkpg_market_product_group_id = upg.upg_market_product_group_id
WHERE upg.upg_user_id IS NULL
go

INSERT INTO tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
SELECT now, 1, now, 1, c.ucp_user_id, c.ucp_comp_id, c.mkpg_market_product_group_id
FROM
(
    SELECT a.ucp_user_id, a.ucp_comp_id, b.mkpg_market_product_group_id
    FROM
    (
        SELECT ucp.ucp_user_id, ucp.ucp_comp_id
        FROM (( tt_user_company_permission [ucp]
        INNER JOIN tt_user ON ucp.ucp_user_id = tt_user.user_id )
        INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
        INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
        WHERE CByte(1) = ( select lss_multibroker_mode from tt_login_server_settings)
            AND tt_company.comp_is_broker = CByte(0)
            AND tt_company.comp_id <> 0
    )  AS a, (SELECT mkpg_market_product_group_id
        FROM tt_market_product_group
        WHERE mkpg_market_id = 32 AND mkpg_product_group_id = 12
    )  AS b
) c
LEFT JOIN tt_user_product_group [upg] ON c.ucp_user_id = upg.upg_user_id AND c.ucp_comp_id = upg.upg_comp_id AND c.mkpg_market_product_group_id = upg.upg_market_product_group_id
WHERE upg.upg_user_id IS NULL
go

INSERT INTO tt_x_trader_mode ( x_trader_mode_id, x_trader_mode_name )
SELECT 1, 'X_TRADER'
from tt_login_server_settings
WHERE 0 = ( SELECT COUNT( x_trader_mode_id ) FROM tt_x_trader_mode WHERE x_trader_mode_id = 1 )
go


UPDATE tt_user_group
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
SET tt_user_group.ugrp_name = tt_company.comp_name
WHERE tt_user_group.ugrp_comp_id <> 0
    AND tt_user_group.ugrp_name <> tt_company.comp_name
go

UPDATE tt_user_group
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
SET tt_user_group.ugrp_name = tt_company.comp_name
WHERE tt_user_group.ugrp_comp_id <> 0
    AND tt_user_group.ugrp_name <> tt_company.comp_name
go

UPDATE tt_user_group
INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
SET tt_user_group.ugrp_name = tt_company.comp_name
WHERE tt_user_group.ugrp_comp_id <> 0
    AND tt_user_group.ugrp_name <> tt_company.comp_name
go


--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.040.000'
go
