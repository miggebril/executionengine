update tt_db_version set dbv_version = 'converting to 7.17.85'
go

ALTER TABLE tt_user ADD user_sniper_orders_allowed BYTE NOT NULL
go

ALTER TABLE tt_user ADD user_eu_config_1_allowed BYTE NOT NULL
go

ALTER TABLE tt_user ADD user_eu_config_1 varchar(255) NOT NULL
go

ALTER TABLE tt_user ADD user_eu_config_2_allowed BYTE NOT NULL
go

ALTER TABLE tt_user ADD user_eu_config_2 varchar(255) NOT NULL
go


UPDATE tt_user
    SET user_sniper_orders_allowed = CByte(1),
        user_eu_config_1_allowed = CByte(0),
        user_eu_config_1 = '',
        user_eu_config_2_allowed = CByte(0),
        user_eu_config_2 = ''
go

ALTER TABLE tt_user_company_permission ADD ucp_sniper_orders_allowed BYTE NOT NULL
go

ALTER TABLE tt_user_company_permission ADD ucp_eu_config_1_allowed BYTE NOT NULL
go

ALTER TABLE tt_user_company_permission ADD ucp_eu_config_1 varchar(255) NOT NULL
go

ALTER TABLE tt_user_company_permission ADD ucp_eu_config_2_allowed BYTE NOT NULL
go

ALTER TABLE tt_user_company_permission ADD ucp_eu_config_2 varchar(255) NOT NULL
go


UPDATE tt_user_company_permission
    SET ucp_sniper_orders_allowed = CByte(1),
        ucp_eu_config_1_allowed = CByte(0),
        ucp_eu_config_1 = '',
        ucp_eu_config_2_allowed = CByte(0),
        ucp_eu_config_2 = ''
go

update tt_margin_limit set mlim_order_threshold=1 where mlim_order_threshold=0
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.085.000'
go
