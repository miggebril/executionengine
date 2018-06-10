update tt_db_version set dbv_version = 'converting to 7.17.41'
go

DELETE *
FROM tt_market_product_group
WHERE mkpg_market_id = 6
    AND CByte( 1 ) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
go

ALTER TABLE tt_market_product_group ADD mkpg_requires_subscription_agreement BYTE NOT NULL
go

UPDATE tt_market_product_group
SET mkpg_requires_subscription_agreement = CByte( 0 )
go

-- for now, all CME product groups require a subscription agreement
UPDATE tt_market_product_group
SET mkpg_requires_subscription_agreement = CByte( 1 )
WHERE mkpg_market_id = 7
go

CREATE TABLE tt_user_mpg_sub_agreement
(
    umsa_id                               COUNTER        NOT NULL   PRIMARY KEY,
    umsa_created_datetime                 DATETIME       NOT NULL,
    umsa_created_user_id                  INT            NOT NULL,
    umsa_last_updated_datetime            DATETIME       NOT NULL,
    umsa_last_updated_user_id             INT            NOT NULL,
    umsa_user_id                          INT            NOT NULL,
    umsa_market_product_group_id          INT            NOT NULL
)
go

ALTER TABLE tt_user_mpg_sub_agreement
    ADD CONSTRAINT fk_umsa_to_user
    FOREIGN KEY( umsa_user_id )
    REFERENCES tt_user ( user_id )
    ON DELETE CASCADE
go

ALTER TABLE tt_user_mpg_sub_agreement
    ADD CONSTRAINT fk_umsa_to_mpg
    FOREIGN KEY( umsa_market_product_group_id )
    REFERENCES tt_market_product_group ( mkpg_market_product_group_id )
    ON DELETE CASCADE
go

CREATE UNIQUE INDEX index_umpg_user_mpg ON tt_user_mpg_sub_agreement ( umsa_user_id, umsa_market_product_group_id )
go

INSERT INTO tt_user_setup_user_type ( utype_id, utype_description )
    VALUES ( 15, 'Market Data Billing Admin' )
go

alter table tt_user add user_gf_cbot byte not null
go

alter table tt_user add user_gf_cme byte not null
go

alter table tt_user add user_gf_cme_europe byte not null
go

alter table tt_user add user_gf_comex byte not null
go

alter table tt_user add user_gf_nymex byte not null
go

alter table tt_user add user_gf_dme byte not null
go

alter table tt_user add user_netting_cbot byte not null
go

alter table tt_user add user_netting_cme byte not null
go

alter table tt_user add user_netting_cme_europe byte not null
go

alter table tt_user add user_netting_comex byte not null
go

alter table tt_user add user_netting_nymex byte not null
go

alter table tt_user add user_netting_dme byte not null
go

alter table tt_user add user_netting_organization_id int not null
go

update tt_user set
    user_gf_cbot = CByte( 0 ),
    user_gf_cme = CByte( 0 ),
    user_gf_cme_europe = CByte( 0 ),
    user_gf_comex = CByte( 0 ),
    user_gf_nymex = CByte( 0 ),
    user_gf_dme = CByte( 0 ),
    user_netting_cbot = CByte( 0 ),
    user_netting_cme = CByte( 0 ),
    user_netting_cme_europe = CByte( 0 ),
    user_netting_comex = CByte( 0 ),
    user_netting_nymex = CByte( 0 ),
    user_netting_dme = CByte( 0 ),
    user_netting_organization_id = 0
go


alter table tt_user_company_permission add ucp_gf_cbot byte not null
go

alter table tt_user_company_permission add ucp_gf_cme byte not null
go

alter table tt_user_company_permission add ucp_gf_cme_europe byte not null
go

alter table tt_user_company_permission add ucp_gf_comex byte not null
go

alter table tt_user_company_permission add ucp_gf_nymex byte not null
go

alter table tt_user_company_permission add ucp_gf_dme byte not null
go

update tt_user_company_permission set
    ucp_gf_cbot = CByte( 0 ),
    ucp_gf_cme = CByte( 0 ),
    ucp_gf_cme_europe = CByte( 0 ),
    ucp_gf_comex = CByte( 0 ),
    ucp_gf_nymex = CByte( 0 ),
    ucp_gf_dme = CByte( 0 )
go

CREATE TABLE tt_netting_organization
(
    no_id                               COUNTER        NOT NULL   PRIMARY KEY,
    no_created_datetime                 DATETIME       NOT NULL,
    no_created_user_id                  INT            NOT NULL,
    no_last_updated_datetime            DATETIME       NOT NULL,
    no_last_updated_user_id             INT            NOT NULL,
    no_comp_id                          INT            NOT NULL,
    no_name                             VARCHAR(64)    NOT NULL,
    no_tt_approved                      BYTE           NOT NULL
)
go

ALTER TABLE tt_netting_organization
    ADD CONSTRAINT fk_no_to_company
    FOREIGN KEY( no_comp_id )
    REFERENCES tt_company ( comp_id )
    ON DELETE CASCADE
go

CREATE UNIQUE INDEX index_no_name_per_company ON tt_netting_organization ( no_comp_id, no_name )
go

