class RemoveEmailNewDiscussionsAndProposalsFromUsersAndMemberships < ActiveRecord::Migration
  def change
    #update memberships to volume = :email where users.email_new_discussions_and_proposals is true and memberships.email_new_discussions_and_proposals is true
    Memberships.joins(:user).
                where('users.email_new_discussions_and_proposals = :true
                       AND memberships.email_new_discussions_and_proposals = :true', {true: true}).
                update_all(volume: Memberships.volume[:email])

    remove_column :users, :email_new_discussions_and_proposals
    remove_column :memberships, :email_new_discussions_and_proposals
  end
end
