namespace :stats do
  task :all => [:environment, :group_requests, :users, :groups,   :events] do
  end

  task :group_requests => :environment do
    export_model_to_s3 GroupRequest, ["id", "name", "admin_email", "created_at", "group_id"]
  end

  task :groups => :environment do    # Export all groups, scramble details of private ones
    require 'csv'
    file = CSV.generate do |csv|
      csv << ["id", "name", "created_at", "viewable_by", "parent_id", "description", "memberships_count", "archived_at"]
      Group.all.each do |group|
        if group.viewable_by == :everyone
          csv << [group.id, group.name, group.created_at, group.viewable_by, group.parent_id, group.description, group.memberships_count, group.archived_at]
        else
          csv << [scramble(group.id), "Private", group.created_at, group.viewable_by, group.parent_id, "Private", group.memberships_count, group.archived_at]
        end
      end
    end

    s3file('groups.csv').write file
  end

  task :users => :environment do   # Export some user data
    require 'csv'
    file = CSV.generate do |csv|
      csv << ["id", "created_at", "last_sign_in_at", "memberships_count"]
      User.all.each do |user|
        csv << [scramble(user.id), user.created_at, user.last_sign_in_at, user.memberships_count]
      end
    end

    s3file('users.csv').write file
  end

task :events => :environment do    # Export all events, scramble users, scramble private groups & subgroups
    require 'csv'

    file = CSV.generate do |csv|
      csv << ["id", "user", "group", "parent_group", "kind", "created_at"]
      count = 0
      Event.find_each do |event|
        count += 1
        puts count if (count % 100) == 0
        id = event.id
        kind = event.kind
        created_at = event.created_at
        eventable = event.eventable
        case event.kind
        when "new_discussion", "new_motion"
          user = eventable.author if eventable
          group = eventable.group if eventable
        when "new_comment", "new_vote", "motion_blocked", "membership_requested", "comment_liked", "mentioned_user"
          begin
            user = eventable.user if eventable
            group = eventable.group if eventable
          rescue => error
            puts error.class
            puts error
            user = nil
            group = nil
          end
        when "motion_closed"
          user = event.user
          group = eventable.group if eventable
        when "user_added_to_group"
          user = eventable.inviter if eventable
          group = eventable.group if eventable
        else
          user = nil
          group = nil
        end

        user_id = user ? user.id : ""

        # scramble users, and (private) groups & subgroups

        if group
          if group.viewable_by == :everyone
            group_id = group.id
          else
            group_id = scramble(group.id)
          end

          if group.parent and group.viewable_by == :everyone
            parent_group_id = group.parent.id.to_s
          elsif group.parent  # i.e. the group is not public
            parent_group_id = scramble(group.parent.id)
          else
            parent_group_id =  ""
          end
        end

        csv << [id, scramble(user_id), group_id, parent_group_id, kind, created_at]
      end
    end

    s3file('events.csv').write file
  end

task :group_events => :environment do    # Export all events associated with a particular group, no privacy
  @our_group = ENV['exportgroup']
  raise "Please pass the group_id as an argument, like this: rake stats:group_events exportgroup=2" if @our_group.blank?

  require 'csv'

  file = CSV.generate do |csv|
    csv << ["id", "user", "group", "kind", "created_at"]
    count = 0
    Event.find_each do |event|
      count += 1
      puts count if (count % 100) == 0
      id = event.id
      kind = event.kind
      created_at = event.created_at
      eventable = event.eventable
      case event.kind
      when "new_discussion", "new_motion"
        user = eventable.author if eventable
        group = eventable.group if eventable
      when "new_comment", "new_vote", "motion_blocked", "membership_requested", "comment_liked", "mentioned_user"
        begin
          user = eventable.user if eventable
          group = eventable.group if eventable
        rescue => error
          puts error.class
          puts error
          user = nil
          group = nil
        end
      when "motion_closed"
        user = event.user
        group = eventable.group if eventable
      when "user_added_to_group"
        user = eventable.inviter if eventable
        group = eventable.group if eventable
      else
        user = nil
        group = nil
      end

      group_id = group ? group.id : ""
      user_id = user ? user.id : ""

      if group_id.to_s == @our_group
        csv << [id, user_id, group_id, kind, created_at]
      end
    end
  end

  s3file("group-#{@our_group}-events.csv").write file
end

  def export_model_to_s3(model, fields)
    require 'csv'
    file = CSV.generate do |csv|
      csv << fields
      model.all.each do |m|
        csv << fields.map { |x| eval('m.' + x) }
      end
    end

    s3file(model.name + '.csv').write file
  end

  def scramble(method)
    Digest::MD5.hexdigest(method.to_s)
  end

  def s3file (filename)
    raise "Please set environment variable LOOMIO_INSTANCE" if ENV["LOOMIO_INSTANCE"].blank?
    AWS::S3.new.buckets['loomio-metrics'].objects.create ENV["LOOMIO_INSTANCE"] + '-' + filename
  end
end