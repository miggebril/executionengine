-- create tables for TT User Setup 7.17.0

create table tt_login_server_settings
(
lss_created_datetime                      datetime     not null,
lss_created_user_id                       int          not null,
lss_last_updated_datetime                 datetime     not null,
lss_last_updated_user_id                  int          not null,
lss_enforce_password_complexity           byte         not null,
lss_minimum_password_length               int          not null,
lss_maximum_password_length               int          not null,
lss_at_least_one_lowercase_letter         byte         not null,
lss_at_least_one_uppercase_letter         byte         not null,
lss_at_least_one_digit                    byte         not null,
lss_at_least_one_non_alnum_char           byte         not null,
lss_enforce_password_expiration           byte         not null,
lss_expiration_period_days                int          not null,
lss_expiration_warning_period_days        int          not null,
lss_reset_password_on_initial_login       byte         not null,
lss_failed_login_attempt_limit            int          not null,
lss_inactivity_period_days                int          not null,
lss_enforce_password_reuse_restriction    byte         not null,
lss_password_history_depth                int          not null,
lss_enforce_ip_login_limit                byte         not null,
lss_seconds_between_logins                int          not null,
lss_enforce_password_locking              byte         not null,
lss_apply_additional_failed_login_msg     byte         not null,
lss_additional_failed_login_msg_text      varchar(255) not null,
lss_initial_guardian_import_done          byte         not null,
lss_use_ttus_risk_versus_guardian_risk    char(1)      not null,
lss_fmds_allowed                          byte         not null,
lss_fmds_primary_ip                       varchar(15)  not null,
lss_fmds_primary_port                     int          not null,
lss_fmds_primary_service                  int          not null,
lss_fmds_primary_timeout_in_secs          int          not null,
lss_fmds_secondary_ip                     varchar(15)  not null,
lss_fmds_secondary_port                   int          not null,
lss_fmds_secondary_service                int          not null,
lss_fmds_secondary_timeout_in_secs        int          not null
)
go

create table tt_x_trader_mode
(
x_trader_mode_id                          int             not null primary key,
x_trader_mode_name                        varchar(20)     not null
)
go

create unique index unique_trader_mode_name on tt_x_trader_mode (x_trader_mode_name)
go

create table tt_country
(
country_id                                int          not null primary key,
country_code                              char(6)      not null,
country_name                              varchar(100) not null
)
go

create unique index unique_country_name on tt_country (country_name)
go
create unique index unique_country_code on tt_country (country_code)
go

create table tt_us_state
(
state_id                                  int          not null primary key,
state_abbrev                              char(6)      not null,
state_long_name                           varchar(100) not null
)
go

create unique index unique_state_abbrev on tt_us_state (state_abbrev)
go

create unique index unique_state_long_name on tt_us_state (state_long_name)
go

create table tt_market
(
market_id                                 counter      not null primary key,
market_name                               varchar(100) not null 
)
go

create unique index unique_market_name on tt_market (market_name)
go

create table tt_gateway
(
gateway_id                                counter      not null primary key,
gateway_name                              varchar(100) not null,
gateway_market_id                         int          not null
)
go

create unique index unique_gateway_name on tt_gateway (gateway_name)
go

create table tt_mgt
(
mgt_id                                    counter      not null primary key,
mgt_created_datetime                      datetime     not null,
mgt_created_user_id                       int          not null,
mgt_last_updated_datetime                 datetime     not null,
mgt_last_updated_user_id                  int          not null,

-- max sizes because of guardian
mgt_member                                varchar(7)   not null,
mgt_group                                 varchar(3)   not null,
mgt_trader                                varchar(11)  not null,
mgt_description                           varchar(11)  not null,

mgt_credit                                int          not null,
mgt_currency                              varchar(3)   not null,
mgt_allow_trading                         byte         not null,
mgt_ignore_pl                             byte         not null,

mgt_risk_on                               byte         not null,
mgt_publish_to_guardian                   byte         not null,
mgt_mgt_key                               varchar(25)  not null,
mgt_password                              varchar(100) not null,
mgt_can_associate_with_user_directly      byte         not null
)
go

create unique index unique_trader on tt_mgt (mgt_mgt_key)
go

create table tt_mgt_gmgt
(
mxg_id                                   counter      not null primary key,
mxg_created_datetime                     datetime     not null,
mxg_created_user_id                      int          not null,
mxg_last_updated_datetime                datetime     not null,
mxg_last_updated_user_id                 int          not null,
mxg_mgt_id                               int          not null,
mxg_gmgt_id                              int          not null
)
go

create unique index unique_mgt_gmgt on tt_mgt_gmgt (mxg_mgt_id, mxg_gmgt_id)
go

create index index_mxg on tt_mgt_gmgt (mxg_gmgt_id)
go

create table tt_product_limit
(
plim_product_limit_id                      counter      not null primary key,
plim_created_datetime                      datetime     not null,
plim_created_user_id                       int          not null,
plim_last_updated_datetime                 datetime     not null,
plim_last_updated_user_id                  int          not null,
plim_gateway_id                            int          not null,
plim_product                               varchar(20)  not null,
plim_product_type                          int          not null,
plim_additional_margin_pct                 int          not null,
plim_max_order_qty                         int          not null,
plim_max_position                          int          not null,
plim_allow_tradeout                        byte         not null,

plim_max_long_short                        int          not null,
plim_product_in_hex                        varchar(40)  not null,
plim_mgt_id                                int          not null
)
go

create unique index index_product_limit_key on tt_product_limit (plim_mgt_id, plim_gateway_id, plim_product_in_hex, plim_product_type)
go


create table tt_gmgt
(
gm_id                                    counter      not null primary key,
gm_created_datetime                      datetime     not null,
gm_created_user_id                       int          not null,
gm_last_updated_datetime                 datetime     not null,
gm_last_updated_user_id                  int          not null,
gm_gateway_id                            int          not null,
gm_member                                varchar(7)   not null,
gm_group                                 varchar(3)   not null,
gm_trader                                varchar(11)  not null,
gm_gateway_mgt_key                       varchar(30)  not null
)
go

