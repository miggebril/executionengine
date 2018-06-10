update tt_db_version set dbv_version = 'converting to 7.4.7'
go



-------------------------------------------------------------------------------
-- user_gmgt
-------------------------------------------------------------------------------

alter table tt_user_gmgt add uxg_operator_id varchar(50) not null default ''
go



--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.007.000'
go
