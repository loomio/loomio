class FixAgeIndexOnVotes < ActiveRecord::Migration
  def up
    remove_index :votes, name: 'aged_votes_for_motions'
    execute <<-SQL
      alter table votes
        add constraint vote_age_per_user_per_motion unique (motion_id, user_id, age)
        DEFERRABLE INITIALLY IMMEDIATE;
    SQL
  end

  def down
    execute <<-SQL
      alter table votes
        drop constraint if exists vote_age_per_user_per_motion;
    SQL
  end
end
