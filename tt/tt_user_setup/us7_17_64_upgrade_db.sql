update tt_db_version set dbv_version = 'converting to 7.17.64'
go

UPDATE tt_market_product_group
SET mkpg_product_group_id = 3
WHERE mkpg_market_id = 71 AND mkpg_product_group like 'Weekly Options'
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.064.000'
go
