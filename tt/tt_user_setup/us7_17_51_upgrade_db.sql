update tt_db_version set dbv_version = 'converting to 7.17.51'
go

ALTER TABLE tt_company ADD comp_requires_cme_mda BYTE NOT NULL
go

UPDATE tt_company SET comp_requires_cme_mda = CByte(1)
go

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.051.000'
go
