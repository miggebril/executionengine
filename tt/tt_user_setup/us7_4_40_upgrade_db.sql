update tt_db_version set dbv_version = 'converting to 7.4.40'
go

-------------------------------------------------------------------------------
--  tt apps
-------------------------------------------------------------------------------


alter table tt_app_version_rule drop constraint fk_app_version_rule_to_app
go

drop table tt_tt_app
go

create table tt_tt_app
(
	ttapp_app_id                            int          not null,
	ttapp_app_name_on_wire                  varchar(50) not null,
	ttapp_core_license_id                   int          not null,
	ttapp_display_order                     int          not null,
	ttapp_display_name                      varchar(50) not null,
	ttapp_display_in_version_rules          byte         not null,
	ttapp_exchange_id                       int          not null,
	ttapp_generate_announce_self            byte         not null,
	ttapp_allow_user_to_create_rule         byte         not null
)
go

create unique index index_ttapp_app_id on tt_tt_app (ttapp_app_id)
go

create unique index index_ttapp_app_name_on_wire on tt_tt_app (ttapp_app_name_on_wire)
go

-- The ttapp_app_name_on_wire column must be the same as MSG_APP #defines in messages.h
-- the ttapp_display_name column can be anything

insert into tt_tt_app values ( 1,'FIX Adapter Drop Copy Server',        38,0,'FIX Adapter Drop Copy Server',       0,0,0,1)
go
insert into tt_tt_app values ( 2,'FIX Adapter Order Routing Server',    40,0,'FIX Adapter Order Routing Server',   0,0,0,1)
go
insert into tt_tt_app values ( 3,'Guardian',                            21,0,'Guardian',                           0,0,1,1)
go
insert into tt_tt_app values ( 4,'GuardianMFC',                         -4,0,'GuardianMFC',                        0,0,1,1)
go
insert into tt_tt_app values ( 5,'TT API',                              51,4,'TT API',                             1,0,1,1)
go
insert into tt_tt_app values ( 6,'X_Risk',                              10,2,'X_RISK',                             1,0,1,1)
go
insert into tt_tt_app values ( 7,'X_Study',                             45,0,'X_STUDY',                            0,0,1,1)
go
insert into tt_tt_app values ( 8,'X_Trader API',                        -8,5,'X_TRADER API',                       1,0,0,1)
go
insert into tt_tt_app values ( 9,'Old apps that don''t report version',  0,1,'Old apps that don''t report version',0,0,0,1)
go
insert into tt_tt_app values (10,'X_Trader',                             8,3,'X_TRADER',                           1,0,0,1)
go
insert into tt_tt_app values (11,'Billing Server',                      10,0,'Billing Server',                     0,79,1,0)
go
insert into tt_tt_app values (12,'FMDS',                                47,0,'FMDS',                               0,0,1,1)
go
insert into tt_tt_app values (13,'HFS',                                 15,0,'HFS',                                0,0,1,1)
go
insert into tt_tt_app values (14,'TT SIM',                             -14,0,'TT SIM',                             0,0,1,1)
go
insert into tt_tt_app values (15,'TTM',                                -15,0,'TTM',                                0,0,1,1)
go
insert into tt_tt_app values (16,'TTUS Admin API',                     -16,0,'TT User Setup API',                  0,0,1,1)
go
insert into tt_tt_app values (17,'TTUS Command Line Client',           -17,0,'TTUS Command Line Client',           0,0,1,1)
go
insert into tt_tt_app values (18,'TTUserSetupClient',                  -18,0,'TT User Setup Client',               0,0,1,1)
go
insert into tt_tt_app values (19,'TT User Setup Server',                 9,0,'TT User Setup Server',               0,79,1,0)
go
insert into tt_tt_app values (20,'FIX Adapter Client',                   0,0,'FIX Adapter Client',                 0,0,0,1)
go

-------------------------------------------------------------------------------
-- Version Rule
-------------------------------------------------------------------------------

-- delete human generated old version rules
delete from tt_app_version_rule where avr_tt_app_id = 9
go

alter table tt_app_version_rule drop constraint fk_app_version_rule_to_app
go

alter table tt_app_version_rule add constraint fk_app_version_rule_to_app foreign key (avr_tt_app_id) references tt_tt_app (ttapp_app_id) ON DELETE CASCADE
go

alter table tt_app_version_rule alter column [avr_version] varchar(50)
go

alter table tt_app_version_rule add avr_user_group_id int not null
go

update tt_app_version_rule set avr_user_group_id = 0
go

drop index index_avr_tt_app on tt_app_version_rule
go

create unique index index_avr_tt_app on tt_app_version_rule (avr_tt_app_id, avr_user_id, avr_user_group_id)
go

UPDATE tt_app_version_rule
SET avr_version = LEFT( avr_version, INSTR( avr_version, ' - ' ) - 1 ) + Chr( 5 ) + RIGHT( avr_version, LEN( avr_version ) - INSTR( avr_version, ' - ' ) - 2 )
WHERE avr_version like '% - %'
go

update tt_app_version_rule set avr_comparison_operator = 'ge' where avr_comparison_operator = 'gt'
go

update tt_app_version_rule set avr_comparison_operator = 'le' where avr_comparison_operator = 'lt'
go


-------------------------------------------------------------------------------
-- blob
-------------------------------------------------------------------------------
-- if data is related to user, and user is deleted, should this data be deleted, if either group/nongroup permissions are other than "-"?
drop table tt_blob
go

create table tt_blob
(
blb_id                                   counter       not null primary key,
blb_created_datetime                     datetime      not null,
blb_created_user_id                      int           not null,
blb_last_updated_datetime                datetime      not null,
blb_last_updated_user_id                 int           not null,
blb_key                                  varchar(64)  not null,
blb_description                          varchar(50)  not null,
blb_group_permission                     char(1)       not null,
blb_nongroup_permission                  char(1)       not null,
blb_data oleobject
)
go

create unique index index_unique_blob_key on tt_blob (blb_key)
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.040.000'
go
