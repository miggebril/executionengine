update tt_db_version set dbv_version = 'converting'
go


alter table tt_account_default drop constraint fk_acctd_to_account_type
go

alter table tt_account_default drop constraint fk_acctd_to_account
go

alter table tt_account_default drop constraint fk_acctd_to_product_type
go

alter table tt_account_default drop constraint fk_acctd_to_market
go

alter table tt_account_default drop constraint fk_acctd_to_user
go

alter table tt_user add user_restrict_account_default_editing byte not null 
go



create table tt_account_default
(
acctd_id                                   counter      not null primary key,

acctd_created_datetime                     datetime     not null,
acctd_created_user_id                      int          not null,
acctd_last_updated_datetime                datetime     not null,
acctd_last_updated_user_id                 int          not null,

acctd_user_id                              int          not null,
acctd_account_id                           int          not null,
acctd_market_id                            int          not null,
-- ProdIDs - Future, Spread, Option...
acctd_product_type                         varchar(8)   not null,
acctd_account_type                         varchar(2)   not null,
acctd_give_up                              varchar(255) not null,
acctd_fft2                                 varchar(255) not null,
acctd_fft3                                 varchar(255) not null
)
go

create index index_account_default_user_id on tt_account_default (acctd_user_id)
go

create unique index index_account_default_key on tt_account_default (acctd_user_id , acctd_account_id, acctd_market_id, acctd_product_type)
go


create table tt_ip_address_version
(
ipv_id                                   counter      not null primary key,
ipv_created_datetime                     datetime     not null,
ipv_created_user_id                      int          not null,
ipv_last_updated_datetime                datetime     not null,
ipv_last_updated_user_id                 int          not null,

-- unique key
ipv_ip_address                           varchar(15)  not null,
ipv_version                              varchar(30)  not null,
ipv_tt_product_id                        int          not null,
ipv_user_login                           varchar(30)  not null,
ipv_exe_path                             varchar(255) not null,

-- data
ipv_tt_product_name                      varchar(255) not null,
ipv_update_count                         int          not null
)
go

create unique index index_ip_address_version on tt_ip_address_version 
(
ipv_ip_address,
ipv_version,
ipv_tt_product_id,
ipv_user_login,
ipv_exe_path
) 
go


-- add foreign key constraints


alter table tt_account_default add constraint fk_acctd_to_account_type foreign key (acctd_account_type) references tt_account_type (acctType_code) ON DELETE CASCADE
go

alter table tt_account_default add constraint fk_acctd_to_account foreign key (acctd_account_id) references tt_account (acct_id) ON DELETE CASCADE
go

alter table tt_account_default add constraint fk_acctd_to_product_type foreign key (acctd_product_type) references tt_product_type (product_description) ON DELETE CASCADE
go

alter table tt_account_default add constraint fk_acctd_to_market foreign key (acctd_market_id) references tt_market (market_id) ON DELETE CASCADE
go

alter table tt_account_default add constraint fk_acctd_to_user foreign key (acctd_user_id) references tt_user (user_id) ON DELETE CASCADE
go

alter table tt_user alter user_phone varchar(20) not null
go

update tt_db_version set dbv_version = '007.000.002.000'
go