-- to handle TTSIM,12,34 versus TTSIM,1,234
create unique index unique_gmgt_gateway_mgt_key on tt_gmgt (gm_gateway_mgt_key)
go

create unique index unique_gmgt_gateway_mgt on tt_gmgt (gm_gateway_id, gm_member, gm_group, gm_trader)
go

-- non unique
create index index_mgt_member_group_trader on tt_gmgt (gm_member, gm_group, gm_trader)
go


create table tt_user_group
(
ugrp_group_id                             counter      not null primary key,
ugrp_created_datetime                     datetime     not null,
ugrp_created_user_id                      int          not null,
ugrp_last_updated_datetime                datetime     not null,
ugrp_last_updated_user_id                 int          not null,
ugrp_name                                 varchar(100) not null
)
go

create unique index unique_ugrp_name on tt_user_group (ugrp_name)
go

create table tt_user
(
user_id                                   counter      not null primary key,

user_created_datetime                     datetime     not null,
user_created_user_id                      int          not null,
user_last_updated_datetime                datetime     not null,
user_last_updated_user_id                 int          not null,

user_group_id                             int          not null,
user_login                                varchar(30)  not null,
user_display_name                         varchar(100) not null,
user_password                             varchar(100) not null,

user_city                                 varchar(50)  not null,
user_postal_code                          varchar(20)  not null,
user_state_id                             int          not null,
user_country_id                           int          not null,

user_status                               int          not null,
user_password_never_expires               byte         not null,
user_must_change_password_next_login      byte         not null,
user_most_recent_password_change_datetime datetime     not null,

user_most_recent_login_datetime           datetime     not null,
user_failed_login_attempts_count          int          not null,
user_def1                                 varchar(50)  not null,
user_def2                                 varchar(50)  not null,

user_def3                                 varchar(50)  not null,
user_enforce_ip_login_limit               byte         not null,
user_ip_login_limit                       int          not null,
user_email                                varchar(100) not null,

user_restrict_customer_default_editing    byte         not null,
user_address                              varchar(50)  not null,
user_phone                                varchar(20)  not null,
user_def4                                 varchar(50)  not null,

user_def5                                 varchar(50)  not null,
user_def6                                 varchar(50)  not null,
user_x_trader_mode                        int          not null,
user_login_attempt_key                    int          not null,

user_fix_adapter_enable_order_logging     byte         not null,
user_fix_adapter_enable_price_logging     byte         not null,
user_fix_adapter_default_editing_allowed  byte         not null,
user_xrisk_sods_allowed                   byte         not null,

user_xrisk_manual_fills_allowed           byte         not null,
user_xrisk_prices_allowed                 byte         not null,
user_xrisk_instant_messages_allowed       byte         not null,
user_cross_orders_allowed                 byte         not null,

user_user_setup_user_type                 int          not null, 
user_smtp_host                            varchar(100) not null,
user_smtp_port                            int          not null,
user_smtp_requires_authentication         byte         not null,

user_smtp_login_user                      varchar(100) not null,
user_smtp_login_password                  varchar(100) not null,
user_smtp_use_ssl                         byte         not null,
user_smtp_from_address                    varchar(100) not null,

user_smtp_subject                         varchar(100) not null,
user_smtp_body                            varchar(255) not null,
user_smtp_include_username_in_message     byte         not null,
user_smtp_enable_settings                 byte         not null,

user_quoting_allowed                      byte         not null,
user_wholesale_trades_allowed             byte         not null,
user_fmds_allowed                         byte         not null

-- in us7_3_0_upgrade_db_sql
-- tt_user add user_credit                int          not null 

--user_currency            varchar(3)   not null
--user_allow_trading       byte         not null
--user_force_logoff_switch byte         not null
--in us7_3_1_upgrade_db.sql:
--user_fix_adapter_role int not null 

--user_cross_orders_cancel_resting byte not null
)
go

create unique index unique_user_login on tt_user (user_login)
go

create table tt_user_setup_user_type
(
utype_id                                  int          not null primary key,
utype_description                         varchar(50)  not null
)
go


create table tt_user_gmgt
(
uxg_user_gmgt_id                         counter      not null primary key,
uxg_created_datetime                     datetime     not null,
uxg_created_user_id                      int          not null,
uxg_last_updated_datetime                datetime     not null,
uxg_last_updated_user_id                 int          not null,
uxg_user_id                              int          not null,
uxg_gmgt_id                               int          not null,
uxg_automatically_login                  byte         not null,
uxg_preferred_ip                         varchar(15)  not null,
uxg_clearing_member                      varchar(11)  not null,
uxg_default_account                      varchar(2)   not null,
uxg_available_to_user                    byte         not null
)
go

create unique index index_uxg_user_id on tt_user_gmgt (uxg_user_id, uxg_gmgt_id)
go

create index index_uxg_gmgt_id on tt_user_gmgt (uxg_gmgt_id)
go


create table tt_password_history
(
password_history_id                       counter      not null primary key,
password_history_user_id                  int          not null,
password_history_created_datetime         datetime     not null,
password_history_password                 varchar(100) not null
)
go

create index index_password_history_user_id on tt_password_history (password_history_user_id)
go

create table tt_db_version
(
dbv_version                               varchar(30)  not null
)
go

create table tt_product_type
(
product_description                       varchar(50) primary key,
product_id                                int not null
)
go

create unique index unique_product_id on tt_product_type (product_id)
go

create table tt_account_type
(
acctType_code                              varchar(2)  not null primary key,
accType_id                                 int not null,
acctType_description                       varchar(19) not null
)
go

