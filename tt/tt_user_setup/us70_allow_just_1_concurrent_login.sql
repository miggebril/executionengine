-- Limit each user to just one login
update tt_user set 
user_enforce_ip_login_limit = 1,
user_ip_login_limit = 1

go

-- Tell user setup server to enforce the setting
update tt_login_server_settings set
lss_enforce_ip_login_limit = 1,
lss_seconds_between_logins = 20
