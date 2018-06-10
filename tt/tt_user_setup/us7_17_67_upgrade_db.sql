update tt_db_version set dbv_version = 'converting to 7.17.67'
go

INSERT INTO tt_market_product_group ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id, mkpg_product_group_id, mkpg_product_group, mkpg_requires_subscription_agreement )
    VALUES ( now, 0, now, 0, 32, 13, 'ICE Futures SG', 0 )
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
SELECT now, 0, now, 0, tt_user.user_id, 0, mkpg.mkpg_market_product_group_id
FROM tt_market_product_group mkpg, tt_user
WHERE mkpg.mkpg_market_id = 32
    AND mkpg.mkpg_product_group_id = 13
    AND 0 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
SELECT now, 0, now, 0, tt_user.user_id, ucp.ucp_comp_id, mkpg.mkpg_market_product_group_id
FROM tt_market_product_group mkpg, tt_user
INNER JOIN tt_user_company_permission ucp ON tt_user.user_id = ucp.ucp_user_id
WHERE mkpg.mkpg_market_id = 32
    AND mkpg.mkpg_product_group_id = 13
    AND 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
go

DELETE  from tt_user_product_group where upg_user_product_group_id in 
( SELECT upg_user_product_group_id from tt_user_product_group nymexpg where upg_market_product_group_id in
    ( SELECT mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id=7 and mkpg_product_group_id=3 and mkpg_product_group='NYMEX')
    AND 0 = ( Select  COUNT(*) from tt_user_product_group greenxpg where upg_market_product_group_id in
                ( SELECT mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id=7 and mkpg_product_group_id=10 and mkpg_product_group='GreenX') AND nymexpg.upg_user_id = greenxpg.upg_user_id AND nymexpg.upg_comp_id = greenxpg.upg_comp_id))

go

DELETE  from tt_user_product_group where upg_user_product_group_id in
( SELECT upg_user_product_group_id from tt_user_product_group cbotpg where upg_market_product_group_id in
    ( SELECT mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id=7 and mkpg_product_group_id=4 and mkpg_product_group='CBOT')
    AND 0 = ( Select  COUNT(*) from tt_user_product_group kcbtpg where upg_market_product_group_id in
                ( SELECT mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id=7 and mkpg_product_group_id=6 and mkpg_product_group='KCBT') AND cbotpg.upg_user_id = kcbtpg.upg_user_id AND cbotpg.upg_comp_id = kcbtpg.upg_comp_id))

go

DELETE from tt_market_product_group where mkpg_market_id=7 AND mkpg_product_group_id=12 and mkpg_product_group='DME-NYMEX'

go

DELETE from tt_market_product_group where mkpg_market_id=7 AND mkpg_product_group_id=6 and mkpg_product_group='KCBT'

go

DELETE from tt_market_product_group where mkpg_market_id=7 AND mkpg_product_group_id=10 and mkpg_product_group='GreenX'

go

ALTER table tt_product_limit add plim_allow_trading byte not null

go

UPDATE tt_product_limit set
    plim_allow_trading = CByte(1)
go


ALTER table tt_user add user_fix_subscribers_cbot int not null

go

ALTER table tt_user add user_fix_subscribers_cme int not null

go

ALTER table tt_user add user_fix_subscribers_cme_europe int not null

go

ALTER table tt_user add user_fix_subscribers_comex int not null

go

ALTER table tt_user add user_fix_subscribers_nymex int not null

go

ALTER table tt_user add user_fix_subscribers_dme int not null

go

UPDATE tt_user set
    user_fix_subscribers_cbot = 0,
    user_fix_subscribers_cme = 0,
    user_fix_subscribers_cme_europe = 0,
    user_fix_subscribers_comex = 0,
    user_fix_subscribers_nymex = 0,
    user_fix_subscribers_dme = 0

go

UPDATE tt_market_product_group set mkpg_product_group="BMD" where mkpg_product_group like "Bursa Malaysia" AND mkpg_market_id=7 and mkpg_product_group_id=11

go

UPDATE tt_market_product_group set mkpg_product_group="BM&F" where mkpg_product_group like "BVMF" AND mkpg_market_id=7 and mkpg_product_group_id=9

go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.067.000'
go
