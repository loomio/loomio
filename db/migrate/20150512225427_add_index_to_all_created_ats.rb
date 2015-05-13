class AddIndexToAllCreatedAts < ActiveRecord::Migration
  def change
    #remove = %w[announcements campaigns group_setups subscriptions]

    %w[comment_votes
       comments
       discussions
       group_visits
       groups
       invitations
       memberships
       motions
       organisation_visits
       votes].each do |table|
      add_index table, :created_at
    end
  end
end
