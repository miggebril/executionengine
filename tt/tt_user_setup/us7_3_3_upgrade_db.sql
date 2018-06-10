update tt_db_version set dbv_version = 'converting to 7.3.3'
go

alter table tt_account_default add acctd_gateway_id int not null
go

update tt_account_default set acctd_gateway_id = -1
go

alter table tt_account_default drop constraint index_account_default_key
go

create unique index index_account_default_key on tt_account_default (acctd_user_id , acctd_account_id, acctd_market_id, acctd_gateway_id, acctd_product_type)
go

update tt_account_default set acctd_product_type = ucase(acctd_product_type)
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.003.003.000'
go