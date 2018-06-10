alter table tt_customer_default alter column cusd_fft4 varchar(255) null
go

alter table tt_customer_default alter column cusd_fft5 varchar(255) null
go

alter table tt_customer_default alter column cusd_fft6 varchar(255) null
go

alter table tt_customer_default alter column cusd_investment_decision varchar(255) null
go

alter table tt_customer_default alter column cusd_execution_decision varchar(255) null
go

alter table tt_customer_default alter column cusd_client varchar(255) null
go

alter table tt_customer_default alter column cusd_dea varchar(1) null
go

alter table tt_customer_default alter column cusd_trading_capacity varchar(1) null
go

alter table tt_customer_default alter column cusd_liquidity_provision varchar(1) null
go

alter table tt_customer_default alter column cusd_cdi varchar(1) null
go

alter table tt_account_default  alter column acctd_fft4 varchar(255) null
go

alter table tt_account_default  alter column acctd_fft5 varchar(255) null
go

alter table tt_account_default  alter column acctd_fft6 varchar(255) null
go

alter table tt_account_default  alter column acctd_investment_decision varchar(255) null
go

alter table tt_account_default  alter column acctd_execution_decision varchar(255) null
go

alter table tt_account_default  alter column acctd_client varchar(255) null
go

alter table tt_account_default  alter column acctd_dea varchar(1) null
go

alter table tt_account_default  alter column acctd_trading_capacity varchar(1) null
go

alter table tt_account_default  alter column acctd_liquidity_provision varchar(1) null
go

alter table tt_account_default  alter column acctd_cdi varchar(1) null
go

create table tt_algos
(
al_algo_id 				 counter      not null primary key,
al_algo_name 				 varchar(255) not null,
al_comp_id				 int,
al_editable				 byte 	      not null default 1,
al_created_datetime                      datetime     not null,
al_created_user_id                       int          not null,
al_last_updated_datetime                 datetime     not null,
al_last_updated_user_id                  int          not null)
go


insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id) 
select 'Aggregator', comp_id, 0, now, 0, now, 0 from tt_company
go

insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id)
select 'Autospreader', comp_id, 0, now, 0, now, 0 from tt_company
go

insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id)
select 'Liquidate', comp_id, 0, now, 0, now, 0 from tt_company
go

insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id)
select 'Sniper', comp_id, 0, now, 0, now, 0 from tt_company
go

insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id)
select 'TT Synthetic', comp_id, 0, now, 0, now, 0 from tt_company
go

alter table tt_customer_default add column cusd_al_algo_id int
go

alter table tt_account_default add column acctd_al_algo_id int
go

