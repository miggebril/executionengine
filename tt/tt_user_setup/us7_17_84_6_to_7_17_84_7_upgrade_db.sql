insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id)
select 'Autotrader', comp_id, 0, now, 0, now, 0 from tt_company
go

update tt_algos set al_algo_name = 'SSE' where al_algo_name = 'TT Synthetic'
go

alter table tt_customer_default alter column cusd_dea varchar(20)
go

alter table tt_customer_default alter column cusd_trading_capacity varchar(20)
go

alter table tt_customer_default alter column cusd_liquidity_provision varchar(20)
go

alter table tt_customer_default alter column cusd_cdi varchar(20)
go

alter table tt_account_default  alter column acctd_dea varchar(20)
go

alter table tt_account_default  alter column acctd_trading_capacity varchar(20)
go

alter table tt_account_default  alter column acctd_liquidity_provision varchar(20)
go

alter table tt_account_default  alter column acctd_cdi varchar(20)
go

update tt_customer_default set cusd_dea = 'None'  where cusd_dea = 'N'
go

update tt_customer_default set cusd_dea = 'True'  where cusd_dea = 'T'
go

update tt_customer_default set cusd_dea = 'False'  where cusd_dea = 'F'
go

update tt_customer_default set cusd_liquidity_provision = 'None'  where cusd_liquidity_provision = 'N'
go

update tt_customer_default set cusd_liquidity_provision = 'True'  where cusd_liquidity_provision = 'T'
go

update tt_customer_default set cusd_liquidity_provision = 'False'  where cusd_liquidity_provision = 'F'
go

update tt_customer_default set cusd_cdi = 'None'  where cusd_cdi = 'N'
go

update tt_customer_default set cusd_cdi = 'True'  where cusd_cdi = 'T'
go

update tt_customer_default set cusd_cdi = 'False'  where cusd_cdi = 'F'
go

update tt_customer_default set cusd_trading_capacity = 'None'  where cusd_trading_capacity = 'N'
go

update tt_customer_default set cusd_trading_capacity = 'DEAL'  where cusd_trading_capacity = 'D'
go

update tt_customer_default set cusd_trading_capacity = 'MATCH'  where cusd_trading_capacity = 'M'
go

update tt_customer_default set cusd_trading_capacity = 'AOTC'  where cusd_trading_capacity = 'A'
go

update tt_account_default set acctd_dea = 'None'  where acctd_dea = 'N'
go

update tt_account_default set acctd_dea = 'True'  where acctd_dea = 'T'
go

update tt_account_default set acctd_dea = 'False'  where acctd_dea = 'F'
go

update tt_account_default set acctd_liquidity_provision = 'None'  where acctd_liquidity_provision = 'N'
go

update tt_account_default set acctd_liquidity_provision = 'True'  where acctd_liquidity_provision = 'T'
go

update tt_account_default set acctd_liquidity_provision = 'False'  where acctd_liquidity_provision = 'F'
go

update tt_account_default set acctd_cdi = 'None'  where acctd_cdi = 'N'
go

update tt_account_default set acctd_cdi = 'True'  where acctd_cdi = 'T'
go

update tt_account_default set acctd_cdi = 'False'  where acctd_cdi = 'F'
go

update tt_account_default set acctd_trading_capacity = 'None'  where acctd_trading_capacity = 'N'
go

update tt_account_default set acctd_trading_capacity = 'DEAL'  where acctd_trading_capacity = 'D'
go

update tt_account_default set acctd_trading_capacity = 'MATCH'  where acctd_trading_capacity = 'M'
go

update tt_account_default set acctd_trading_capacity = 'AOTC'  where acctd_trading_capacity = 'A'
go
