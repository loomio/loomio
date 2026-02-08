# frozen_string_literal: true

class Views::UserMailer::CatchUp < Views::ApplicationMailer::BaseLayout
  include PrettyUrlHelper

  def initialize(user:, recipient:, groups:, discussions_by_group_id:, subject_key:, subject_params:, time_start:, time_finish:, cache:, utm_hash:)
    @user = user
    @recipient = recipient
    @groups = groups
    @discussions_by_group_id = discussions_by_group_id
    @subject_key = subject_key
    @subject_params = subject_params
    @time_start = time_start
    @time_finish = time_finish
    @cache = cache
    @utm_hash = utm_hash
  end

  def view_template
    div(class: "everything") do
      p { plain t(:"email.catch_up.do_not_reply") }
      h1 { plain t(@subject_key, **@subject_params) }

      div(class: "toc") do
        render Views::UserMailer::CatchUp::Headlines.new(
          groups: @groups,
          discussions_by_group_id: @discussions_by_group_id,
          recipient: @recipient,
          utm_hash: @utm_hash
        )
      end

      hr

      if @discussions_by_group_id.has_key?(nil)
        h1 { link_to t(:"sidebar.direct_discussions"), direct_discussions_url }
        @discussions_by_group_id[nil].each do |discussion|
          render Views::UserMailer::CatchUp::Discussion.new(
            discussion: discussion,
            recipient: @recipient,
            time_start: @time_start,
            cache: @cache,
            utm_hash: @utm_hash
          )
        end
      end

      @groups.each do |group|
        next unless @discussions_by_group_id.has_key?(group.id)

        h1 { link_to group.full_name, group_url(group) }
        @discussions_by_group_id[group.id].each do |discussion|
          render Views::UserMailer::CatchUp::Discussion.new(
            discussion: discussion,
            recipient: @recipient,
            time_start: @time_start,
            cache: @cache,
            utm_hash: @utm_hash
          )
        end
      end
    end

    p do
      plain t(:"email.catch_up.thanks_for_reading")
      img(src: mark_summary_as_read_url_for(@user, format: 'gif'), alt: '', width: 1, height: 1)
      br
    end
    render Views::UserMailer::UnsubscribeLink.new(recipient: @recipient)
  end

  private

  def mark_summary_as_read_url_for(user, format: nil)
    email_actions_mark_summary_email_as_read_url(
      unsubscribe_token: user.unsubscribe_token,
      time_start: @time_start.utc.to_i,
      time_finish: @time_finish.utc.to_i,
      format: format
    )
  end
end
