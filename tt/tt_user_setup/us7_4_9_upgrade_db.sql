update tt_db_version set dbv_version = 'converting to 7.4.9'
go

update tt_user set user_xrisk_manual_fills_allowed = CByte(1) where user_xrisk_sods_allowed = CByte(1)
go
update tt_user set user_xrisk_sods_allowed = CByte(1) where user_xrisk_manual_fills_allowed = CByte(1)
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.009.000'
go
