-- Reset TTSYSTEM user's password to 12345678
-- Reset other fields to their initial state
update tt_user set 
user_password = '77D8ED17B04C7D2881A26647BDF703EB',
user_most_recent_login_datetime = now(),
user_failed_login_attempts_count = 0,
user_must_change_password_next_login = 1,
user_status = 1,
user_user_setup_user_type = 1,
user_password_never_expires = 0,
user_marked_for_deletion_datetime = #1970-01-02 00:00:00#,
user_most_recent_login_datetime_for_inactivity = #1970-01-02 00:00:00#,
user_non_simulation_allowed = 1,
user_2fa_required_mode = 0
where user_login = 'TTSYSTEM'

