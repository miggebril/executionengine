update tt_db_version set dbv_version = 'converting to 7.17.60'
go

ALTER TABLE tt_user ADD user_2fa_required_mode INT NOT NULL DEFAULT 0
go

UPDATE tt_user
SET user_2fa_required_mode = 0
go

UPDATE tt_user
SET user_2fa_required_mode = 1
WHERE user_2fa_required = CByte(1)
    AND 1 = ( SELECT lss_2fa_state FROM tt_login_server_settings )
go

UPDATE tt_user
SET user_2fa_required_mode = 2
WHERE user_2fa_required = CByte(1)
    AND 2 = ( SELECT lss_2fa_state FROM tt_login_server_settings )
go

ALTER TABLE tt_user_company_permission ADD ucp_2fa_required_mode INT NOT NULL DEFAULT 0
go

UPDATE tt_user_company_permission
SET ucp_2fa_required_mode = 0
go

UPDATE tt_user_company_permission
SET ucp_2fa_required_mode = 1
WHERE ucp_2fa_required = CByte(1)
    AND 1 = ( SELECT lss_2fa_state FROM tt_login_server_settings )
go

UPDATE tt_user_company_permission
SET ucp_2fa_required_mode = 2
WHERE ucp_2fa_required = CByte(1)
    AND 2 = ( SELECT lss_2fa_state FROM tt_login_server_settings )
go

INSERT INTO tt_market ( market_id, market_name )
SELECT 3, 'NYSE_Liffe'
FROM tt_login_server_settings
WHERE 0 = ( SELECT COUNT(*) FROM tt_market WHERE market_id = 3 )
go

INSERT INTO tt_market_product_group ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id, mkpg_product_group_id, mkpg_product_group, mkpg_requires_subscription_agreement )
SELECT now, 0, now, 0, 3, 0, '<All Euronext Products>', 0
FROM tt_login_server_settings
WHERE 0 = ( SELECT COUNT(*) FROM tt_market_product_group WHERE mkpg_market_id = 3 AND mkpg_product_group_id = 0 )
go

INSERT INTO tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
SELECT now, 0, now, 0, user_id, comp_id, NL.mkpg_market_product_group_id
FROM tt_market_product_group NL,
(
    SELECT
        tt_user.user_id,
        tt_user_company_permission.ucp_comp_id AS [comp_id]
    FROM tt_user
    INNER JOIN tt_user_company_permission ON tt_user.user_id = tt_user_company_permission.ucp_user_id
    WHERE 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
UNION
    SELECT
        tt_user.user_id, 0
    FROM tt_user
    WHERE 0 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
)
WHERE NL.mkpg_market_id = 3
    AND NL.mkpg_product_group = '<All Euronext Products>'
go

UPDATE tt_market_product_group
SET mkpg_product_group = '<All Euronext Products>'
WHERE mkpg_market_id = 3 AND mkpg_product_group_id = 0
go

INSERT INTO tt_market_product_group ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id, mkpg_product_group_id, mkpg_product_group, mkpg_requires_subscription_agreement )
    VALUES ( now, 0, now, 0, 3, 1, 'Euronext Equity and Index Derivatives', 0 )
go
INSERT INTO tt_market_product_group ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id, mkpg_product_group_id, mkpg_product_group, mkpg_requires_subscription_agreement )
    VALUES ( now, 0, now, 0, 3, 2, 'Euronext Commodities Derivatives', 0 )
go
INSERT INTO tt_market_product_group ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id, mkpg_product_group_id, mkpg_product_group, mkpg_requires_subscription_agreement )
    VALUES ( now, 0, now, 0, 3, 3, 'Euronext Currency Derivatives', 0 )
go

INSERT INTO tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
SELECT now, 0, now, 0, upg.upg_user_id, upg.upg_comp_id, allNL.mkpg_market_product_group_id
FROM tt_market_product_group allNL, tt_user_product_group upg
INNER JOIN tt_market_product_group mkpg ON upg.upg_market_product_group_id = mkpg.mkpg_market_product_group_id
WHERE mkpg.mkpg_market_id = 3
    AND allNL.mkpg_market_id = 3
    AND allNL.mkpg_product_group_id > 0
go

INSERT INTO tt_market_product_group ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id, mkpg_market_id, mkpg_product_group_id, mkpg_product_group, mkpg_requires_subscription_agreement )
    VALUES ( now, 0, now, 0, 71, 11, 'Weekly Options', 0 )
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
SELECT now, 0, now, 0, tt_user.user_id, 0, mkpg.mkpg_market_product_group_id
FROM tt_market_product_group mkpg, tt_user
WHERE mkpg.mkpg_market_id = 71
    AND mkpg.mkpg_product_group_id = 11
    AND 0 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
SELECT now, 0, now, 0, tt_user.user_id, ucp.ucp_comp_id, mkpg.mkpg_market_product_group_id
FROM tt_market_product_group mkpg, tt_user
INNER JOIN tt_user_company_permission ucp ON tt_user.user_id = ucp.ucp_user_id
WHERE mkpg.mkpg_market_id = 71
    AND mkpg.mkpg_product_group_id = 11
    AND 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.060.000'
go
