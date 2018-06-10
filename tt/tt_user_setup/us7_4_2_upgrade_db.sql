update tt_db_version set dbv_version = 'converting to 7.4.2'
go

-----------------------------------------------------------------------
-- company_market_product
-----------------------------------------------------------------------

alter table tt_company_market_product drop column cmkp_alias
go
alter table tt_company_market_product drop column cmkp_description
go

-----------------------------------------------------------------------
-- customer_default
-----------------------------------------------------------------------

alter table tt_customer_default alter cusd_product varchar(127)
go
alter table tt_customer_default alter cusd_product_in_hex varchar(254)
go


-----------------------------------------------------------------------
-- login_server_settings
-----------------------------------------------------------------------

alter table tt_login_server_settings add lss_primary_currency_abbrev varchar(3) not null
go

update tt_login_server_settings set lss_primary_currency_abbrev = 'USD'
go

-----------------------------------------------------------------------
-- user
-----------------------------------------------------------------------

insert into tt_user_setup_user_type values(12, 'Collect Log Files Only')
go

alter table tt_user add user_non_simulation_allowed byte not null
go
update tt_user set user_non_simulation_allowed = 1
go

alter table tt_user add user_organization varchar(50) not null
go
update tt_user set user_organization = ''
go

update tt_user set user_organization = user_def1 where user_def1 like 'Customer:%'
go
update tt_user set user_organization = user_def2 where user_def2 like 'Customer:%'
go
update tt_user set user_organization = user_def3 where user_def3 like 'Customer:%'
go
update tt_user set user_organization = user_def4 where user_def4 like 'Customer:%'
go
update tt_user set user_organization = user_def5 where user_def5 like 'Customer:%'
go
update tt_user set user_organization = user_def6 where user_def6 like 'Customer:%'
go
update tt_user set user_organization = Mid(user_organization, 10) where user_organization like 'Customer:%'
go

-----------------------------------------------------------------------
-- user_company_permission
-----------------------------------------------------------------------

-- change type from int to byte
alter table tt_user_company_permission drop column ucp_customer_default_editing_allowed
go
alter table tt_user_company_permission add ucp_customer_default_editing_allowed byte not null
go
update tt_user_company_permission set ucp_customer_default_editing_allowed = 1
go

-----------------------------------------------------------------------
-- bvmf participant
-----------------------------------------------------------------------

create table tt_bvmf_participant
(
bvmf_id                                   counter      not null primary key,
bvmf_created_datetime                     datetime     not null,
bvmf_created_user_id                      int          not null,
bvmf_last_updated_datetime                datetime     not null,
bvmf_last_updated_user_id                 int          not null,
bvmf_participant_code                     int          not null,
bvmf_participant_name                     varchar(50)  not null
)
go

create unique index unique_bvmf_participant_code on tt_bvmf_participant(bvmf_participant_code)
go

insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,1,'MAGLIANO S/A CCVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,2,'CORRETORA SOUZA BARROS CAMBIO E TITULOS S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,3,'XP INVESTIMENTOS CCTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,4,'ALFA CCVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,8,'LINK S/A CCTVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,9,'DEUTSCHE BANK-CV S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,10,'SPINELLI S/A CVMC')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,13,'MERRILL LYNCH S/A CTVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,14,'CRUZEIRO DO SUL S/A CVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,15,'INDUSVAL S/A CTVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,16,'J.P. MORGAN CCVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,21,'VOTORANTIM CTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,23,'CONCORDIA S/A CVMCC')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,27,'SANTANDER CCVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,33,'ESCRITORIO LEROSA S/A CORRETORES DE VALORES')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,34,'SCHAHIN CCVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,37,'UM INVESTIMENTOS S/A CTVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,39,'AGORA CTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,40,'MORGAN STANLEY CTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,41,'ING CCT S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,45,'CREDIT SUISSE (BRASIL) S.A. CTVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,47,'SOLIDEZ CCTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,51,'CITIGROUP GLOBAL MARKETS BRASIL CCTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,54,'BES SECURITIES DO BRASIL S/A CCVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,57,'BRASCAN S/A CTV')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,58,'SOCOPA SOCIEDADE CORRETORA PAULISTA S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,59,'SAFRA CORRETORA DE VALORES E CAMBIO LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,63,'NOVINVEST CVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,70,'HSBC CTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,72,'BRADESCO S/A CTVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,74,'COINVALORES CCVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,76,'INTERBOLSA DO BRASIL CCTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,82,'TOV CCTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,83,'MAXIMA S/A CTVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,85,'BTG PACTUAL CTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,86,'WALPIRES S/A CCTVM')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,88,'CM CAPITAL MARKETS CCTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,92,'RENASCENCA DTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,93,'FUTURA CCM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,94,'PIONEER CM E FUTUROS LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,95,'CREDIT SUISSE HEDGING GRIFFO C.V. S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,98,'ALPES CCTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,99,'TENDENCIA CCTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,102,'BANIF CVC S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,104,'DISTRIBUIDORA INTERCAP TVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,105,'FDR CM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,107,'TERRA FUTUROS CM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,110,'SLW CVC LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,114,'ITAU CV S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,115,'HENCORP COMMCOR DTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,119,'BTG PACTUAL CM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,120,'FLOW CCTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,121,'BANCO INTERCAP S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,122,'LIQUIDEZ DTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,123,'BANCO RABOBANK INTERNATIONAL BRASIL S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,126,'BANCO MORGAN STANLEY S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,127,'CONVENCAO S/A CVC')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,129,'PLANNER CV S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,131,'FATOR S/A - CORRETORA DE VALORES')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,133,'DIBRAN DTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,147,'ATIVA S/A CTCV')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,150,'PROSPER S/A CVC')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,158,'LOPEZ LEON BROKERS BRASIL DTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,206,'BANCO J.P.MORGAN S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,227,'GRADUAL CORRET DE CAMBIO TIT E VALS MOB SA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,233,'BANCO ALVORADA S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,234,'CODEPE CORRETORA DE VALORES S/A.')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,238,'GOLDMAN SACHS DO BRASIL CTVM SA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,239,'INTERFLOAT HZ CCTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,244,'DRESDNER BANK BRASIL S/A BANCO MULTIPLO')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,245,'BANCO BRASCAN S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,247,'BANCO CITIBANK S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,248,'ITAU UNIBANCO S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,249,'BANCO FIBRA S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,251,'BANCO BNP PARIBAS BRASIL S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,252,'BANCO ITAU BBA S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,253,'ING BANK N.V.')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,254,'BANCO DO BRASIL S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,255,'M.SAFRA & CO. DTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,259,'HSBC BANK BRASIL S/A BANCO MULTIPLO')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,261,'BANCO BTG PACTUAL S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,264,'BANCO VOTORANTIM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,265,'BTG PACTUAL CM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,269,'BANCO BBM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,271,'GOLDMAN SACHS DO BRASIL BANCO MULTIPLO SA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,277,'BANCO WESTLB DO BRASIL S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,298,'CITIBANK DTVM S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,304,'BANCO SAFRA S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,314,'BANCO CRUZEIRO DO SUL S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,483,'BANCO COMERCIAL E DE INVEST. SUDAMERIS S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,491,'BANCO CAIXA GERAL - BRASIL S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,497,'BANCO BRADESCO S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,564,'NOVA FUTURA DTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,591,'BANCO BARCLAYS S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,622,'BANCO SANTANDER (BRASIL) S.A.')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,639,'BANCO SOCIETE GENERALE BRASIL S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,659,'DEUTSCHE BANK S/A - BANCO ALEMAO')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,713,'BB GESTAO DE RECURSOS DTVM S.A.')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,735,'ICAP DO BRASIL CTVM LTDA')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,833,'BANCO DE INVEST. CREDIT SUISSE (BRASIL) S.A.')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,945,'BANCO BRADESCO BBI S/A')
go
insert into tt_bvmf_participant (bvmf_created_datetime, bvmf_created_user_id, bvmf_last_updated_datetime, bvmf_last_updated_user_id, bvmf_participant_code, bvmf_participant_name) values (now,0,now,0,386,'OCTO CTVM SA')
go


--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.002.000'
go

