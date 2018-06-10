update tt_db_version set dbv_version = 'converting to 7.4.3'
go

-------------------------------------------------------------------------------
-- user
-------------------------------------------------------------------------------

alter table tt_user add user_simulation_allowed byte not null
go
alter table tt_user add user_machine_gun_orders_allowed byte not null
go
alter table tt_user add user_persist_orders_on_eurex int not null
go

update tt_user set
user_simulation_allowed=1,
user_machine_gun_orders_allowed =1,
user_persist_orders_on_eurex = 0
go


--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.003.000'
go
