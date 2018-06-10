update tt_db_version set dbv_version = 'converting to 7.17.24'
go

DELETE FROM tt_market WHERE market_id = 4
go

INSERT INTO tt_market ( market_id, market_name )
SELECT 99, 'LSE'
FROM
(
    SELECT count(*) as [cnt]
    FROM tt_market
    WHERE market_id = 99
) a where a.cnt = 0
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 99, 69, 'LSE Derivatives'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 99 AND mkpg_product_group_id = 69 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 99, 79, 'Oslo Bors'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 99 AND mkpg_product_group_id = 79 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 99, 73, 'IDEM'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 99 AND mkpg_product_group_id = 73 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 99, 90, 'IDEX'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 99 AND mkpg_product_group_id = 90 )
go

DELETE FROM tt_user_product_group
WHERE upg_market_product_group_id IN
(
    SELECT mkpg_market_product_group_id
    FROM tt_market_product_group
    WHERE mkpg_market_id = 99
        AND CByte(1) = ( select lss_multibroker_mode from tt_login_server_settings )
)
go

INSERT INTO tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
SELECT Now() AS Expr1, 1 AS Expr2, Now() AS Expr3, 1 AS Expr4, a.ucp_user_id, a.ucp_comp_id, b.mkpg_market_product_group_id
FROM (SELECT ucp.ucp_user_id, ucp.ucp_comp_id
    FROM (( tt_user_company_permission [ucp]
    INNER JOIN tt_user ON ucp.ucp_user_id = tt_user.user_id )
    INNER JOIN tt_user_group ON tt_user.user_group_id = tt_user_group.ugrp_group_id )
    INNER JOIN tt_company ON tt_user_group.ugrp_comp_id = tt_company.comp_id
    WHERE CByte(1) = ( select lss_multibroker_mode from tt_login_server_settings)
        AND tt_company.comp_is_broker = CByte(0)
        AND tt_company.comp_id <> 0
)  AS a, (SELECT mkpg_market_product_group_id
    FROM tt_market_product_group
    WHERE mkpg_market_id = 99
)  AS b
go

CREATE TABLE tmpAvailableUserGmgts
(
    user_id int not null,
    gm_gateway_id int not null,
    gmgt_id int not null
)
go

CREATE TABLE tmpUnavailableUserGmgts
(
    user_id int not null,
    gm_gateway_id int not null,
    gmgt_id int not null
)
go

INSERT INTO tmpAvailableUserGmgts
SELECT
    tt_user.user_id,
    tt_gmgt.gm_gateway_id,
    max( tt_gmgt.gm_id ) as gmgt_id
FROM ( tt_user
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id
WHERE ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
    AND tt_gmgt.gm_member <> 'TTADM'
    AND tt_gmgt.gm_group <> 'XXX'
    AND tt_gmgt.gm_trader NOT IN ( 'MGR', 'VIEW' )
GROUP BY
    tt_user.user_id,
    tt_gmgt.gm_gateway_id
go

INSERT INTO tmpUnavailableUserGmgts
SELECT
    tt_user.user_id,
    tt_gmgt.gm_gateway_id,
    max( tt_gmgt.gm_id ) as gmgt_id
FROM ( tt_user
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id
WHERE false = ( tt_user_gmgt.uxg_available_to_user = 1 OR ( tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1 ) )
    AND tt_gmgt.gm_member <> 'TTADM'
    AND tt_gmgt.gm_group <> 'XXX'
    AND tt_gmgt.gm_trader NOT IN ( 'MGR', 'VIEW' )
GROUP BY
    tt_user.user_id,
    tt_gmgt.gm_gateway_id
go

UPDATE tt_customer_default
INNER JOIN tmpAvailableUserGmgts gmgts ON tt_customer_default.cusd_user_id = gmgts.user_id AND tt_customer_default.cusd_gateway_id = gmgts.gm_gateway_id
SET tt_customer_default.cusd_default_gmgt_id = gmgts.gmgt_id
WHERE tt_customer_default.cusd_default_gmgt_id = 0
go

UPDATE tt_customer_default
INNER JOIN tmpUnavailableUserGmgts gmgts ON tt_customer_default.cusd_user_id = gmgts.user_id AND tt_customer_default.cusd_gateway_id = gmgts.gm_gateway_id
SET tt_customer_default.cusd_default_gmgt_id = gmgts.gmgt_id
WHERE tt_customer_default.cusd_default_gmgt_id = 0
go

DROP TABLE tmpAvailableUserGmgts
go

DROP TABLE tmpUnavailableUserGmgts
go

DROP VIEW tt_view_user_product_groups_for_cme
go

CREATE VIEW tt_view_user_product_groups_for_cme AS
SELECT
    sub1.mkpg_product_group,
    a.user_login,
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

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.024.000'
go
