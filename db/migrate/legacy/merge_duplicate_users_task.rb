class MergeDuplicateUsersTask
  def self.print_stats
    puts "users: #{User.count}"
    puts "email_verified users: #{User.where(email_verified: true).count}"
    puts "email_not_verified users: #{User.where(email_verified: false).count}"
    puts "verified users with unverified dupes: #{verified_users_with_dupes.count}"

    unique_emails = User.pluck("lower(email)").uniq
    puts "unique emails: #{unique_emails.size}"

    puts "sql"
    sql_unique_verified_count = User.select("distinct(lower(email))").where(email_verified: true).count
    sql_unique_unverified_count = User.select("distinct(lower(email))").where(email_verified: false).count
    puts "unique verified emails: #{sql_unique_verified_count}"
    puts "unique unverified emails: #{sql_unique_unverified_count}"
    puts "unique unverified emails (minus verified): #{unqiue_unverified_users_minus_verified.pluck(:email).count}"

    puts "ruby"
    ruby_unique_verified_emails = User.where(email_verified: true).pluck("lower(email)").uniq
    ruby_unique_unverified_emails = User.where(email_verified: false).pluck('lower(email)').uniq
    ruby_unique_unverified_emails_minus_verified = ruby_unique_unverified_emails - ruby_unique_verified_emails
    puts "unique verified emails: #{ruby_unique_verified_emails.size}"
    puts "unique unverified emails: #{ruby_unique_unverified_emails.size}"
    puts "unique unique_unverified_emails_minus_verified: #{ruby_unique_unverified_emails_minus_verified.size}"
  end

  def self.verified_users_with_dupes
    User.joins("INNER JOIN users unverified ON users.email = unverified.email")
        .where("users.email_verified = true AND unverified.email_verified=false").distinct
  end

  def self.unqiue_unverified_users_minus_verified
    # get list of unqiue emails of users with unverified_emails , diff against verified emails uniq list.
    # select the user with the min id in each dupe situation

    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS verified_emails")
    ActiveRecord::Base.connection.execute("SELECT lower(email) as email INTO TEMPORARY verified_emails FROM users WHERE email_verified = true")

    User.select('distinct on (users.email) *, users.email')
        .joins('LEFT OUTER JOIN verified_emails ON lower(users.email) = verified_emails.email')
        .where('users.email_verified = false AND verified_emails.email is null')
        .order("users.email, id")
  end

  def self.merge_verified
    ActiveRecord::Base.logger.level = 1
    ActiveRecord::Base.transaction do
      verified_users_with_dupes.pluck('lower(users.email)').uniq
      count = 0
      puts "merge verified:"
      verified_users_with_dupes.where(email_verified: true).find_each do |user|
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
      unqiue_unverified_users_minus_verified.where(email_verified: false).each do |user|
        puts count.to_s if (count += 1) % 100 == 0
        merge_dupes(user)
      end
      puts "done"
    end
  end

  def self.merge_dupes(original_user)
    duplicate_users = User.where(email: original_user.email.downcase).where(email_verified: false).where("id != ?", original_user.id)
    duplicate_user_ids = duplicate_users.pluck(:id)
    # raise "too many dupe user ids #{duplicate_user_ids.size} #{original_user.email}" if duplicate_user_ids.size > 100 and original_user.email != "contact@loomio.org"

    original_user_group_ids = Membership.where(user_id: original_user.id).pluck(:group_id)
    deleted_dupe_memberships_count = Membership.where(user_id: duplicate_user_ids, group_id: original_user_group_ids).delete_all

    # raise "deleted max dupe memberships #{deleted_dupe_memberships_count} " if deleted_dupe_memberships_count > 100

    taken_group_ids = []
    unique_membership_ids = []
    Membership.where(user_id: duplicate_user_ids).each do |m|
      unless taken_group_ids.include? m.group_id
        taken_group_ids << m.group_id
        unique_membership_ids << m.id
      end
    end

    merged_memberships_count = Membership.where(id: unique_membership_ids).update_all(user_id: original_user.id)
    # raise "merged memberships maxed #{merged_memberships_count}" if merged_memberships_count > 100

    deleted_memberships_count = Membership.where(user_id: duplicate_user_ids).delete_all
    # raise "deleted max memberships #{deleted_memberships_count}" if deleted_memberships_count > 100

    #
    # group_ids_after = original_user.reload.group_ids
    #
    # raise "missing group ids" unless group_ids_before.all? {|id| group_ids_after.include? id }

    updated_comments_count = Comment.where(user_id: duplicate_user_ids).update_all(user_id: original_user.id)
    # raise "max updated comments #{updated_comments_count}" if updated_comments_count > 100

    updated_events_count = Event.where(user_id: duplicate_user_ids).update_all(user_id: original_user.id)
    # raise "updated max events #{updated_events_count}" if updated_events_count > 100

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
