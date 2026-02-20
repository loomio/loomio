module CleanupService
  def self.delete_orphan_records
    [Group,
     Membership,
     MembershipRequest,
     Discussion,
     Subscription,
     TopicReader,
     Comment,
     Poll,
     PollOption,
     Stance,
     StanceChoice,
     Outcome,
     Event,
     Notification].each do |model|
      count = model.dangling.delete_all
      puts "deleted #{count} dangling #{model.to_s} records"
    end

    PaperTrail::Version.where(item_type: 'Motion').delete_all
    # ActiveStorage::Blob.unattached.where("active_storage_blobs.created_at < ?", 7.days.ago).find_each(&:purge_later)
    
    # ["Comment", "Discussion", "Group", "Membership", "Outcome", "Poll", "Stance", "User"].each do |model|
    #   table = model.pluralize.downcase
    #   # puts PaperTrail::Version.joins("left join #{table} on #{table}.id = item_id and item_type = '#{model}'").where("#{table}.id is null").to_sql
    #   # puts PaperTrail::Version.joins("left join #{table} on #{table}.id = item_id and item_type = '#{model}'").where("#{table}.id is null").count
    #   count = PaperTrail::Version.joins("left join #{table} on #{table}.id = item_id and item_type = '#{model}'").where("#{table}.id is null").delete_all
    #   puts "deleted #{count} dangling #{table} version records"
    # end

    # real delete of dangling active storage objects
    # delete subscription records where no group references them
  end

  DEFAULT_DISCUSSION_TITLES = [
    "How to use Loomio",
    "Welcome! Please introduce yourself",
    "Example Discussion: Welcome and introduction to Loomio",
    "Comment utiliser Loomio",
    "How To Use Loomio",
    "Cómo usar Loomio",
    "Bienvenue ! N'hésitez pas à vous présenter",
    "Bienvenid@! Por favor  preséntate al grupo",
    "Discusión de ejemplo: Bienvenida e introducción a Loomio",
    "Wie man Loomio benutzt",
    "Willkommen! Bitte stelle dich kurz vor",
    "Exemple de Discussion : Bienvenue et introduction sur Loomio",
    "Como utilizar o Loomio",
    "Come usare Loomio",
    "Bem-vindo! Por favor, apresente-se",
  ].freeze

  DEFAULT_POLL_TITLES = [
    "Demonstration proposal",
    "Have any questions about using Loomio?",
    "Proposition de démonstration",
    "We should have a holiday on the moon!",
    "Demonstration proposal: let's go!",
    "Propuesta de demostración",
    "¿Tienes alguna pregunta acerca de cómo usar Loomio?",
    "Demo-Vorschlag",
    "Vous avez des questions sur l'utilisation de Loomio ?",
    "Proposta de demonstração",
  ].freeze

  def self.destroy_unused_trial_groups
    group_ids = unused_trial_group_ids

    if group_ids.empty?
      puts "No unused trial groups to destroy"
      return
    end

    Group.where(id: group_ids).update_all(archived_at: Time.current)

    group_ids.each do |group_id|
      DestroyGroupWorker.perform_async(group_id)
    end

    puts "Enqueued #{group_ids.size} unused trial groups for destruction"
  end

  def self.warn_and_destroy_expired_trial_groups
    group_ids = expired_trial_group_ids

    if group_ids.empty?
      puts "No expired trial groups to warn and destroy"
      return
    end

    Group.where(id: group_ids).find_each do |group|
      group.archive!
      group.admins.each do |admin|
        GroupMailer.trial_expired(group.id, admin.id).deliver_later
      end
      DestroyGroupWorker.perform_in(2.weeks, group.id)
    end

    puts "Warned and enqueued #{group_ids.size} expired trial groups for destruction in 2 weeks"
  end

  def self.destroy_orphan_users
    user_ids = orphan_user_ids

    if user_ids.empty?
      puts "No orphan users to destroy"
      return
    end

    User.where(id: user_ids).find_each do |user|
      DeactivateUserWorker.perform_async(user.id, user.id)
    end

    puts "Enqueued #{user_ids.size} orphan users for deactivation"
  end

  def self.unused_trial_group_ids
    unused_trial_groups_scope.where("groups.created_at < ?", 3.years.ago).pluck(:id)
  end

  def self.expired_trial_group_ids
    unused_trial_groups_scope
      .where("groups.created_at BETWEEN ? AND ?", 3.years.ago, 1.year.ago)
      .order(:created_at)
      .limit(100)
      .pluck(:id)
  end

  def self.orphan_user_ids
    User.where(deactivated_at: nil)
        .where("last_sign_in_at < ?", 1.year.ago)
        .where("NOT EXISTS (SELECT 1 FROM memberships WHERE memberships.user_id = users.id AND memberships.revoked_at IS NULL)")
        .pluck(:id)
  end

  def self.destroy_spam_groups
    group_ids = spam_group_ids

    if group_ids.empty?
      puts "No spam groups to destroy"
      return
    end

    Group.where(id: group_ids).update_all(archived_at: Time.current)

    group_ids.each do |group_id|
      DestroyGroupWorker.perform_async(group_id)
    end

    puts "Enqueued #{group_ids.size} spam groups for destruction"
  end

  def self.spam_group_ids
    ids = Set.new

    # 1. Single-member groups created by users who made 10+ groups in a single day (excluding loomio.org staff)
    spammer_group_ids = ActiveRecord::Base.connection.execute(<<~SQL).map { |r| r['id'] }
      SELECT g.id
      FROM groups g
      JOIN users u ON u.id = g.creator_id
      WHERE g.parent_id IS NULL
        AND g.archived_at IS NULL
        AND u.email NOT LIKE '%@loomio.org'
        AND (SELECT COUNT(*) FROM memberships m WHERE m.group_id = g.id AND m.revoked_at IS NULL) <= 1
        AND (
          SELECT COUNT(*)
          FROM groups g2
          WHERE g2.creator_id = g.creator_id
            AND g2.parent_id IS NULL
            AND g2.archived_at IS NULL
            AND g2.created_at::date = g.created_at::date
        ) >= 10
    SQL
    ids.merge(spammer_group_ids)
    puts "Spam pattern 1 (10+ single-member groups created same day): #{spammer_group_ids.size} groups"

    # 2. Groups with 10+ discussions, 0 comments, and only 1 member
    content_spam_ids = ActiveRecord::Base.connection.execute(<<~SQL).map { |r| r['id'] }
      SELECT g.id
      FROM groups g
      WHERE g.parent_id IS NULL
        AND g.archived_at IS NULL
        AND (SELECT COUNT(*) FROM memberships m WHERE m.group_id = g.id AND m.revoked_at IS NULL) <= 1
        AND (SELECT COUNT(*) FROM discussions d WHERE d.group_id = g.id AND d.discarded_at IS NULL) >= 10
        AND (SELECT COUNT(*) FROM comments c JOIN discussions d ON d.id = c.discussion_id WHERE d.group_id = g.id) = 0
    SQL
    ids.merge(content_spam_ids)
    puts "Spam pattern 2 (10+ discussions, 0 comments, 1 member): #{content_spam_ids.size} groups"

    # 3. Groups containing discussions with spam keywords
    spam_keyword_ids = ActiveRecord::Base.connection.execute(<<~SQL).map { |r| r['id'] }
      SELECT DISTINCT g.id
      FROM groups g
      JOIN discussions d ON d.group_id = g.id
      WHERE g.parent_id IS NULL
        AND g.archived_at IS NULL
        AND d.discarded_at IS NULL
        AND (SELECT COUNT(*) FROM memberships m WHERE m.group_id = g.id AND m.revoked_at IS NULL) <= 3
        AND d.title ~* '\\m(viagra|casino|onlyfans|escort|porn|vigrx|slimming pills)\\M'
    SQL
    ids.merge(spam_keyword_ids)
    puts "Spam pattern 3 (spam keyword titles, ≤3 members): #{spam_keyword_ids.size} groups"

    ids.to_a
  end

  def self.unused_trial_groups_scope
    Group.where(parent_id: nil, archived_at: nil)
         .where("(SELECT COUNT(*) FROM memberships WHERE memberships.group_id = groups.id AND memberships.revoked_at IS NULL) <= 1")
         .where("(SELECT COUNT(*) FROM groups sg WHERE sg.parent_id = groups.id AND sg.archived_at IS NULL) = 0")
         .where(<<~SQL)
           (SELECT COUNT(*) FROM discussions
            WHERE discussions.group_id = groups.id
            AND discussions.discarded_at IS NULL
            AND discussions.title NOT IN (#{DEFAULT_DISCUSSION_TITLES.map { |t| ActiveRecord::Base.connection.quote(t) }.join(', ')})) < 3
         SQL
         .where(<<~SQL)
           (SELECT COUNT(*) FROM polls
            WHERE polls.group_id = groups.id
            AND polls.discarded_at IS NULL
            AND polls.title NOT IN (#{DEFAULT_POLL_TITLES.map { |t| ActiveRecord::Base.connection.quote(t) }.join(', ')})) < 3
         SQL
  end
end
