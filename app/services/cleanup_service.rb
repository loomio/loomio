module CleanupService
  def self.delete_orphan_records
    [Group,
     Membership,
     MembershipRequest,
     Discussion,
     Subscription,
     DiscussionReader,
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
    ActiveStorage::Blob.unattached.where("active_storage_blobs.created_at < ?", 7.days.ago).find_each(&:purge_later)
    
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
end