create table tt_account
(
acct_id                                   counter      not null primary key,
acct_created_datetime                     datetime     not null,
acct_created_user_id                      int          not null,
acct_last_updated_datetime                datetime     not null,
acct_last_updated_user_id                 int          not null,
acct_name	                              varchar(20)  not null,
acct_name_in_hex                          varchar(40)  not null,
acct_description                          varchar(100) not null,
acct_mgt_id                               int          not null
)
go

create table tt_customer_default
(
cusd_id                                   counter      not null primary key,

cusd_created_datetime                     datetime     not null,
cusd_created_user_id                      int          not null,
cusd_last_updated_datetime                datetime     not null,
cusd_last_updated_user_id                 int          not null,

cusd_user_id                              int          not null,
cusd_customer                             varchar(31)  not null,
cusd_selected                             byte         not null,
cusd_market_id                            int          not null,
cusd_product                              varchar(20)  not null,		

-- ProdIDs - Future, Spread, Option...
cusd_product_type                         varchar(50)   not null,

-- foreign key
cusd_account_id                           int          not null,
cusd_account_type                         varchar(2)   not null,

cusd_give_up                              varchar(255) not null,
cusd_fft2                                 varchar(255) not null,
cusd_fft3                                 varchar(255) not null,

cusd_first_default                        byte         not null,

cusd_product_in_hex                       varchar(40)  not null
)
go

create index index_customer_default_user_id on tt_customer_default (cusd_user_id)
go
create unique index index_customer_default_key on tt_customer_default (cusd_user_id, cusd_customer, cusd_market_id, cusd_product_in_hex, cusd_product_type)
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
acctd_product_type                         varchar(50)   not null,
acctd_account_type                         varchar(2)   not null,
acctd_give_up                              varchar(255) not null,
acctd_fft2                                 varchar(255) not null,
acctd_fft3                                 varchar(255) not null,
acctd_sequence_number                      int          not null
)
go

create index index_account_default_user_id on tt_account_default (acctd_user_id)
go
create unique index index_account_default_key on tt_account_default (acctd_user_id, acctd_account_id, acctd_market_id, acctd_product_type)
go
create unique index index_account_default_user_seq on tt_account_default (acctd_user_id, acctd_sequence_number)
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

create table tt_user_group_permission
(
ugp_id                                   counter      not null primary key,
ugp_created_datetime                     datetime     not null,
ugp_created_user_id                      int          not null,
ugp_last_updated_datetime                datetime     not null,
ugp_last_updated_user_id                 int          not null,
ugp_user_id                              int          not null,
ugp_group_id                             int          not null,
ugp_automatically_add                    byte         not null
) 
go

create unique index index_user_group_permission_user_group on tt_user_group_permission (ugp_user_id, ugp_group_id)
go

create table tt_account_group_permission
(
agp_id                                   counter      not null primary key,
agp_created_datetime                     datetime     not null,
agp_created_user_id                      int          not null,
agp_last_updated_datetime                datetime     not null,
agp_last_updated_user_id                 int          not null,
agp_account_id                           int          not null,
agp_group_id                             int          not null
) 
go

create unique index index_account_group_permission_account_group on tt_account_group_permission (agp_account_id, agp_group_id)
go


create table tt_mgt_group_permission
(
mgp_id                                   counter      not null primary key,
mgp_created_datetime                     datetime     not null,
mgp_created_user_id                      int          not null,
mgp_last_updated_datetime                datetime     not null,
mgp_last_updated_user_id                 int          not null,
mgp_mgt_id                               int          not null,
mgp_group_id                             int          not null
) 
go

create unique index index_mgt_group_permission_mgt_group on tt_mgt_group_permission (mgp_mgt_id, mgp_group_id)
go

-- insert initial data

insert into tt_user_setup_user_type values(0, '')
go
insert into tt_user_setup_user_type values(1, 'Super Admin')
go
insert into tt_user_setup_user_type values(2, 'Group Admin')
go
insert into tt_user_setup_user_type values(3, 'Group Admin (can create non-TTORDS)')
go
insert into tt_user_setup_user_type values(4, 'Password Admin (restricted)')
go
insert into tt_user_setup_user_type values(5, 'Password Admin (all groups)')
go


