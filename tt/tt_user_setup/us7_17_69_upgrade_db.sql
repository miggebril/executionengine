update tt_db_version set dbv_version = 'converting to 7.17.69'
go

DROP VIEW tt_view_fix_client_server_mgt_dependencies
go
CREATE VIEW tt_view_fix_client_server_mgt_dependencies AS
SELECT
    tt_user.user_id AS server_user_id,
    tt_user.user_login AS server_user_login,
    tt_user_1.user_id AS client_user_id,
    tt_user_1.user_login AS client_user_login,
    tt_gmgt.gm_id AS server_gm_id,
    tt_gmgt.gm_gateway_id AS server_gm_gateway_id,
    tt_gmgt.gm_member AS server_gm_member,
    tt_gmgt.gm_group AS server_gm_group,
    tt_gmgt.gm_trader AS server_gm_trader,
    tt_mgt.mgt_id AS server_mgt_id,
    tt_gmgt_1.gm_id AS client_gm_id,
    tt_gmgt_1.gm_member AS client_gm_member,
    tt_gmgt_1.gm_group AS client_gm_group,
    tt_gmgt_1.gm_trader AS client_gm_trader,
    tt_mgt_1.mgt_id AS client_mgt_id
FROM (((((((( tt_user_user_relationship
INNER JOIN tt_user AS tt_user_1 ON tt_user_user_relationship.uur_user_id1 = tt_user_1.user_id )
INNER JOIN tt_user_gmgt AS tt_user_gmgt_1 ON tt_user_1.user_id = tt_user_gmgt_1.uxg_user_id )
INNER JOIN tt_gmgt AS tt_gmgt_1 ON tt_user_gmgt_1.uxg_gmgt_id = tt_gmgt_1.gm_id )
INNER JOIN tt_mgt AS tt_mgt_1 ON (tt_gmgt_1.gm_trader = tt_mgt_1.mgt_trader) AND (tt_gmgt_1.gm_group = tt_mgt_1.mgt_group) AND (tt_gmgt_1.gm_member = tt_mgt_1.mgt_member) )
INNER JOIN tt_user ON tt_user_user_relationship.uur_user_id2 = tt_user.user_id )
INNER JOIN tt_user_gmgt ON tt_user.user_id = tt_user_gmgt.uxg_user_id )
INNER JOIN tt_gmgt ON tt_user_gmgt.uxg_gmgt_id = tt_gmgt.gm_id )
INNER JOIN tt_mgt ON (tt_gmgt.gm_trader = tt_mgt.mgt_trader) AND (tt_gmgt.gm_group = tt_mgt.mgt_group) AND (tt_gmgt.gm_member = tt_mgt.mgt_member) )
WHERE
    tt_gmgt.gm_gateway_id = tt_gmgt_1.gm_gateway_id
    AND tt_user.user_fix_adapter_role in (2,3) 
    AND tt_user_1.user_fix_adapter_role = 1
    AND tt_user_user_relationship.uur_relationship_type = 'fix'
    AND tt_user_gmgt.uxg_available_to_user = 1
    AND tt_user_gmgt_1.uxg_available_to_fix_adapter_user = 1
    AND tt_gmgt.gm_id <> tt_gmgt_1.gm_id;
go

alter table tt_user add user_mgt_auto_login byte not null default 1
go

update tt_user set user_mgt_auto_login = CByte( 1 )
go

INSERT INTO tt_market ( market_id, market_name )
SELECT 104, 'SGX_OTC'
FROM tt_login_server_settings
WHERE 0 = ( SELECT COUNT(*) FROM tt_market WHERE market_id = 104 )
go


UPDATE tt_company
   SET comp_smtp_body = MID( comp_smtp_body,   1,   INSTR(comp_smtp_body, 'https://www.tradingtechnologies.com/Multibroker/login')  - 1 )
                     + 'https://www.tradingtechnologies.com/login'
                     + MID( comp_smtp_body,  INSTR(comp_smtp_body, 'https://www.tradingtechnologies.com/Multibroker/login') + LEN('https://www.tradingtechnologies.com/Multibroker/login'),
                           LEN(comp_smtp_body) - INSTR(comp_smtp_body, 'https://www.tradingtechnologies.com/Multibroker/login') - LEN('https://www.tradingtechnologies.com/Multibroker/login') + 1   )
WHERE INSTR(comp_smtp_body, 'https://www.tradingtechnologies.com/Multibroker/login') > 0 AND 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
go

UPDATE tt_company
   SET comp_smtp_body = MID( comp_smtp_body,   1,   INSTR(comp_smtp_body, '<URL goes here>')  - 1 )
                     + 'https://www.tradingtechnologies.com/login'
                     + MID( comp_smtp_body,  INSTR(comp_smtp_body, '<URL goes here>') + LEN('<URL goes here>'),
                           LEN(comp_smtp_body) - INSTR(comp_smtp_body, '<URL goes here>') - LEN('<URL goes here>') + 1   )
WHERE INSTR(comp_smtp_body, '<URL goes here>') > 0 AND 1 = ( SELECT lss_multibroker_mode FROM tt_login_server_settings )
go

ALTER table tt_company ADD comp_password_rules_override_on BYTE NOT NULL
go

ALTER table tt_company ADD comp_2fa_trust_days INT NOT NULL
go

ALTER table tt_company ADD comp_enforce_password_expiration BYTE NOT NULL
go

ALTER table tt_company ADD comp_expiration_period_days INT NOT NULL
go

UPDATE tt_company 
    SET comp_password_rules_override_on = CByte(0),
           comp_2fa_trust_days = 30,
           comp_enforce_password_expiration = CByte(0),
           comp_expiration_period_days  = 120
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.069.000'
go
