update tt_db_version set dbv_version = 'converting'
go

alter table tt_customer_default drop constraint fk_custd_to_order_restriction
go

alter table tt_customer_default drop constraint fk_custd_to_open_close
go

alter table tt_customer_default drop constraint fk_custd_to_time_in_force
go

alter table tt_customer_default drop constraint fk_custd_to_order_type
go

alter table tt_customer_default drop constraint fk_custd_to_account_type
go

alter table tt_customer_default drop constraint fk_custd_to_account
go

alter table tt_customer_default drop constraint fk_custd_to_product_type
go

alter table tt_customer_default drop constraint fk_custd_to_market
go

alter table tt_customer_default drop constraint fk_custd_to_user
go

alter table tt_gateway drop constraint fk_gateway_to_market
go

alter table tt_mgt drop constraint fk_mgt_to_gateway
go

alter table tt_user drop constraint fk_user_to_group
go

alter table tt_user_mgt drop constraint fk_user_mgt_to_user 
go

alter table tt_user_mgt drop constraint fk_user_mgt_to_mgt
go

alter table tt_user drop constraint fk_user_to_country 
go

alter table tt_user drop constraint fk_user_to_state 
go

alter table tt_user drop constraint fk_user_to_email_account
go

alter table tt_password_history drop constraint fk_password_history_to_user
go

alter table tt_user drop constraint fk_user_to_x_trader_mode
go

drop table tt_x_trader_mode
go
create table tt_x_trader_mode
(
x_trader_mode_id                                int          not null primary key,
x_trader_mode_name                              char(15)      not null
)
go

drop table tt_email_account
go
create table tt_email_account
(
emac_id                                   counter      not null primary key,
emac_created_datetime                     datetime     not null,
emac_created_user_id                      int          not null,
emac_last_updated_datetime                datetime     not null,
emac_last_updated_user_id                 int          not null,
emac_name                                 varchar(100) not null,
emac_host                                 varchar(100) not null,
emac_port                                 int          not null,
emac_requires_authentication              byte         not null,
emac_login_user                           varchar(100) not null,
emac_login_password                       varchar(100) not null,
emac_use_ssl                              byte         not null,
emac_from_address                         varchar(100) not null,
emac_subject                              varchar(100) not null,
emac_body                                 varchar(255) not null,
emac_include_username_in_message          byte         not null
)
go

create unique index unique_emac_name on tt_email_account (emac_name)
go

alter table tt_user add user_email_account int not null 
go
alter table tt_user add user_email varchar(100) not null 
go
alter table tt_user add user_restrict_customer_default_editing byte not null 
go
alter table tt_user add user_address varchar(50) not null 
go
alter table tt_user add user_phone varchar(20) not null 
go
alter table tt_user add user_def4  varchar(50) not null 
go
alter table tt_user add user_def5  varchar(50) not null 
go
alter table tt_user add user_def6  varchar(50) not null 
go
alter table tt_user add user_x_trader_mode int not null 
go


update tt_user set user_email_account = 0 where user_email_account is null
go
update tt_user set user_email = '' where user_email is null
go
update tt_user set user_restrict_customer_default_editing = 0 where user_restrict_customer_default_editing is null
go
update tt_user set user_address = '' where user_address is null
go
update tt_user set user_phone = '' where user_phone is null
go
update tt_user set user_def4 = '' where user_def4 is null
go
update tt_user set user_def5 = '' where user_def5 is null
go
update tt_user set user_def6 = '' where user_def6 is null
go
update tt_user set user_x_trader_mode = 0 where user_x_trader_mode is null
go





drop table tt_product_type
go
create table tt_product_type
(
product_description                          varchar(8) primary key,
product_id                                   int not null
)
go

drop table tt_account_type
go
create table tt_account_type
(
acctType_code                              varchar(2)  not null primary key,
accType_id                                 int not null,
acctType_description                       varchar(19) not null
)
go


drop table tt_account
go
create table tt_account
(
acct_id                                   counter      not null primary key,
acct_created_datetime                     datetime     not null,
acct_created_user_id                      int          not null,
acct_last_updated_datetime                datetime     not null,
acct_last_updated_user_id                 int          not null,
acct_name	                              varchar(20)  not null
)
go

create unique index unique_acct_name on tt_account (acct_name)
go


drop table tt_order_restriction
go
create table tt_order_restriction
(
ordrest_short_description                 varchar(10)  primary key,
ordrest_code                              varchar(1)   not null,
ordrest_long_description                  varchar(72)  not null
)
go


drop table tt_order_type
go
create table tt_order_type
(
ordertype_description                     varchar(5) primary key,
ordertype_code                            varchar(1) not null
)
go


drop table tt_time_in_force
go
create table tt_time_in_force
(
timeInForce_code                            varchar(3) primary key,
timeInForce_description                     varchar(15) not null
)
go

