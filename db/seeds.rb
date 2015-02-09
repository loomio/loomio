connection = ActiveRecord::Base.connection()
connection.execute <<SQL
	ALTER TABLE votes
	ADD CONSTRAINT vote_age_per_user_per_motion
	UNIQUE USING INDEX vote_age_per_user_per_motion
	DEFERRABLE INITIALLY IMMEDIATE
SQL
