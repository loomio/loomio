class AddVolumeOptions < ActiveRecord::Migration
  def change
    add_column :memberships, :volume, :integer, default: DiscussionReader.volumes[:normal], null: false
    add_column :discussion_readers, :volume, :integer, default: nil
    add_column :users, :email_on_participation, :boolean, null: false, default: true
    
    change_column :users, :email_when_proposal_closing_soon, :boolean, default: false, null: false


    Membership.reset_column_information
    DiscussionReader.reset_column_information
    User.reset_column_information

    User.where(email_followed_threads: false).update_all(email_on_participation: false)

    Membership.joins(:user).
                where('users.email_new_discussions_and_proposals = FALSE OR
                       memberships.email_new_discussions_and_proposals = FALSE').
                update_all(volume: Membership.volumes[:quiet])

    Membership.joins(:user).
                where('users.email_new_discussions_and_proposals = TRUE
                       AND memberships.email_new_discussions_and_proposals = TRUE
                      AND NOT (users.email_followed_threads = TRUE
                       AND memberships.following_by_default = TRUE)').
                update_all(volume: Membership.volumes[:normal])

    Membership.joins(:user).
                where('users.email_followed_threads = TRUE
                       AND memberships.following_by_default = TRUE').
                update_all(volume: Membership.volumes[:loud])

    ActiveRecord::Base.connection.execute "UPDATE discussion_readers SET volume = #{DiscussionReader.volumes[:normal]}
                                           WHERE discussion_readers.following IS NOT NULL"

    puts "setting volume to loud for following by email users"
    ActiveRecord::Base.connection.execute "UPDATE discussion_readers SET volume = #{DiscussionReader.volumes[:loud]}
                                           WHERE id IN (SELECT discussion_readers.id
                                                        FROM discussion_readers LEFT OUTER JOIN users ON discussion_readers.user_id = users.id
                                                        WHERE users.email_followed_threads = TRUE and discussion_readers.following = TRUE)"


    puts "emailed_followed_threads count: #{User.where(email_followed_threads: true).count}, email_on_participation count: #{User.where(email_on_participation: true).count}"
    # verify that count of (discussion_readers where users.email_followed_threads = true and following = true)
    #        equals count of (discussion_readers where volume = email)
    #
    following_by_email_count = DiscussionReader.joins('LEFT OUTER JOIN users ON discussion_readers.user_id = users.id').
                                                where('users.email_followed_threads = TRUE AND discussion_readers.following = TRUE').count
    volume_is_loud_count     = DiscussionReader.where(volume: DiscussionReader.volumes[:loud]).count


    puts "total users: #{User.count}"
    puts "folloing by email count: #{following_by_email_count} and volume_is_loud_count: #{volume_is_loud_count}"


    email_new_discussions_memberships_count = Membership.joins(:user).where('users.email_new_discussions_and_proposals = true AND
                                                                             memberships.email_new_discussions_and_proposals = true AND NOT (users.email_followed_threads = TRUE
                       AND memberships.following_by_default = TRUE)').count
    normal_memberships_count = Membership.where(volume: Membership.volumes[:normal]).count

    puts "email_new_discussions_memberships_count: #{email_new_discussions_memberships_count} and normal_memberships_count: #{normal_memberships_count}"

    follow_by_default_and_email_memberships_count = Membership.joins(:user).where('users.email_followed_threads = true and memberships.following_by_default = true').count
    loud_membership_count = Membership.where(volume: Membership.volumes[:loud]).count
    puts "follow_by_default_and_email_memberships_count: #{follow_by_default_and_email_memberships_count} and loud_membership_count: #{loud_membership_count}"



  end
end
