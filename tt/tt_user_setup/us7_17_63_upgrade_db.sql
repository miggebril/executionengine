update tt_db_version set dbv_version = 'converting to 7.17.63'
go

UPDATE tt_market_product_group 
SET mkpg_product_group_id = 702 
WHERE mkpg_market_id = 3 AND mkpg_product_group like 'Euronext Equity and Index Derivatives'
go


UPDATE tt_market_product_group 
SET mkpg_product_group_id = 704 
WHERE mkpg_market_id = 3 AND mkpg_product_group like 'Euronext Currency Derivatives'
go

UPDATE tt_market_product_group 
SET mkpg_product_group_id = 706 
WHERE mkpg_market_id = 3 AND mkpg_product_group like 'Euronext Commodities Derivatives'
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.063.000'
go
