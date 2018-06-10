update tt_db_version set dbv_version = 'converting to 7.17.84'
go

alter table tt_customer_default add column cusd_fft4 varchar(255)
go

alter table tt_customer_default add column cusd_fft5 varchar(255)
go

alter table tt_customer_default add column cusd_fft6 varchar(255)
go

alter table tt_customer_default add column cusd_investment_decision varchar(255)
go

alter table tt_customer_default add column cusd_execution_decision varchar(255)
go

alter table tt_customer_default add column cusd_client varchar(255)
go

alter table tt_customer_default add column cusd_dea varchar(20)
go

alter table tt_customer_default add column cusd_trading_capacity varchar(20)
go

alter table tt_customer_default add column cusd_liquidity_provision varchar(20)
go

alter table tt_customer_default add column cusd_cdi varchar(20)
go


alter table tt_account_default  add column acctd_fft4 varchar(255)
go

alter table tt_account_default  add column acctd_fft5 varchar(255)
go

alter table tt_account_default  add column acctd_fft6 varchar(255)
go

alter table tt_account_default  add column acctd_investment_decision varchar(255)
go

alter table tt_account_default  add column acctd_execution_decision varchar(255)
go

alter table tt_account_default  add column acctd_client varchar(255)
go

alter table tt_account_default  add column acctd_dea varchar(20)
go

alter table tt_account_default  add column acctd_trading_capacity varchar(20)
go

alter table tt_account_default  add column acctd_liquidity_provision varchar(20)
go

alter table tt_account_default  add column acctd_cdi varchar(20)
go


--Create tt_algos table
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
select 'Autotrader', comp_id, 0, now, 0, now, 0 from tt_company
go

insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id)
select 'Liquidate', comp_id, 0, now, 0, now, 0 from tt_company
go

insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id)
select 'Sniper', comp_id, 0, now, 0, now, 0 from tt_company
go

insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id)
select 'SSE', comp_id, 0, now, 0, now, 0 from tt_company
go

insert into tt_algos (al_algo_name, al_comp_id, al_editable , al_created_datetime, al_created_user_id, al_last_updated_datetime, al_last_updated_user_id)
select 'ADL', comp_id, 0, now, 0, now, 0 from tt_company
go

alter table tt_customer_default add column cusd_al_algo_id int
go

alter table tt_account_default add column acctd_al_algo_id int
go

update tt_account_default  set
acctd_fft4 = '',
acctd_fft5 = '',
acctd_fft6 = '',
acctd_investment_decision = '',
acctd_execution_decision = '',
acctd_client = '',
acctd_dea = 'None',
acctd_trading_capacity = 'None',
acctd_liquidity_provision = 'None',
acctd_cdi = 'None',
acctd_al_algo_id = 0
go

update tt_customer_default set
cusd_fft4 = '',
cusd_fft5 = '',
cusd_fft6 = '',
cusd_investment_decision = '',
cusd_execution_decision = '',
cusd_client = '',
cusd_dea = 'None',
cusd_trading_capacity = 'None',
cusd_liquidity_provision = 'None',
cusd_cdi = 'None',
cusd_al_algo_id = 0
go

ALTER TABLE tt_user ADD user_aggregator_allowed BYTE NOT NULL
go

UPDATE tt_user
    SET user_aggregator_allowed = CByte(1)
go

ALTER TABLE tt_user_company_permission ADD ucp_aggregator_allowed BYTE NOT NULL
go

UPDATE tt_user_company_permission
    SET ucp_aggregator_allowed = CByte(1)
go

ALTER TABLE tt_margin_limit ADD mlim_prevent_dup_orders_enabled BYTE not null
go

UPDATE tt_margin_limit
    SET mlim_prevent_dup_orders_enabled = CByte(0)
go

alter table tt_customer_default drop constraint index_customer_default_key
go

create unique index index_customer_default_key on tt_customer_default (cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_in_hex, cusd_product_type, cusd_al_algo_id)
go

alter table tt_account_default drop constraint index_account_default_key
go

create unique index index_account_default_key on tt_account_default (acctd_user_id , acctd_account_id, acctd_market_id, acctd_gateway_id, acctd_product_type, acctd_al_algo_id)
go

ALTER TABLE tt_margin_limit ADD mlim_order_threshold int not null default 0
go

UPDATE tt_margin_limit
    SET mlim_order_threshold = 0
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.084.000'
go
