update tt_db_version set dbv_version = 'converting to 7.17.20'
go

alter table tt_user_gmgt add uxg_exchange_data1 varchar(100) not null
go

alter table tt_user_gmgt add uxg_exchange_data2 varchar(100) not null
go

alter table tt_user_gmgt add uxg_exchange_data3 varchar(100) not null
go

alter table tt_user_gmgt add uxg_exchange_data4 varchar(100) not null
go

alter table tt_user_gmgt add uxg_exchange_data5 varchar(100) not null
go

alter table tt_user_gmgt add uxg_exchange_data6 varchar(100) not null
go

alter table tt_user_company_permission add ucp_quoting_allowed byte null
go

update tt_user_company_permission set ucp_quoting_allowed = 0
go

ALTER table tt_account_group add ag_credit int NOT NULL
go

ALTER table tt_account_group add ag_credit_currency_abbrev VARCHAR(3) NOT NULL
go

ALTER table tt_account_group add ag_apply_margin byte NOT NULL
go

ALTER table tt_account_group add ag_apply_pl byte NOT NULL
go

update tt_account_group set ag_credit = 0, ag_credit_currency_abbrev = "USD", ag_apply_margin = 0, ag_apply_pl = 0
go

delete from tt_market_product_group where mkpg_market_id = 95
go

INSERT INTO tt_market ( market_id, market_name )
SELECT 95, 'NASDAQ_OMX_EU'
FROM
(
    SELECT count(*) as [cnt]
    FROM tt_market
    WHERE market_id = 95
) a where a.cnt = 0
go

--[NASDAQ_OMX_EU]
--NLX=1
--Nordic=2

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 95, 1, 'NLX')
go
insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
values (now, 0, now, 0, 95, 2, 'Nordic')
go

DROP VIEW tt_view_gmgts_missing_passwords
go

CREATE VIEW tt_view_gmgts_missing_passwords AS
SELECT tt_mgt.mgt_id,
tt_mgt.mgt_comp_id,
tt_gateway.gateway_name AS Gateway,
tt_gmgt.gm_member AS Member,
tt_gmgt.gm_group AS [Group],
tt_gmgt.gm_trader AS Trader,
tt_market.market_name,
tt_mgt.mgt_password
FROM tt_mgt 
INNER JOIN (tt_market 
INNER JOIN (tt_gateway 
INNER JOIN tt_gmgt ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) ON tt_market.market_id = tt_gateway.gateway_market_id) ON (tt_mgt.mgt_member = tt_gmgt.gm_member) AND (tt_mgt.mgt_group = tt_gmgt.gm_group) AND (tt_mgt.mgt_trader = tt_gmgt.gm_trader)
WHERE (
tt_market.market_id = 2 	
or tt_market.market_id = 1 	
or tt_market.market_id = 10
or tt_market.market_id = 11 
or tt_market.market_id = 32
or (tt_market.market_id = 6 and tt_gateway.gateway_name like '%ecbot%')
or (tt_market.market_id = 3 and tt_gateway.gateway_name like 'liffe%') ) 
and mgt_type = 0
and tt_mgt.mgt_member <> '<No'
and tt_mgt.mgt_password = '';
go

alter table tt_company add comp_trading_kill_switch_allowed byte not null
go

update tt_company set comp_trading_kill_switch_allowed = 1
go


INSERT INTO tt_market ( market_id, market_name )
SELECT 71, 'OSE'
FROM
(
    SELECT count(*) as [cnt]
    FROM tt_market
    WHERE market_id = 71
) a where a.cnt = 0
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 10, 'Security Options'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 10 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 20, 'Index RNP'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 20 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 30, 'Index Futures'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 30 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 40, 'Index Options'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 40 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 1, 'Index DJIA'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 1 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 2, 'Index Futures 2'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 2 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 29, 'JGB'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 29 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 21, 'TOPIX Options'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 21 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 22, 'Index Futures 3'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 22 )
go

insert into tt_market_product_group (mkpg_created_datetime,mkpg_created_user_id,mkpg_last_updated_datetime,mkpg_last_updated_user_id,mkpg_market_id,mkpg_product_group_id,mkpg_product_group)
select now, 0, now, 0, 71, 23, 'Index Futures 5'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 23 )
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 10 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 20 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 30 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 40 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 1 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 2 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 29 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 21 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 22 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 23 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 71 AND m1.mkpg_product_group_id = 0
go

delete from tt_market_product_group where mkpg_market_id = 71 AND mkpg_product_group_id = 0
go

alter table tt_user_setup_user_type alter column utype_description varchar(64)
go

insert into tt_user_setup_user_type values(13, 'Group Admin (can create non-TTORDS, cannot manage accounts)')
go

insert into tt_user_setup_user_type values(14, 'Group Admin (cannot manage accounts)')
go

UPDATE tt_account_group
    SET ag_avoid_orders_that_cross = 2
    WHERE ag_avoid_orders_that_cross = 1
GO

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.020.000'
go

