update tt_db_version set dbv_version = 'converting to 7.17.21'
go

DELETE FROM tt_market WHERE market_id = 4
go

ALTER TABLE tt_market_product_group ADD mkpg_product_group_tmp VARCHAR(64) NOT NULL
go

UPDATE tt_market_product_group SET mkpg_product_group_tmp = mkpg_product_group
go

ALTER TABLE tt_market_product_group DROP mkpg_product_group
go

ALTER TABLE tt_market_product_group ADD mkpg_product_group VARCHAR(64) NOT NULL
go

UPDATE tt_market_product_group SET mkpg_product_group = mkpg_product_group_tmp
go

ALTER TABLE tt_market_product_group DROP mkpg_product_group_tmp
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
select now, 0, now, 0, 99, 73, 'Bosra Italiana Derivatives'
from tt_login_server_settings
where 0 = ( select count(*) from tt_market_product_group where mkpg_market_id = 99 AND mkpg_product_group_id = 73 )
go


insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 99 AND mkpg_product_group_id = 69 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 99 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 99 AND mkpg_product_group_id = 79 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 99 AND m1.mkpg_product_group_id = 0
go

insert into tt_user_product_group ( upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id, upg_market_product_group_id )
select upg_created_datetime, upg_created_user_id, upg_last_updated_datetime, upg_last_updated_user_id, upg_user_id, upg_comp_id,
    ( select mkpg_market_product_group_id from tt_market_product_group where mkpg_market_id = 99 AND mkpg_product_group_id = 73 ) as [market_product_group_id]
from tt_user_product_group
inner join tt_market_product_group m1 on tt_user_product_group.upg_market_product_group_id = m1.mkpg_market_product_group_id
where m1.mkpg_market_id = 99 AND m1.mkpg_product_group_id = 0
go

delete from tt_market_product_group where mkpg_market_id = 99 AND mkpg_product_group_id = 0
go

DELETE FROM tt_user_product_group WHERE upg_market_product_group_id IN ( SELECT mkpg_market_product_group_id FROM tt_market_product_group WHERE mkpg_market_id = 99 )
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
GO

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.021.000'
go
