# frozen_string_literal: true

class Views::UserMailer::Digest < Views::NotificationMailer::Layout
  include PrettyUrlHelper

  def initialize(user:, recipient:, notifications:, topics_by_group_id:, time_start:, time_finish:, utm_hash:)
    @user = user
    @recipient = recipient
    @notifications = notifications
    @topics_by_group_id = topics_by_group_id
    @groups = [NullGroup.new, *Group.where(id: topics_by_group_id.keys).order(full_name: :asc)]

    @time_start = time_start
    @time_finish = time_finish
    @utm_hash = utm_hash
  end

  def view_template
    h1 { plain t(:"email.catch_up.catch_up_heading", site_name: AppConfig.theme[:site_name]) }

    if @notifications.any?
      render Views::UserMailer::Digest::Notifications.new(
        notifications: @notifications,
        recipient: @recipient
      )
    end

    if @topics_by_group_id.any?
      section do
        h2 { plain t(:"email.catch_up.unread_threads") }

        @groups.each do |group|
          next unless @topics_by_group_id.has_key?(group.id)

          section do
            h3 { link_to group.full_name, group.id ? group_url(group) : direct_discussions_url }

            @topics_by_group_id[group.id].each do |topic|
              render Views::UserMailer::Digest::Topic.new(
                topic: topic,
                recipient: @recipient,
                time_start: @time_start,
                time_finish: @time_finish,
                utm_hash: @utm_hash
              )
            end
          end
        end
      end
    end

    div(class: "email-actions") do
      render Views::NotificationMailer::Common::Button.new(
        url: mark_digest_as_read_url_for(@user),
        text: t(:"email.catch_up.mark_catch_up_as_read")
      )
    end
    render Views::UserMailer::Digest::Footer.new(recipient: @recipient)
  end

  private

  def mark_digest_as_read_url_for(user, format: nil)
    email_actions_mark_digest_as_read_url(
      unsubscribe_token: user.unsubscribe_token,
      time_start: @time_start.utc.to_i,
      time_finish: @time_finish.utc.to_i,
      format: format
    )
  end
end
