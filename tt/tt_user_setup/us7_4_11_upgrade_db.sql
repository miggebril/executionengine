update tt_db_version set dbv_version = 'converting to 7.4.11'
go


-------------------------------------------------------------------------------
--  Product Limit
-------------------------------------------------------------------------------

alter table tt_product_limit add plim_prevent_orders_based_on_price_ticks byte not null
go
alter table tt_product_limit add plim_prevent_orders_price_ticks int not null
go
alter table tt_product_limit add plim_enforce_price_limit_on_buysell_only byte not null
go

update tt_product_limit set
  plim_prevent_orders_based_on_price_ticks = 0,
  plim_prevent_orders_price_ticks = 0,
  plim_enforce_price_limit_on_buysell_only = 1
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.004.011.000'
go
