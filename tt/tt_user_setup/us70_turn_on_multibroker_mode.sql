update tt_login_server_settings set lss_multibroker_mode = 1
go

-- rename <General< group
update tt_user_group set ugrp_name = 'Trading Technologies' where ugrp_name = '<General>'
go

-- set on/off server-side diagnostics
update tt_login_server_settings set
lss_enable_automatic_diagnostic_A = 0,
lss_enable_automatic_diagnostic_B = 0,
lss_enable_automatic_diagnostic_C = 0,
lss_enable_automatic_diagnostic_D = 0,
lss_enable_automatic_diagnostic_E = 0,

lss_enable_automatic_diagnostic_F = 0,
lss_enable_automatic_diagnostic_G = 0,
lss_enable_automatic_diagnostic_H = 0,
lss_enable_automatic_diagnostic_I = 0,
lss_enable_automatic_diagnostic_J = 0,

lss_enable_automatic_diagnostic_K = 0,
lss_enable_automatic_diagnostic_L = 0,
lss_enable_automatic_diagnostic_M = 0,
lss_enable_automatic_diagnostic_N = 0,
lss_enable_automatic_diagnostic_O = 0,

lss_enable_automatic_diagnostic_P = 0,
lss_enable_automatic_diagnostic_Q = 0,
lss_enable_automatic_diagnostic_R = 0,
lss_enable_automatic_diagnostic_S = 0,
lss_enable_automatic_diagnostic_T = 0,

lss_enable_automatic_diagnostic_U = 0,
lss_enable_automatic_diagnostic_V = 0,
lss_enable_automatic_diagnostic_W = 0,
lss_enable_automatic_diagnostic_X = 0,
lss_enable_automatic_diagnostic_Y = 0,

lss_enable_automatic_diagnostic_Z = 0,
lss_enable_diagnostics = 0
go


-- set all users to XT Pro mode, the only acceptable option
update tt_user set user_x_trader_mode = 2
go


-- remove invalid XT modes in mb mode
delete from tt_x_trader_mode where x_trader_mode_id = 0
go

DELETE *
FROM tt_market_product_group
WHERE mkpg_market_id = 6
go

UPDATE tt_login_server_settings
SET lss_enforce_ip_login_limit = CByte( 1 )
go