UPDATE tt_login_server_settings
SET lss_enforce_ip_login_limit = CByte( 1 )
WHERE CByte( 1 ) = lss_multibroker_mode
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
    a.mgt_comp_id,
    a.user_netting_cbot,
    a.user_netting_cme,
    a.user_netting_cme_europe,
    a.user_netting_comex,
    a.user_netting_nymex,
    a.user_netting_dme,
    a.user_netting_organization,
    a.user_created_datetime,
    a.user_most_recent_login_datetime,
    a.user_gf_cbot,
    a.user_gf_cme,
    a.user_gf_cme_europe,
    a.user_gf_comex,
    a.user_gf_nymex,
    a.user_gf_dme,
    a.netting_org_approved
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
        IIF( ucp.ucp_id IS NULL, tt_mgt.mgt_comp_id, ucp.ucp_comp_id ) AS [mgt_comp_id],
        IIF( CByte( 1 ) = tt_netting_organization.no_tt_approved OR CByte( 0 ) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings ), IIF( CByte( 1 ) = tt_user.user_netting_cbot, 'Yes', 'No' ), 'No' ) AS [user_netting_cbot],
        IIF( CByte( 1 ) = tt_netting_organization.no_tt_approved OR CByte( 0 ) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings ), IIF( CByte( 1 ) = tt_user.user_netting_cme, 'Yes', 'No' ), 'No' ) AS [user_netting_cme],
        IIF( CByte( 1 ) = tt_netting_organization.no_tt_approved OR CByte( 0 ) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings ), IIF( CByte( 1 ) = tt_user.user_netting_cme_europe, 'Yes', 'No' ), 'No' ) AS [user_netting_cme_europe],
        IIF( CByte( 1 ) = tt_netting_organization.no_tt_approved OR CByte( 0 ) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings ), IIF( CByte( 1 ) = tt_user.user_netting_comex, 'Yes', 'No' ), 'No' ) AS [user_netting_comex],
        IIF( CByte( 1 ) = tt_netting_organization.no_tt_approved OR CByte( 0 ) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings ), IIF( CByte( 1 ) = tt_user.user_netting_nymex, 'Yes', 'No' ), 'No' ) AS [user_netting_nymex],
        IIF( CByte( 1 ) = tt_netting_organization.no_tt_approved OR CByte( 0 ) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings ), IIF( CByte( 1 ) = tt_user.user_netting_dme, 'Yes', 'No' ), 'No' ) AS [user_netting_dme],
        tt_netting_organization.no_name AS [user_netting_organization],
        IIF( CByte( 1 ) = tt_user.user_gf_cbot, 'Yes', 'No' ) AS [user_gf_cbot],
        IIF( CByte( 1 ) = tt_user.user_gf_cme, 'Yes', 'No' ) AS [user_gf_cme],
        IIF( CByte( 1 ) = tt_user.user_gf_cme_europe, 'Yes', 'No' ) AS [user_gf_cme_europe],
        IIF( CByte( 1 ) = tt_user.user_gf_comex, 'Yes', 'No' ) AS [user_gf_comex],
        IIF( CByte( 1 ) = tt_user.user_gf_nymex, 'Yes', 'No' ) AS [user_gf_nymex],
        IIF( CByte( 1 ) = tt_user.user_gf_dme, 'Yes', 'No' ) AS [user_gf_dme],
        tt_user.user_created_datetime,
        tt_user.user_most_recent_login_datetime,
        CByte( IIF( CByte( 1 ) = tt_netting_organization.no_tt_approved OR CByte( 0 ) = ( SELECT lss_multibroker_mode FROM tt_login_server_settings ), 1, 0 ) ) AS [netting_org_approved]
    FROM (((((((((((( tt_user
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
        LEFT JOIN tt_user_company_permission AS ucp ON tt_user.user_id = ucp.ucp_user_id )
        LEFT JOIN tt_netting_organization ON tt_user.user_netting_organization_id = tt_netting_organization.no_id
    WHERE
        tt_gateway.gateway_market_id = 7
        AND tt_gateway_1.gateway_market_id = 7
        AND (tt_user_gmgt.uxg_available_to_user = 1 OR (tt_user.user_fix_adapter_role = 1 AND tt_user_gmgt.uxg_available_to_fix_adapter_user = 1))
        AND ( ucp.ucp_comp_id is null OR ucp.ucp_comp_id = tt_mgt.mgt_comp_id OR tt_mgt.mgt_comp_id = 0 )
) a
LEFT JOIN tt_view_user_product_groups_for_cme_sub AS sub1 ON a.user_id = sub1.upg_user_id AND a.mgt_comp_id = sub1.upg_comp_id
go

INSERT INTO tt_market_product_group
    ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id,
      mkpg_product_group_id, mkpg_product_group, mkpg_requires_subscription_agreement )
SELECT
    now, 0, now, 0, tt_market.market_id, 0, '<All Products>', CByte( 0 )
FROM ( tt_previously_heartbeating_gateways [phg]
INNER JOIN tt_gateway ON phg.phg_gateway_id = tt_gateway.gateway_id )
INNER JOIN tt_market ON tt_gateway.gateway_market_id = tt_market.market_id
WHERE tt_market.market_id NOT IN ( SELECT mkpg_market_id FROM tt_market_product_group )
GROUP BY
    tt_market.market_id
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.041.000'
go
