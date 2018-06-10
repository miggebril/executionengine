update tt_db_version set dbv_version = 'converting to 7.0.3'
go

-- drop the foreign keys so that we can change the field lengths
alter table tt_account_default drop constraint fk_acctd_to_product_type
go

alter table tt_customer_default drop constraint fk_custd_to_product_type
go


-- make the fields bigger
alter table tt_product_type alter product_description varchar(50) 
go

alter table tt_account_default alter acctd_product_type varchar(50) not null
go

alter table tt_customer_default alter cusd_product_type varchar(50) not null
go

-- put the foreign keys back
alter table tt_account_default add constraint fk_acctd_to_product_type foreign key (acctd_product_type) references tt_product_type (product_description) ON DELETE CASCADE
go

alter table tt_customer_default add constraint fk_custd_to_product_type foreign key (cusd_product_type) references tt_product_type (product_description) ON DELETE CASCADE
go




alter table tt_customer_default alter cusd_customer varchar(31) not null
go

alter table tt_customer_default add cusd_first_default byte
go

update tt_customer_default set cusd_first_default = 0
go

update tt_user set user_restrict_account_default_editing = 0
go

alter table tt_user add user_login_attempt_key int
go

update tt_user set user_login_attempt_key = 0
go

alter table tt_account add acct_name_in_hex varchar(40)
go

drop index unique_acct_name on tt_account
go

create unique index unique_acct_name_in_hex on tt_account (acct_name_in_hex)
go

-- for the oldest customer default for each user to be selected
update tt_customer_default
set cusd_selected = 1, cusd_first_default = 1
where cusd_id in 
(select oldest_default_per_user_cusd_id from tt_view_oldest_default_per_user)
go

insert into tt_product_type values('ENERGY', 30)
go
insert into tt_product_type values('FOREX', 31)
go
