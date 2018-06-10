update tt_db_version set dbv_version = 'converting to 7.4.14'
go

create index index_mgt_member_group_trader on tt_mgt (mgt_member, mgt_group, mgt_trader)
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.014.000'
go
