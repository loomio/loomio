namespace :stats do
  task :all => [:environment, :group_requests, :users, :groups,   :events] do
  end

  task :group_requests => :environment do
    export_model_to_s3 GroupRequest, ["id", "name", "admin_email", "created_at", "group_id"]
  end

  task :groups => :environment do    # Export all groups, scramble details of private ones
    require 'csv'
    file = CSV.generate do |csv|
      csv << ["id", "name", "created_at", "viewable_by", "parent_id", "description", "memberships_count", "archived_at", "distribution_metric", "sectors_metric", "other_sectors_metric", "cannot_contribute"]
      Group.all.each do |group|
        if group.viewable_by == :everyone
          csv << [group.id, group.name, group.created_at, group.viewable_by, group.parent_id, group.description, group.memberships_count, group.archived_at, group.distribution_metric, group.sectors_metric, group.other_sectors_metric, group.cannot_contribute]
        else
          csv << [scramble(group.id), "Private", group.created_at, group.viewable_by, group.parent_id, "Private", group.memberships_count, group.archived_at, group.distribution_metric, group.sectors_metric, group.other_sectors_metric, group.cannot_contribute]
        end
      end
    end

    s3write('groups.csv', file)
  end

  task :users => :environment do   # Export all users' create dates
    require 'csv'
    file = CSV.generate do |csv|
      csv << ["id", "created_at", "last_sign_in_at", "memberships_count"]
      User.all.each do |user|
        csv << [scramble(user.id), user.created_at, user.last_sign_in_at, user.memberships_count]
      end
    end

    s3write('users.csv', file)
  end

task :events => :environment do    # Export all events, scramble users, scramble private groups & subgroups
    require 'csv'

    file = CSV.generate do |csv|
      csv << ["id", "user", "group", "parent_group", "top_group", "kind", "created_at"]
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

          if group.parent and group.parent.viewable_by == :everyone
            parent_group_id = group.parent.id.to_s
          elsif group.parent  # i.e. the group is not public
            parent_group_id = scramble(group.parent.id)
          else
            parent_group_id =  ""
          end
        end

        top_group = !parent_group_id.blank? ? parent_group_id : group_id

        csv << [id, scramble(user_id), group_id, parent_group_id, top_group, kind, created_at]
      end
    end

    s3write('events.csv', file)
  end

  def export_model_to_s3(model, fields)
    require 'csv'
    file = CSV.generate do |csv|
      csv << fields
      model.all.each do |m|
        csv << fields.map { |x| eval('m.' + x) }
      end
    end

    s3write(model.name + '.csv', file)
  end

  def scramble(method)
    Digest::MD5.hexdigest(method.to_s)
  end

  def s3write (filename, data)
    raise "Please set environment variable CANONICAL_HOST" if ENV["CANONICAL_HOST"].blank?
    AWS::S3.new.buckets['loomio-metrics'].objects.create(ENV["CANONICAL_HOST"] + '-' + filename, data)
  end
end