update tt_db_version set dbv_version = 'converting to 7.17.87'
go

alter table tt_account_default drop constraint index_account_default_key
go

create unique index index_account_default_key on tt_account_default (acctd_user_id , acctd_comp_id, acctd_account_id, acctd_market_id, acctd_gateway_id, acctd_product_type, acctd_al_algo_id)
go

drop index index_account_default_user_seq on tt_account_default
go

create unique index index_account_default_user_seq on tt_account_default (acctd_user_id, acctd_comp_id, acctd_sequence_number, acctd_market_id, acctd_gateway_id)
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.087.000'
go
