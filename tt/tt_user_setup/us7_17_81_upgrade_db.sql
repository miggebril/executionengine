update tt_db_version set dbv_version = 'converting to 7.17.81'
go

ALTER TABLE tt_company ADD comp_requires_sfe_mda BYTE NOT NULL
go

UPDATE tt_company SET comp_requires_sfe_mda = CByte(1)
go

-- Update all sfe product groups to require a subscription agreement
UPDATE tt_market_product_group
SET mkpg_requires_subscription_agreement = CByte( 1 )
WHERE mkpg_market_id = 24
go

-- For any user who signed CME MDA, mark them signed for sfe MDA
INSERT INTO tt_user_mpg_sub_agreement (umsa_user_id, umsa_market_product_group_id, umsa_created_user_id, umsa_last_updated_user_id, umsa_created_datetime, umsa_last_updated_datetime)
select DISTINCT(umsa_user_id), mkpg_market_product_group_id, 0, 0, now, now from tt_user_mpg_sub_agreement, (select mkpg_market_product_group_id from  tt_market_product_group where mkpg_market_id = 24)
WHERE 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings ) AND umsa_market_product_group_id in (select mkpg_market_product_group_id from  tt_market_product_group where mkpg_market_id = 7)
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.081.000'
go
