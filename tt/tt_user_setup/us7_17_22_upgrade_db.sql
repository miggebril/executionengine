update tt_db_version set dbv_version = 'converting to 7.17.22'
go

update tt_market_product_group set mkpg_product_group = 'IDEM' where mkpg_market_id = 99 and mkpg_product_group_id = 73
go

insert into tt_market_product_group
    ( mkpg_created_datetime, mkpg_created_user_id, mkpg_last_updated_datetime, mkpg_last_updated_user_id,
      mkpg_market_id, mkpg_product_group_id, mkpg_product_group )
    values ( now, 0, now, 0, 99, 90, 'IDEX' )
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.022.000'
go
