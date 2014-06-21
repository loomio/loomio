namespace :stats do
  task :all => [:environment, :group_requests, :users, :groups, :events, :discussions, :discussion_readers, :retention] do
  end

  task :group_requests => :environment do
    export_model_to_s3 GroupRequest, ["id", "name", "admin_email", "created_at", "group_id"]
  end

  task :groups => :environment do    # Export all groups, scramble details of private ones
    require 'csv'
    file = CSV.generate do |csv|
      csv << ["id", "name", "created_at", "privacy", "parent_id", "description", "memberships_count", "archived_at", "distribution_metric", "cannot_contribute"]
      Group.find_each do |group|
        if group.privacy == :public
          csv << [group.id, group.name, group.created_at, group.privacy, group.parent_id, group.description, group.memberships_count, group.archived_at, group.distribution_metric, group.cannot_contribute]
        else
          csv << [scramble(group.id), "Private", group.created_at, group.privacy, group.parent_id, "Private", group.memberships_count, group.archived_at, group.distribution_metric, group.cannot_contribute]
        end
      end
    end

    fogwrite('groups.csv', file)
  end

  task :users => :environment do   # Export all users' create dates
    require 'csv'
    file = CSV.generate do |csv|
      csv << ["id", "created_at", "last_sign_in_at", "memberships_count"]
      User.find_each do |user|
        csv << [scramble(user.id), user.created_at, user.last_sign_in_at, user.memberships_count]
      end
    end

    fogwrite('users.csv', file)
  end

  task :events => :environment do    # Export all events, scramble users, scramble private groups & subgroups
    require 'csv'

    file = CSV.generate do |csv|
      csv << ["id", "user", "group", "parent_group", "top_group", "kind", "created_at"]
      count = 0
      Event.find_each do |event|
        begin
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
            if group.privacy == :public
              group_id = group.id
            else
              group_id = scramble(group.id)
            end

            if group.parent and group.parent.privacy == :public
              parent_group_id = group.parent.id.to_s
            elsif group.parent  # i.e. the group is not public
              parent_group_id = scramble(group.parent.id)
            else
              parent_group_id =  ""
            end
          end

          top_group = !parent_group_id.blank? ? parent_group_id : group_id

          csv << [id, scramble(user_id), group_id, parent_group_id, top_group, kind, created_at]
        rescue Exception
          p $!, *$@
        end
      end
    end

    fogwrite('events.csv', file)
  end

  task :discussions => :environment do
    require 'csv'
    file = CSV.generate do |csv|
      csv << ["id", "group_id", "created_at", "updated_at", "last_comment_at", "author_id"]
      Discussion.find_each do |d|
        csv << [d.id, d.group_id, d.created_at, d.updated_at, d.last_comment_at, scramble(d.author_id)]
      end
    end
    fogwrite('discussions.csv', file)
  end

  task :discussion_readers => :environment do
    require 'csv'
    file = CSV.generate do |csv|
      csv << ["id", "discussion_id", "created_at", "last_read_at", "user_id"]
      DiscussionReader.find_each do |l|
        csv << [l.id, l.discussion_id, l.created_at, l.last_read_at, scramble(l.user_id)]
      end
    end
    fogwrite('discussion_readers.csv', file)
  end

  task :retention => :environment do
    dates = full_recent_months(15)
    new_users_by_month = dates[0..-4].map do |date|
      extract_new_user_ids(date.year, date.month)
    end
    active_users_by_month = dates[3..-1].map do |date|
      extract_active_user_ids(date.year, date.month)
    end

    rates = []
    new_users_by_month.each_index do |index|
      arr = retention_rate(new_users_by_month[index], active_users_by_month[index])
      result = {
        :month => dates[index+3].strftime('%Y - %m'),
        :new_users => arr[0],
        :retained_users => arr[1],
        :rate => arr[2]
      }
      rates.push result
    end 
    p rates
  end

  def retention_rate(month_new, month_later)
    intersection = month_new & month_later
    rate = intersection.size.to_f / month_new.size
    return month_new.size, intersection.size, rate
  end 

  def extract_active_user_ids(year, month)
    q_comments = 'SELECT DISTINCT user_id FROM comments WHERE extract(year from created_at) = ' + year.to_s
    q_comments += ' AND extract(month from created_at) = ' + month.to_s
    q_votes = 'SELECT DISTINCT user_id FROM votes WHERE extract(year from created_at) = ' + year.to_s
    q_votes +=  'AND extract(year from created_at) = ' + month.to_s
    query = 'SELECT DISTINCT I FROM (' + q_comments + ' UNION ' + q_votes + ') AS I'
    Event.connection.select_all(query).map {|o| o['i'].delete('()').to_i}
  end

  def full_recent_months(n)
    require 'date'
    now = Date.today
    dates = Array.new(n){|i| now - (i+1).months }.reverse!
  end

  def extract_new_user_ids(year, month)
    query = 'SELECT DISTINCT id FROM users WHERE extract(year from created_at) = ' + year.to_s
    query += ' AND extract(month from created_at) = ' + month.to_s
    Event.connection.select_all(query).map {|o| o['id'].to_i}
  end 


  def export_model_to_s3(model, fields)
    require 'csv'
    file = CSV.generate do |csv|
      csv << fields
      model.find_each do |model|
        csv << model.attributes.values_at(*fields)
      end
    end

    fogwrite(model.name + '.csv', file)
  end

  def scramble(method)
    Digest::MD5.hexdigest(method.to_s)
  end

  def fogwrite(filename, data)
    name_space = ENV["CANONICAL_HOST"]
    name_space ||= ENV['METRICS_NAMESPACE']
    raise "Please set environment variable METRICS_NAMESPACE or CANONICAL_HOST" if name_space.blank?

    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['AWS_SECRET_ACCESS_KEY']
    })

    connection.directories.get('loomio-metrics').files.create(
      :key    => name_space + '-' + filename,
      :body   => data,
      :acl    => 'authenticated-read'
    )
  end
end
