class AddVolumeOptions < ActiveRecord::Migration
  def change
    add_column :memberships, :volume, :integer, default: DiscussionReader.volumes[:normal], null: false
    add_column :discussion_readers, :volume, :integer, default: nil

    Membership.reset_column_information
    DiscussionReader.reset_column_information

    puts "setting volume to normal on all discussion readers"
    ActiveRecord::Base.connection.execute "UPDATE discussion_readers SET volume = #{DiscussionReader.volumes[:normal]}
                                           WHERE discussion_readers.following IS NOT NULL"

    puts "setting volume to email for following by email users"
    ActiveRecord::Base.connection.execute "UPDATE discussion_readers SET volume = #{DiscussionReader.volumes[:email]}
                                           WHERE id IN (SELECT discussion_readers.id
                                                        FROM discussion_readers LEFT OUTER JOIN users ON discussion_readers.user_id = users.id
                                                        WHERE users.email_followed_threads = TRUE and discussion_readers.following = TRUE)"



    # verify that count of (discussion_readers where users.email_followed_threads = true and following = true)
    #        equals count of (discussion_readers where volume = email)
    #
    following_by_email_count = DiscussionReader.joins('LEFT OUTER JOIN users ON discussion_readers.user_id = users.id').
                                                where('users.email_followed_threads = :true AND discussion_readers.following = :true', true: true).count
    volume_is_email_count    = DiscussionReader.where(volume: DiscussionReader.volumes[:email]).count

    puts "folloing by email count: #{following_by_email_count} and volume_is_email_count: #{volume_is_email_count}"

    Membership.where(following_by_default: true).update_all(volume: DiscussionReader.volumes[:email])
    Membership.where(following_by_default: false).update_all(volume: DiscussionReader.volumes[:normal])

    remove_column :memberships, :following_by_default, :boolean
    remove_column :discussion_readers, :following, :boolean

    rename_column :users, :email_followed_threads, :email_on_participation
  end
end
