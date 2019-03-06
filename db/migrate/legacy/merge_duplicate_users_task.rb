class MergeDuplicateUsersTask
  def self.print_stats
    puts "users: #{User.count}"
    puts "email_verified users: #{User.where(email_verified: true).count}"
    puts "email_not_verified users: #{User.where(email_verified: false).count}"
    puts "verified users with unverified dupes: #{verified_users_with_dupes.count}"

    puts "unique verified emails: #{User.select("distinct(lower(email))").where(email_verified: true).count}"
    puts "unique unverified emails: #{User.select("distinct(lower(email))").where(email_verified: false).count}"
    puts "unique unverified emails (minus verified): #{unqiue_unverified_users_minus_verified.pluck(:email).count}"
    puts "total unique emails: #{User.select("distinct(lower(email))").count}"
  end

  def self.verified_users_with_dupes
    User.joins("INNER JOIN users unverified ON users.email = unverified.email")
        .where("users.email_verified = true AND unverified.email_verified=false").distinct
  end

  def self.unqiue_unverified_users_minus_verified
    # get list of unqiue emails of users with unverified_emails , diff against verified emails uniq list.
    # select the user with the min id in each dupe situation

    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS verified_emails")
    ActiveRecord::Base.connection.execute("SELECT lower(email) as email INTO TEMPORARY verified_emails FROM users WHERE email_verified = true;")

    User.select('distinct on (lower(users.email)) *')
        .joins('LEFT OUTER JOIN verified_emails ON lower(users.email) = lower(verified_emails.email)')
        .where('users.email_verified = false AND verified_emails.email is null')
        .order("email, id")
  end

  def self.merge_verified
    ActiveRecord::Base.logger.level = 1
    ActiveRecord::Base.transaction do
      verified_user_ids_with_dupes = verified_users_with_dupes.pluck('users.id')
      count = 0
      puts "merge verified:"
      User.where(id: verified_user_ids_with_dupes, email_verified: true).find_each do |user|
        puts count.to_s if (count += 1) % 100 == 0
        merge_dupes(user)
      end
      puts "done"
    end
  end

  def self.merge_unverified
    ActiveRecord::Base.transaction do
      users_with_duplicates = unqiue_unverified_users_minus_verified.pluck('users.id')

      count = 0
      puts "merge unverified:"
      User.where(id: users_with_duplicates, email_verified: false).find_each do |user|
        puts count.to_s if (count += 1) % 100 == 0
        merge_dupes(user)
      end
      puts "done"
    end
  end

  def self.merge_dupes(original_user)
    duplicate_users = User.where(email: original_user.email, email_verified: false).where("id != ?", original_user.id)
    duplicate_user_ids = duplicate_users.pluck(:id)

    # puts "1"

    # maybe make this a background job?
    # group_ids_before = original_user.reload.group_ids
    # original_user_group_ids = membership.where(user_id: original_user.id).pluck(:group_id)
    #
    # Membership.where(user_id: duplicate_user_ids, group_id: original_user_group_ids).delete_all
    #
    # taken_group_ids = []
    # unique_membership_ids = []
    # Membership.where(user_id: duplicate_user_ids).each do |m|
    #   unless taken_group_ids.include? m.group_id
    #     taken_group_ids << m.group_id
    #     unique_membership_ids << m.id
    #   end
    # end
    #
    # Membership.where(id: unique_membership_ids).update_all(user_id: original_user.id)
    # Membership.where(user_id: duplicate_user_ids).delete_all
    #
    # group_ids_after = original_user.reload.group_ids

    # raise "missing group ids" unless group_ids_before.all? {|id| group_ids_after.include? id }

    Comment.where(user_id: duplicate_user_ids).update_all(user_id: original_user.id)
    Event.where(user_id: duplicate_user_ids).update_all(user_id: original_user.id)

    # puts "4"
    duplicate_users.each do |source|
      poll_ids = source.participated_poll_ids & original_user.participated_poll_ids
      Stance.where(participant: source).update_all(participant_id: original_user.id)
      Stance.where(participant: original_user, poll_id: poll_ids).update_all(latest: false)

      Poll.where(id: poll_ids).each do |poll|
        poll.stances.where(participant: original_user)
        .order(created_at: :desc)
        .first
        .update_attribute(:latest, true)
      end
    end

    # puts "5"
    duplicate_users.delete_all
  end


  # tests:
  #   verified user count should stay the same
  #   total unique emails should stay the same
  #   unvierified users will drop

end
