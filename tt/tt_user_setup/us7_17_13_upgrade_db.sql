update tt_db_version set dbv_version = 'converting to 7.17.13'
go

alter table tt_company add comp_trading_enabled byte not null
go

alter table tt_company add comp_trading_enabled_last_updated_user_id int not null
go

update tt_company set comp_trading_enabled = 1
go

update tt_company set comp_trading_enabled_last_updated_user_id = 1
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.013.000'
go