drop table tt_open_close_code
go
create table tt_open_close_code
(
openClose_description                     varchar(5) Primary key,
openClose_code                            varchar(1) not null
)
go

drop table tt_customer_default
go
create table tt_customer_default
(
cusd_id                                   counter      not null primary key,

cusd_created_datetime                     datetime     not null,
cusd_created_user_id                      int          not null,
cusd_last_updated_datetime                datetime     not null,
cusd_last_updated_user_id                 int          not null,

cusd_user_id                              int          not null,
cusd_customer                             varchar(15)  not null,
cusd_selected                             byte         not null,
cusd_market_id                            int          not null,
cusd_product                              varchar(15)  not null,

-- ProdIDs - Future, Spread, Option...
cusd_product_type                         varchar(8)   not null,

-- foreign key
cusd_account_id                           int          not null,
cusd_account_type                         varchar(2)   not null,

cusd_give_up                              varchar(255) not null,
cusd_fft2                                 varchar(255) not null,
cusd_fft3                                 varchar(255) not null,

-- GTD good till day, GTC good till close, GIS good in session
cusd_time_in_force                        varchar(3)   not null,

-- OrderTypeCodes - Limit, Mkt
cusd_order_type                           varchar(5)   not null,

-- OrderResCodes - block, FOK, Iceberg...
cusd_restriction                          varchar(10)   not null,

-- OpenCloseCodes - Open, Close
cusd_open_close                           varchar(5)   not null,

cusd_use_max_order_qty                    byte         not null,
cusd_max_order_qty                        int          not null
)
go

create index index_customer_default_user_id on tt_customer_default (cusd_user_id)
go
create unique index index_customer_default_key on tt_customer_default (cusd_user_id, cusd_customer, cusd_market_id, cusd_product, cusd_product_type)
go

-- x_trader modes
--To create the trade mark symbols
--chr(153)= ™  
--chr(174) = ®
--chr(169): ©s

insert into tt_x_trader_mode values(0,'<NA>')
go
insert into tt_x_trader_mode values(1,'X_TRADER' + chr(174))
go
insert into tt_x_trader_mode values(2,'X_TRADER' + chr(174) + ' Pro')
go
insert into tt_x_trader_mode values(3,'TT_TRADER' + chr(153))
go


insert into tt_email_account
(
emac_id,
emac_created_datetime,
emac_created_user_id,
emac_last_updated_datetime,
emac_last_updated_user_id,
emac_name,
emac_host,
emac_port,
emac_requires_authentication,
emac_login_user,
emac_login_password,
emac_use_ssl,
emac_from_address,
emac_subject,
emac_body,
emac_include_username_in_message
)
values
(
0,
now,
1,
now,
1,
'<None>',
' ',
0,
0,
'',
'',
0,
'',
'',
'',
1
)
go


alter table tt_user add constraint fk_user_to_email_account foreign key (user_email_account) references tt_email_account (emac_id)
go

alter table tt_password_history add constraint fk_password_history_to_user foreign key (password_history_user_id) references tt_user (user_id) ON DELETE CASCADE
go


-- Open / Close
insert into tt_open_close_code values('Open','O');
go
insert into tt_open_close_code values('Close','C');
go

-- Time in Force

insert into tt_time_in_force values('GTD','Good Til Day');
go
insert into tt_time_in_force values('GTC','Good Til Cancel');
go
insert into tt_time_in_force values('GIS','Good In Session');
go


-- Order Type

insert into tt_order_type values('Limit','L')
go
insert into tt_order_type values('Mkt','M')
go


-- Order Restrictions
insert into tt_order_restriction values('<None>',' ','No restriction')
go
insert into tt_order_restriction values('Block','B','Block')
go
insert into tt_order_restriction values('FOK','F','Fill or kill')
go
insert into tt_order_restriction values('Iceberg','f','Iceberg')
go
insert into tt_order_restriction values('IOC','I','Immediate or cancel')
go
insert into tt_order_restriction values('MOC','M','Market on close')
go
insert into tt_order_restriction values('MOO','O','Market on open order')
go
insert into tt_order_restriction values('MV','V','Minimum volume order')
go
insert into tt_order_restriction values('Stop','S','Stop')
go
insert into tt_order_restriction values('Volatility','Y','Volatility')
go
insert into tt_order_restriction values('LOO','a','Converts a limit order to market order on market open')
go
insert into tt_order_restriction values('LOC','b','Convert limit orders to market orders on market close')
go
insert into tt_order_restriction values('LTM','c','Limit order converts to market order on market close')
go
insert into tt_order_restriction values('LWMOL','d','Market becomes limit order with limit price as the price at market close')
go



