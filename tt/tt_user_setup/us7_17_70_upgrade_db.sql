update tt_db_version set dbv_version = 'converting to 7.17.70'
go

ALTER TABLE tt_company ADD comp_requires_ice_mda BYTE NOT NULL
go

UPDATE tt_company SET comp_requires_ice_mda = CByte(1)
go

-- Update all ICE product groups to require a subscription agreement
UPDATE tt_market_product_group
SET mkpg_requires_subscription_agreement = CByte( 1 )
WHERE mkpg_market_id = 32
go

-- For any user who signed CME MDA, mark them signed for ICE MDA
INSERT INTO tt_user_mpg_sub_agreement (umsa_user_id, umsa_market_product_group_id, umsa_created_user_id, umsa_last_updated_user_id, umsa_created_datetime, umsa_last_updated_datetime)  
select DISTINCT(umsa_user_id), mkpg_market_product_group_id, 0, 0, now, now from tt_user_mpg_sub_agreement, (select mkpg_market_product_group_id from  tt_market_product_group where mkpg_market_id = 32)
WHERE 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
go
 
ALTER TABLE tt_netting_organization ADD no_notes VARCHAR(64) NOT NULL
GO

UPDATE tt_netting_organization SET no_notes = ''
GO

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.070.000'
go