-- Account Types
-- Keep this in sync with world.h, RUN_TIME_AGILE_ENUM(Account, AGILE_ENUM_SEQ(
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
-- Keep this in sync with world.h, RUN_TIME_AGILE_ENUM( ProdIDs, AGILE_ENUM_SEQ(
-- There is also hardcode in GuardianInterface.cpp to filter out unknown product types.
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
insert into tt_product_type values('ENERGY', 30)
go
insert into tt_product_type values('FOREX', 31)
go
-- 32 intentionally skipped
insert into tt_product_type values('NDF', 33)
go


-- x_trader types
--To create the trade mark symbols
--chr(153)= ?  
--chr(174) = ®
--chr(169): ©s

insert into tt_x_trader_mode values(0,'<Not Specified>')
go
insert into tt_x_trader_mode values(1,'X_TRADER')
go
insert into tt_x_trader_mode values(2,'X_TRADER Pro')
go


-- countries

insert into tt_country values(0,'<None>','<None>')
go
insert into tt_country values(1,'AF','AFGHANISTAN')
go
insert into tt_country values(2,'AX','ALAND ISLANDS')
go
insert into tt_country values(3,'AL','ALBANIA')
go
insert into tt_country values(4,'DZ','ALGERIA')
go
insert into tt_country values(5,'AS','AMERICAN SAMOA')
go
insert into tt_country values(6,'AD','ANDORRA')
go
insert into tt_country values(7,'AO','ANGOLA')
go
insert into tt_country values(8,'AI','ANGUILLA')
go
insert into tt_country values(9,'AQ','ANTARCTICA')
go
insert into tt_country values(10,'AG','ANTIGUA AND BARBUDA')
go
insert into tt_country values(11,'AR','ARGENTINA')
go
insert into tt_country values(12,'AM','ARMENIA')
go
insert into tt_country values(13,'AW','ARUBA')
go
insert into tt_country values(14,'AU','AUSTRALIA')
go
insert into tt_country values(15,'AT','AUSTRIA')
go
insert into tt_country values(16,'AZ','AZERBAIJAN')
go
insert into tt_country values(17,'BS','BAHAMAS')
go
insert into tt_country values(18,'BH','BAHRAIN')
go
insert into tt_country values(19,'BD','BANGLADESH')
go
insert into tt_country values(20,'BB','BARBADOS')
go
insert into tt_country values(21,'BY','BELARUS')
go
insert into tt_country values(22,'BE','BELGIUM')
go
insert into tt_country values(23,'BZ','BELIZE')
go
insert into tt_country values(24,'BJ','BENIN')
go
insert into tt_country values(25,'BM','BERMUDA')
go
insert into tt_country values(26,'BT','BHUTAN')
go
insert into tt_country values(27,'BO','BOLIVIA')
go
insert into tt_country values(28,'BA','BOSNIA AND HERZEGOVINA')
go
insert into tt_country values(29,'BW','BOTSWANA')
go
insert into tt_country values(30,'BV','BOUVET ISLAND')
go
insert into tt_country values(31,'BR','BRAZIL')
go
insert into tt_country values(32,'IO','BRITISH INDIAN OCEAN TERRITORY')
go
insert into tt_country values(33,'BN','BRUNEI DARUSSALAM')
go
insert into tt_country values(34,'BG','BULGARIA')
go
insert into tt_country values(35,'BF','BURKINA FASO')
go
insert into tt_country values(36,'BI','BURUNDI')
go
insert into tt_country values(37,'KH','CAMBODIA')
go
insert into tt_country values(38,'CM','CAMEROON')
go
insert into tt_country values(39,'CA','CANADA')
go
insert into tt_country values(40,'CV','CAPE VERDE')
go
insert into tt_country values(41,'KY','CAYMAN ISLANDS')
go
insert into tt_country values(42,'CF','CENTRAL AFRICAN REPUBLIC')
go
insert into tt_country values(43,'TD','CHAD')
go
insert into tt_country values(44,'CL','CHILE')
go
insert into tt_country values(45,'CN','CHINA')
go
insert into tt_country values(46,'CX','CHRISTMAS ISLAND')
go
insert into tt_country values(47,'CC','COCOS (KEELING) ISLANDS')
go
insert into tt_country values(48,'CO','COLOMBIA')
go
insert into tt_country values(49,'KM','COMOROS')
go
insert into tt_country values(50,'CG','CONGO')
go
insert into tt_country values(51,'CD','CONGO, DEMOCRATIC REPUBLIC OF')
go
insert into tt_country values(52,'CK','COOK ISLANDS')
go
insert into tt_country values(53,'CR','COSTA RICA')
go
insert into tt_country values(54,'CI','COTE D''IVOIRE')
go
insert into tt_country values(55,'HR','CROATIA')
go
insert into tt_country values(56,'CU','CUBA')
go
insert into tt_country values(57,'CY','CYPRUS')
go
insert into tt_country values(58,'CZ','CZECH REPUBLIC')
go
insert into tt_country values(59,'DK','DENMARK')
go
insert into tt_country values(60,'DJ','DJIBOUTI')
go
insert into tt_country values(61,'DM','DOMINICA')
go
insert into tt_country values(62,'DO','DOMINICAN REPUBLIC')
go
insert into tt_country values(63,'EC','ECUADOR')
go
insert into tt_country values(64,'EG','EGYPT')
go
insert into tt_country values(65,'SV','EL SALVADOR')
go
insert into tt_country values(66,'GQ','EQUATORIAL GUINEA')
go
insert into tt_country values(67,'ER','ERITREA')
go
insert into tt_country values(68,'EE','ESTONIA')
go
insert into tt_country values(69,'ET','ETHIOPIA')
go
insert into tt_country values(70,'FK','FALKLAND ISLANDS (MALVINAS)')
go
insert into tt_country values(71,'FO','FAROE ISLANDS')
go
insert into tt_country values(72,'FJ','FIJI')
go
insert into tt_country values(73,'FI','FINLAND')
go
insert into tt_country values(74,'FR','FRANCE')
go
insert into tt_country values(75,'GF','FRENCH GUIANA')
go
insert into tt_country values(76,'PF','FRENCH POLYNESIA')
go
insert into tt_country values(77,'TF','FRENCH SOUTHERN TERRITORIES')
go
insert into tt_country values(78,'GA','GABON')
go
insert into tt_country values(79,'GM','GAMBIA')
go
insert into tt_country values(80,'GE','GEORGIA')
go
insert into tt_country values(81,'DE','GERMANY')
go
insert into tt_country values(82,'GH','GHANA')
go
insert into tt_country values(83,'GI','GIBRALTAR')
go
insert into tt_country values(84,'GR','GREECE')
go
insert into tt_country values(85,'GL','GREENLAND')
go
insert into tt_country values(86,'GD','GRENADA')
go
insert into tt_country values(87,'GP','GUADELOUPE')
go
insert into tt_country values(88,'GU','GUAM')
go
insert into tt_country values(89,'GT','GUATEMALA')
go
insert into tt_country values(90,'GN','GUINEA')
go
insert into tt_country values(91,'GW','GUINEA-BISSAU')
go
insert into tt_country values(92,'GY','GUYANA')
go
insert into tt_country values(93,'HT','HAITI')
go
insert into tt_country values(94,'HM','HEARD AND MCDONALD ISLANDS')
go
insert into tt_country values(95,'VA','VATICAN')
go
insert into tt_country values(96,'HN','HONDURAS')
go
insert into tt_country values(97,'HK','HONG KONG')
go
insert into tt_country values(98,'HU','HUNGARY')
go
insert into tt_country values(99,'IS','ICELAND')
go
insert into tt_country values(100,'IN','INDIA')
go
insert into tt_country values(101,'ID','INDONESIA')
go
insert into tt_country values(102,'IR','IRAN')
go
insert into tt_country values(103,'IQ','IRAQ')
go
insert into tt_country values(104,'IE','IRELAND')
go
insert into tt_country values(105,'IL','ISRAEL')
go
insert into tt_country values(106,'IT','ITALY')
go
insert into tt_country values(107,'JM','JAMAICA')
go
insert into tt_country values(108,'JP','JAPAN')
go
insert into tt_country values(109,'JO','JORDAN')
go
insert into tt_country values(110,'KZ','KAZAKHSTAN')
go
insert into tt_country values(111,'KE','KENYA')
go
insert into tt_country values(112,'KI','KIRIBATI')
go
insert into tt_country values(113,'KP','KOREA (NORTH)')
go
insert into tt_country values(114,'KR','KOREA (SOUTH)')
go
insert into tt_country values(115,'KW','KUWAIT')
go
insert into tt_country values(116,'KG','KYRGYZSTAN')
go
insert into tt_country values(117,'LA','LAOS')
go
insert into tt_country values(118,'LV','LATVIA')
go
insert into tt_country values(119,'LB','LEBANON')
go
insert into tt_country values(120,'LS','LESOTHO')
go
insert into tt_country values(121,'LR','LIBERIA')
go
insert into tt_country values(122,'LY','LIBYA')
go
insert into tt_country values(123,'LI','LIECHTENSTEIN')
go
insert into tt_country values(124,'LT','LITHUANIA')
go
insert into tt_country values(125,'LU','LUXEMBOURG')
go
insert into tt_country values(126,'MO','MACAO')
go
insert into tt_country values(127,'MK','MACEDONIA')
go
insert into tt_country values(128,'MG','MADAGASCAR')
go
insert into tt_country values(129,'MW','MALAWI')
go
insert into tt_country values(130,'MY','MALAYSIA')
go
insert into tt_country values(131,'MV','MALDIVES')
go
insert into tt_country values(132,'ML','MALI')
go
insert into tt_country values(133,'MT','MALTA')
go
insert into tt_country values(134,'MH','MARSHALL ISLANDS')
go
insert into tt_country values(135,'MQ','MARTINIQUE')
go
insert into tt_country values(136,'MR','MAURITANIA')
go
insert into tt_country values(137,'MU','MAURITIUS')
go
insert into tt_country values(138,'YT','MAYOTTE')
go
insert into tt_country values(139,'MX','MEXICO')
go
insert into tt_country values(140,'FM','MICRONESIA')
go
insert into tt_country values(141,'MD','MOLDOVA')
go
insert into tt_country values(142,'MC','MONACO')
go
insert into tt_country values(143,'MN','MONGOLIA')
go
insert into tt_country values(144,'MS','MONTSERRAT')
go
insert into tt_country values(145,'MA','MOROCCO')
go
insert into tt_country values(146,'MZ','MOZAMBIQUE')
go
insert into tt_country values(147,'MM','MYANMAR')
go
insert into tt_country values(148,'NA','NAMIBIA')
go
insert into tt_country values(149,'NR','NAURU')
go
insert into tt_country values(150,'NP','NEPAL')
go
insert into tt_country values(151,'NL','NETHERLANDS')
go
insert into tt_country values(152,'AN','NETHERLANDS ANTILLES')
go
insert into tt_country values(153,'NC','NEW CALEDONIA')
go
insert into tt_country values(154,'NZ','NEW ZEALAND')
go
insert into tt_country values(155,'NI','NICARAGUA')
go
insert into tt_country values(156,'NE','NIGER')
go
insert into tt_country values(157,'NG','NIGERIA')
go
insert into tt_country values(158,'NU','NIUE')
go
insert into tt_country values(159,'NF','NORFOLK ISLAND')
go
insert into tt_country values(160,'MP','NORTHERN MARIANA ISLANDS')
go
insert into tt_country values(161,'NO','NORWAY')
go
insert into tt_country values(162,'OM','OMAN')
go
insert into tt_country values(163,'PK','PAKISTAN')
go
insert into tt_country values(164,'PW','PALAU')
go
insert into tt_country values(165,'PS','PALESTINIAN TERRITORY, OCCUPIED')
go
insert into tt_country values(166,'PA','PANAMA')
go
insert into tt_country values(167,'PG','PAPUA NEW GUINEA')
go
insert into tt_country values(168,'PY','PARAGUAY')
go
insert into tt_country values(169,'PE','PERU')
go
insert into tt_country values(170,'PH','PHILIPPINES')
go
insert into tt_country values(171,'PN','PITCAIRN')
go
insert into tt_country values(172,'PL','POLAND')
go
insert into tt_country values(173,'PT','PORTUGAL')
go
insert into tt_country values(174,'PR','PUERTO RICO')
go
insert into tt_country values(175,'QA','QATAR')
go
insert into tt_country values(176,'RE','REUNION')
go
insert into tt_country values(177,'RO','ROMANIA')
go
insert into tt_country values(178,'RU','RUSSIAN FEDERATION')
go
insert into tt_country values(179,'RW','RWANDA')
go
insert into tt_country values(180,'SH','SAINT HELENA')
go
insert into tt_country values(181,'KN','SAINT KITTS AND NEVIS')
go
insert into tt_country values(182,'LC','SAINT LUCIA')
go
insert into tt_country values(183,'PM','SAINT PIERRE AND MIQUELON')
go
insert into tt_country values(184,'VC','SAINT VINCENT AND GRENADINES')
go
insert into tt_country values(185,'WS','SAMOA')
go
insert into tt_country values(186,'SM','SAN MARINO')
go
insert into tt_country values(187,'ST','SAO TOME AND PRINCIPE')
go
insert into tt_country values(188,'SA','SAUDI ARABIA')
go
insert into tt_country values(189,'SN','SENEGAL')
go
insert into tt_country values(190,'RS','SERBIA')
go
insert into tt_country values(191,'SC','SEYCHELLES')
go
insert into tt_country values(192,'SL','SIERRA LEONE')
go
insert into tt_country values(193,'SG','SINGAPORE')
go
insert into tt_country values(194,'SK','SLOVAKIA')
go
insert into tt_country values(195,'SI','SLOVENIA')
go
insert into tt_country values(196,'SB','SOLOMON ISLANDS')
go
insert into tt_country values(197,'SO','SOMALIA')
go
insert into tt_country values(198,'ZA','SOUTH AFRICA')
go
insert into tt_country values(199,'GS','SOUTH. GEORGIA AND S. SANDWICH ISLANDS')
go
insert into tt_country values(200,'ES','SPAIN')
go
insert into tt_country values(201,'LK','SRI LANKA')
go
insert into tt_country values(202,'SD','SUDAN')
go
insert into tt_country values(203,'SR','SURINAME')
go
insert into tt_country values(204,'SJ','SVALBARD AND JAN MAYEN')
go
insert into tt_country values(205,'SZ','SWAZILAND')
go
insert into tt_country values(206,'SE','SWEDEN')
go
insert into tt_country values(207,'CH','SWITZERLAND')
go
insert into tt_country values(208,'SY','SYRIAN ARAB REPUBLIC')
go
insert into tt_country values(209,'TW','TAIWAN, PROVINCE OF CHINA')
go
insert into tt_country values(210,'TJ','TAJIKISTAN')
go
insert into tt_country values(211,'TZ','TANZANIA')
go
insert into tt_country values(212,'TH','THAILAND')
go
insert into tt_country values(213,'TL','TIMOR-LESTE')
go
insert into tt_country values(214,'TG','TOGO')
go
insert into tt_country values(215,'TK','TOKELAU')
go
insert into tt_country values(216,'TO','TONGA')
go
insert into tt_country values(217,'TT','TRINIDAD AND TOBAGO')
go
insert into tt_country values(218,'TN','TUNISIA')
go
insert into tt_country values(219,'TR','TURKEY')
go
insert into tt_country values(220,'TM','TURKMENISTAN')
go
insert into tt_country values(221,'TC','TURKS AND CAICOS ISLANDS')
go
insert into tt_country values(222,'TV','TUVALU')
go
insert into tt_country values(223,'UG','UGANDA')
go
insert into tt_country values(224,'UA','UKRAINE')
go
insert into tt_country values(225,'AE','UNITED ARAB EMIRATES')
go
insert into tt_country values(226,'GB','UNITED KINGDOM')
go
insert into tt_country values(227,'US','UNITED STATES')
go
insert into tt_country values(228,'UM','UNITED STATES MINOR OUTLYING ISLANDS')
go
insert into tt_country values(229,'UY','URUGUAY')
go
insert into tt_country values(230,'UZ','UZBEKISTAN')
go
insert into tt_country values(231,'VU','VANUATU')
go
insert into tt_country values(232,'VE','VENEZUELA')
go
insert into tt_country values(233,'VN','VIET NAM')
go
insert into tt_country values(234,'VG','VIRGIN ISLANDS, BRITISH')
go
insert into tt_country values(235,'VI','VIRGIN ISLANDS, U.S.')
go
insert into tt_country values(236,'WF','WALLIS AND FUTUNA')
go
insert into tt_country values(237,'EH','WESTERN SAHARA')
go
insert into tt_country values(238,'YE','YEMEN')
go
insert into tt_country values(239,'ZM','ZAMBIA')
go
insert into tt_country values(240,'ZW','ZIMBABWE')
go
insert into tt_country values(241,'ME','MONTENEGRO')
go
insert into tt_country values(242,'GG','GUERNSEY')
go
insert into tt_country values(243,'IM','ISLE OF MAN')
go
insert into tt_country values(244,'JE','JERSEY')
go


-- states


insert into tt_us_state values(0,'<None>','<None>')
go
insert into tt_us_state values(1,'AK','Alaska')
go
insert into tt_us_state values(2,'AL','Alabama')
go
insert into tt_us_state values(3,'AR','Arkansas')
go
insert into tt_us_state values(4,'AZ','Arizona')
go
insert into tt_us_state values(5,'CA','California')
go
insert into tt_us_state values(6,'CO','Colorado')
go
insert into tt_us_state values(7,'CT','Connecticut')
go
insert into tt_us_state values(8,'DC','District of Columbia')
go
insert into tt_us_state values(9,'DE','Delaware')
go
insert into tt_us_state values(10,'FL','Florida')
go
insert into tt_us_state values(11,'GA','Georgia')
go
insert into tt_us_state values(12,'HI','Hawaii')
go
insert into tt_us_state values(13,'IA','Iowa')
go
insert into tt_us_state values(14,'ID','Idaho')
go
insert into tt_us_state values(15,'IL','Illinois')
go
insert into tt_us_state values(16,'IN','Indiana')
go
insert into tt_us_state values(17,'KS','Kansas')
go
insert into tt_us_state values(18,'KY','Kentucky')
go
insert into tt_us_state values(19,'LA','Louisiana')
go
insert into tt_us_state values(20,'MA','Massachusetts')
go
insert into tt_us_state values(21,'MD','Maryland')
go
insert into tt_us_state values(22,'ME','Maine')
go
insert into tt_us_state values(23,'MI','Michigan')
go
insert into tt_us_state values(24,'MN','Minnesota')
go
insert into tt_us_state values(25,'MO','Missouri')
go
insert into tt_us_state values(26,'MS','Mississippi')
go
insert into tt_us_state values(27,'MT','Montana')
go
insert into tt_us_state values(28,'NC','North Carolina')
go
insert into tt_us_state values(29,'ND','North Dakota')
go
insert into tt_us_state values(30,'NE','Nebraska')
go
insert into tt_us_state values(31,'NH','New Hampshire')
go
insert into tt_us_state values(32,'NJ','New Jersey')
go
insert into tt_us_state values(33,'NM','New Mexico')
go
insert into tt_us_state values(34,'NV','Nevada')
go
insert into tt_us_state values(35,'NY','New York')
go
insert into tt_us_state values(36,'OH','Ohio')
go
insert into tt_us_state values(37,'OK','Oklahoma')
go
insert into tt_us_state values(38,'OR','Oregon')
go
insert into tt_us_state values(39,'PA','Pennsylvania')
go
insert into tt_us_state values(40,'RI','Rhode Island')
go
insert into tt_us_state values(41,'SC','South Carolina')
go
insert into tt_us_state values(42,'SD','South Dakota')
go
insert into tt_us_state values(43,'TN','Tennessee')
go
insert into tt_us_state values(44,'TX','Texas')
go
insert into tt_us_state values(45,'UT','Utah')
go
insert into tt_us_state values(46,'VA','Virginia')
go
insert into tt_us_state values(47,'VT','Vermont')
go
insert into tt_us_state values(48,'WA','Washington')
go
insert into tt_us_state values(49,'WI','Wisconsin')
go
insert into tt_us_state values(50,'WV','West Virginia')
go
insert into tt_us_state values(51,'WY','Wyoming')
go
insert into tt_us_state values(52,'AS','American Samoa')
go
insert into tt_us_state values(53,'FM','Micronesia')
go
insert into tt_us_state values(54,'GU','Guam')
go
insert into tt_us_state values(55,'MH','Marshall Islands')
go
insert into tt_us_state values(56,'MP','Northern Mariana Islands')
go
insert into tt_us_state values(57,'PW','Palau')
go
insert into tt_us_state values(58,'PR','Puerto Rico')
go
insert into tt_us_state values(59,'VI','Virgin Islands')
go
insert into tt_us_state values(61,'AA','Armed Forces Americas')
go
insert into tt_us_state values(63,'AE','Armed Forces Europe')
go
insert into tt_us_state values(65,'AP','Armed Forces Pacific')
go


-- this is needed for customer default
insert into tt_market (market_id, market_name) values (-1,'*')
go

-- this is needed for product groups
insert into tt_market (market_id, market_name) values (32,'ICE_IPE')
go
insert into tt_market (market_id, market_name) values (7,'CME')
go
insert into tt_market (market_id, market_name) values (6,'CBOT')
go


-- this is needed for trade filter
insert into tt_gateway (gateway_id, gateway_name, gateway_market_id) values (-1,'*',-1) 
go

-- User Group
insert into tt_user_group values (1, now, 1, now, 1, '<General>')
go



-- for accounts fk constraint
insert into tt_mgt values(0,now,1,now,1,
'<None>','','','<None>',
0,'USD',0,0,0,0,'<None>', '',0)
go

--blank account
insert into tt_account values(1,now,1,now,1,'','','',0)
go



-- The User Setup Server (aka login server) settings


insert into tt_login_server_settings
(
lss_created_datetime,
lss_created_user_id,
lss_last_updated_datetime,
lss_last_updated_user_id,

lss_enforce_password_complexity,
lss_minimum_password_length,
lss_maximum_password_length,
lss_at_least_one_lowercase_letter,

lss_at_least_one_uppercase_letter,
lss_at_least_one_digit,
lss_at_least_one_non_alnum_char,
lss_enforce_password_expiration,

lss_expiration_period_days,
lss_expiration_warning_period_days,
lss_reset_password_on_initial_login,
lss_failed_login_attempt_limit,

lss_inactivity_period_days,
lss_enforce_password_reuse_restriction,
lss_password_history_depth,
lss_enforce_ip_login_limit,

lss_seconds_between_logins,
lss_enforce_password_locking,

lss_apply_additional_failed_login_msg,
lss_additional_failed_login_msg_text,

lss_initial_guardian_import_done,
lss_use_ttus_risk_versus_guardian_risk,

lss_fmds_allowed,

lss_fmds_primary_ip,
lss_fmds_primary_port,
lss_fmds_primary_service,
lss_fmds_primary_timeout_in_secs,

lss_fmds_secondary_ip,
lss_fmds_secondary_port,
lss_fmds_secondary_service,
lss_fmds_secondary_timeout_in_secs
)
values
(now,1,now,1,
0,6,20,0,
0,0,0,0,
90,3,1,3,
30,0,3,0,
12,0,
0,"<Any text, e.g., For assistance, please contact Trader Support at 1-555-555-HELP or email help@example.com>",
0,' ',
1,
'',10200,250,30,
'',0,0,0
)
go


insert into tt_db_version values('007.002.000.000')
go


-- add foreign key constraints

alter table tt_account add constraint fk_account_to_mgt foreign key (acct_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_account foreign key (acctd_account_id) references tt_account (acct_id) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_account_type foreign key (acctd_account_type) references tt_account_type (acctType_code) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_market foreign key (acctd_market_id) references tt_market (market_id) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_product_type foreign key (acctd_product_type) references tt_product_type (product_description) ON DELETE CASCADE
go
alter table tt_account_default add constraint fk_acctd_to_user foreign key (acctd_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_account foreign key (cusd_account_id) references tt_account (acct_id) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_account_type foreign key (cusd_account_type) references tt_account_type (acctType_code) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_market foreign key (cusd_market_id) references tt_market (market_id) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_product_type foreign key (cusd_product_type) references tt_product_type (product_description) ON DELETE CASCADE
go
alter table tt_customer_default add constraint fk_custd_to_user foreign key (cusd_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_gateway add constraint fk_gateway_to_market foreign key (gateway_market_id) references tt_market (market_id) ON DELETE CASCADE
go
alter table tt_gmgt add constraint fk_gmgt_to_gateway foreign key (gm_gateway_id) references tt_gateway (gateway_id) ON DELETE CASCADE
go
alter table tt_password_history add constraint fk_password_history_to_user foreign key (password_history_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_product_limit add constraint fk_product_limit_to_gateway foreign key (plim_gateway_id) references tt_gateway (gateway_id) ON DELETE CASCADE
go
alter table tt_product_limit add constraint fk_product_limit_to_mgt foreign key (plim_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go
alter table tt_product_limit add constraint fk_product_limit_to_product_type foreign key (plim_product_type) references tt_product_type (product_id) ON DELETE CASCADE
go
alter table tt_mgt_gmgt add constraint fk_mgt_gmgt_to_gmgt foreign key (mxg_gmgt_id) references tt_gmgt (gm_id) ON DELETE CASCADE
go
alter table tt_mgt_gmgt add constraint fk_mgt_gmgt_to_mgt foreign key (mxg_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_country foreign key (user_country_id) references tt_country (country_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_group foreign key (user_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_state foreign key (user_state_id) references tt_us_state (state_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_x_trader_mode foreign key (user_x_trader_mode) references tt_x_trader_mode (x_trader_mode_id) ON DELETE CASCADE
go
alter table tt_user add constraint fk_user_to_user_setup_user_type foreign key (user_user_setup_user_type) references tt_user_setup_user_type (utype_id) ON DELETE CASCADE
go
alter table tt_user_gmgt add constraint fk_user_gmgt_to_gmgt foreign key (uxg_gmgt_id) references tt_gmgt (gm_id) ON DELETE CASCADE
go
alter table tt_user_gmgt add constraint fk_user_gmgt_to_user foreign key (uxg_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_user_group_permission add constraint fk_user_group_permission_to_user foreign key (ugp_user_id) references tt_user (user_id) ON DELETE CASCADE
go
alter table tt_user_group_permission add constraint fk_user_group_permission_to_group foreign key (ugp_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go
alter table tt_account_group_permission add constraint fk_account_group_permission_to_account foreign key (agp_account_id) references tt_account (acct_id) ON DELETE CASCADE
go
alter table tt_account_group_permission add constraint fk_account_group_permission_to_group foreign key (agp_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go
alter table tt_mgt_group_permission add constraint fk_mgt_group_permission_to_mgt foreign key (mgp_mgt_id) references tt_mgt (mgt_id) ON DELETE CASCADE
go
alter table tt_mgt_group_permission add constraint fk_mgt_group_permission_to_group foreign key (mgp_group_id) references tt_user_group (ugrp_group_id) ON DELETE CASCADE
go

#include us7_3_0_upgrade_db.sql
#include us7_3_1_upgrade_db.sql
#include us7_3_2_upgrade_db.sql
#include us7_3_3_upgrade_db.sql
#include us7_4_0_upgrade_db.sql
#include us7_4_1_upgrade_db.sql
#include us7_4_2_upgrade_db.sql
#include us7_4_3_upgrade_db.sql
#include us7_4_6_upgrade_db.sql
#include us7_4_7_upgrade_db.sql
#include us7_4_8_upgrade_db.sql
#include us7_4_9_upgrade_db.sql
#include us7_4_10_upgrade_db.sql
#include us7_4_11_upgrade_db.sql
#include us7_4_12_upgrade_db.sql
#include us7_4_13_upgrade_db.sql
#include us7_4_14_upgrade_db.sql
#include us7_4_15_upgrade_db.sql
#include us7_4_16_upgrade_db.sql
#include us7_4_30_upgrade_db.sql
#include us7_4_31_upgrade_db.sql
#include us7_4_32_upgrade_db.sql
#include us7_4_40_upgrade_db.sql
#include us7_4_41_upgrade_db.sql
#include us7_4_42_upgrade_db.sql
#include us7_4_43_upgrade_db.sql
#include us7_17_0_upgrade_db.sql
#include us7_17_10_upgrade_db.sql
#include us7_17_11_upgrade_db.sql
#include us7_17_12_upgrade_db.sql
#include us7_17_13_upgrade_db.sql
#include us7_17_20_upgrade_db.sql
#include us7_17_21_upgrade_db.sql
#include us7_17_22_upgrade_db.sql
#include us7_17_23_upgrade_db.sql
#include us7_17_24_upgrade_db.sql
#include us7_17_30_upgrade_db.sql
#include us7_17_31_upgrade_db.sql
#include us7_17_40_upgrade_db.sql
#include us7_17_41_upgrade_db.sql
#include us7_17_42_upgrade_db.sql
#include us7_17_50_upgrade_db.sql
#include us7_17_51_upgrade_db.sql
#include us7_17_60_upgrade_db.sql
#include us7_17_61_upgrade_db.sql
#include us7_17_62_upgrade_db.sql
#include us7_17_63_upgrade_db.sql
#include us7_17_64_upgrade_db.sql
#include us7_17_66_upgrade_db.sql
#include us7_17_67_upgrade_db.sql
#include us7_17_68_upgrade_db.sql
#include us7_17_69_upgrade_db.sql
#include us7_17_70_upgrade_db.sql
#include us7_17_71_upgrade_db.sql
#include us7_17_72_upgrade_db.sql
#include us7_17_73_upgrade_db.sql
#include us7_17_80_upgrade_db.sql
#include us7_17_81_upgrade_db.sql
#include us7_17_82_upgrade_db.sql
#include us7_17_83_upgrade_db.sql
#include us7_17_84_upgrade_db.sql
#include us7_17_85_upgrade_db.sql
#include us7_17_86_upgrade_db.sql
#include us7_17_87_upgrade_db.sql

-- The TTSYSTEM user
#include us70_re_insert_TTSYSTEM_user.sql
