module CleanupService
  def self.delete_orphan_records
    [Membership,
     MembershipRequest,
     Discussion,
     DiscussionReader,
     SearchVector,
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
