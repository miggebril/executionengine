update tt_db_version set dbv_version = 'converting to 7.17.73'
go

ALTER TABLE tt_company ADD comp_requires_bvmf_mda BYTE NOT NULL
go

UPDATE tt_company SET comp_requires_bvmf_mda = CByte(1)
go

-- Update all bvmf product groups to require a subscription agreement
UPDATE tt_market_product_group
SET mkpg_requires_subscription_agreement = CByte( 1 )
WHERE mkpg_market_id = 90
go

-- For any user who signed CME MDA, mark them signed for bvmf MDA
INSERT INTO tt_user_mpg_sub_agreement (umsa_user_id, umsa_market_product_group_id, umsa_created_user_id, umsa_last_updated_user_id, umsa_created_datetime, umsa_last_updated_datetime)  
select DISTINCT(umsa_user_id), mkpg_market_product_group_id, 0, 0, now, now from tt_user_mpg_sub_agreement, (select mkpg_market_product_group_id from  tt_market_product_group where mkpg_market_id = 90)
WHERE 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings ) AND umsa_market_product_group_id in (select mkpg_market_product_group_id from  tt_market_product_group where mkpg_market_id = 7)
go

-- User's ICE grandfathered fields
alter table tt_user add user_sw_ice_fut_can byte not null
go

alter table tt_user add user_sw_ice_phy_env byte not null
go

alter table tt_user add user_sw_ice_ifus_gas byte not null
go

alter table tt_user add user_sw_ice_ifeu_oil byte not null
go

alter table tt_user add user_sw_ice_ifus_pwr byte not null
go

alter table tt_user add user_sw_ice_ifeu_com byte not null
go

alter table tt_user add user_sw_ice_fut_us byte not null
go

alter table tt_user add user_sw_ice_ifeu_fin byte not null
go

alter table tt_user add user_sw_ice_endex byte not null
go

alter table tt_user add user_sw_ice_fut_sg byte not null
go

update tt_user set
    user_sw_ice_fut_can = CByte( 0 ),
    user_sw_ice_phy_env = CByte( 0 ),
    user_sw_ice_ifus_gas = CByte( 0 ),
    user_sw_ice_ifeu_oil = CByte( 0 ),
    user_sw_ice_ifus_pwr = CByte( 0 ),
    user_sw_ice_ifeu_com = CByte( 0 ),
    user_sw_ice_fut_us = CByte( 0 ),
    user_sw_ice_ifeu_fin = CByte( 0 ),
    user_sw_ice_endex = CByte( 0 ),
    user_sw_ice_fut_sg = CByte( 0 )
go

UPDATE tt_customer_default
SET cusd_first_default = 1
WHERE cusd_id IN
(
    SELECT cusd_id
    FROM tt_customer_default c
    INNER JOIN
    (
        SELECT cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_type, cusd_product
        FROM tt_customer_default
        GROUP BY cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_type, cusd_product
        HAVING COUNT(*) > 1
    ) d ON c.cusd_user_id = d.cusd_user_id
        AND c.cusd_comp_id = d.cusd_comp_id
        AND c.cusd_customer = d.cusd_customer
        AND c.cusd_market_id = d.cusd_market_id
        AND c.cusd_gateway_id = d.cusd_gateway_id
        AND c.cusd_product_type = d.cusd_product_type
        AND c.cusd_product = d.cusd_product
    WHERE c.cusd_product_in_hex = '2A'
)
GO

DELETE FROM tt_customer_default
WHERE cusd_id IN
(
    SELECT cusd_id
    FROM tt_customer_default c
    INNER JOIN
    (
        SELECT cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_type, cusd_product
        FROM tt_customer_default
        GROUP BY cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_type, cusd_product
        HAVING COUNT(*) > 1
    ) d ON c.cusd_user_id = d.cusd_user_id
        AND c.cusd_comp_id = d.cusd_comp_id
        AND c.cusd_customer = d.cusd_customer
        AND c.cusd_market_id = d.cusd_market_id
        AND c.cusd_gateway_id = d.cusd_gateway_id
        AND c.cusd_product_type = d.cusd_product_type
        AND c.cusd_product = d.cusd_product
    WHERE c.cusd_product_in_hex = ''
)
GO

UPDATE tt_customer_default SET cusd_product_in_hex = '2A' WHERE cusd_product = '*' AND cusd_product_in_hex = ''
GO

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.073.000'
go