-- Account Types
insert into tt_account_type values('A1',1,'Agent account')
go
insert into tt_account_type values('A2',2,'Agent account')
go
insert into tt_account_type values('A3',3,'Agent account')
go
insert into tt_account_type values('G1',4,'Giveup account')
go
insert into tt_account_type values('G2',5,'Giveup account')
go
insert into tt_account_type values('G3',6,'Giveup account')
go
insert into tt_account_type values('M1',7,'MarketMaker account')
go
insert into tt_account_type values('M2',8,'MarketMaker account')
go
insert into tt_account_type values('M3',9,'MarketMaker account')
go
insert into tt_account_type values('P1',10,'Principal account')
go
insert into tt_account_type values('P2',11,'Principal account')
go
insert into tt_account_type values('P3',12,'Principal account')
go
insert into tt_account_type values('U1',13,'Unallocated account')
go
insert into tt_account_type values('U2',14,'Unallocated account')
go
insert into tt_account_type values('U3',15,'Unallocated account')
go

-- Product types

insert into tt_product_type values('*',-1)
go
insert into tt_product_type values('FUTURE',1)
go
insert into tt_product_type values('SPREAD',2)
go
insert into tt_product_type values('OPTION',3)
go
insert into tt_product_type values('STRATEGY',4)
go
insert into tt_product_type values('STOCK',5)
go
insert into tt_product_type values('BOND',6)
go
insert into tt_product_type values('SWAP',7)
go
insert into tt_product_type values('WARRANT',8)
go

-- this is needed for customer default
insert into tt_market (market_id, market_name) values (-1,'*')
go

-- Empty Account required for foreign key constraint
insert into tt_account values(1,now,1,now,1,'');
go

-- For each user, create a "<Default>" customer default rec
insert into tt_customer_default
(cusd_created_datetime,
cusd_created_user_id,
cusd_last_updated_datetime,
cusd_last_updated_user_id,

cusd_user_id,
cusd_customer,
cusd_selected,
cusd_market_id,

cusd_product,
cusd_product_type,
cusd_account_id,
cusd_account_type,

cusd_give_up,
cusd_fft2,
cusd_fft3,
cusd_time_in_force,

cusd_order_type,
cusd_restriction,
cusd_open_close,
cusd_use_max_order_qty,

cusd_max_order_qty)

select 
now,1,now,1,

tt_user.user_id,
'<Default>',
1,
-1,

'*',
'*',
1,
'A1',

'',
'',
'',
'GTD',

'Limit',
'<None>',
'Open',
0,

1
from tt_user;

go

-- add foreign key constraints

alter table tt_customer_default add constraint fk_custd_to_order_restriction foreign key (cusd_restriction) references tt_order_restriction (ordrest_short_description) ON DELETE CASCADE
go

alter table tt_customer_default add constraint fk_custd_to_open_close foreign key (cusd_open_close) references tt_open_close_code (openClose_description) ON DELETE CASCADE
go

alter table tt_customer_default add constraint fk_custd_to_time_in_force foreign key (cusd_time_in_force) references tt_time_in_force (timeInForce_code) ON DELETE CASCADE
go

alter table tt_customer_default add constraint fk_custd_to_order_type foreign key (cusd_order_type) references tt_order_type (ordertype_description) ON DELETE CASCADE
go

alter table tt_customer_default add constraint fk_custd_to_account_type foreign key (cusd_account_type) references tt_account_type (acctType_code) ON DELETE CASCADE
go

alter table tt_customer_default add constraint fk_custd_to_account foreign key (cusd_account_id) references tt_account (acct_id) ON DELETE CASCADE
go

alter table tt_customer_default add constraint fk_custd_to_product_type foreign key (cusd_product_type) references tt_product_type (product_description) ON DELETE CASCADE
go

alter table tt_customer_default add constraint fk_custd_to_market foreign key (cusd_market_id) references tt_market (market_id) ON DELETE CASCADE
go

alter table tt_customer_default add constraint fk_custd_to_user foreign key (cusd_user_id) references tt_user (user_id) ON DELETE CASCADE
go

alter table tt_gateway add constraint fk_gateway_to_market foreign key (gateway_market_id) references tt_market (market_id) ON DELETE CASCADE
go

alter table tt_mgt add constraint fk_mgt_to_gateway foreign key (mgt_gateway_id) references tt_gateway (gateway_id) ON DELETE CASCADE
go

alter table tt_user add constraint fk_user_to_group foreign key (user_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go

alter table tt_user_mgt add constraint fk_user_mgt_to_user foreign key (umgt_user_id) references tt_user (user_id) ON DELETE CASCADE
go

alter table tt_user_mgt add constraint fk_user_mgt_to_mgt foreign key (umgt_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go

alter table tt_user add constraint fk_user_to_country foreign key (user_country_id) references tt_country (country_id) ON DELETE CASCADE
go

alter table tt_user add constraint fk_user_to_state foreign key (user_state_id) references tt_us_state (state_id) ON DELETE CASCADE
go

alter table tt_user add constraint fk_user_to_x_trader_mode foreign key (user_x_trader_mode) references tt_x_trader_mode (x_trader_mode_id) ON DELETE CASCADE
go

update tt_db_version set dbv_version = '007.000.001.000'
go
