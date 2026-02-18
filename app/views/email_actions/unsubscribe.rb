# frozen_string_literal: true

class Views::EmailActions::Unsubscribe < Views::BasicLayout
  include Phlex::Rails::Helpers::FormTag

  def initialize(discussion_reader:, stance:, membership:, unsubscribe_token:, **layout_args)
    super(**layout_args)
    @discussion_reader = discussion_reader
    @stance = stance
    @membership = membership
    @unsubscribe_token = unsubscribe_token
  end

  def view_template
    volume_options = [
      [t(:"change_volume_form.quiet_desc"), "quiet"],
      [t(:"change_volume_form.normal_desc"), "normal"],
      [t(:"change_volume_form.loud_desc"), "loud"]
    ]

    main(class: "sistema") do
      h1 { t(:"change_volume_form.change_your_email_settings") }

      if @discussion_reader
        h3 { "#{t(:'common.thread')}: #{@discussion_reader.discussion.title}" }
        p { t(:"change_volume_form.when_would_you_like_to_be_emailed_discussion") }
        form_tag(email_actions_set_discussion_volume_path, method: :put) do
          input(type: :hidden, name: "unsubscribe_token", value: @unsubscribe_token)
          input(type: :hidden, name: "discussion_id", value: @discussion_reader.discussion_id)
          input(type: :hidden, name: "poll_id", value: @stance.poll_id) if @stance
          volume_select(volume_options, selected: @discussion_reader.email_volume)
          input(type: "submit", value: t(:"common.action.save"))
        end
      end

      if @stance
        h3 { "#{t(:"poll_types.#{@stance.poll.poll_type}")}: #{@stance.poll.title}" }
        p { t(:"change_volume_form.when_would_you_like_to_be_emailed_poll_type", poll_type: I18n.t(:"poll_types.#{@stance.poll.poll_type}")) }
        form_tag(email_actions_set_poll_volume_path, method: :put) do
          input(type: :hidden, name: "unsubscribe_token", value: @unsubscribe_token)
          input(type: :hidden, name: "poll_id", value: @stance.poll.id)
          input(type: :hidden, name: "discussion_id", value: @discussion_reader.discussion_id) if @discussion_reader
          volume_select(volume_options, selected: @stance.email_volume)
          input(type: "submit", value: t(:"common.action.save"))
        end
      end

      if @membership
        h3 { "#{t(:'common.group')}: #{@membership.group.full_name}" }
        p { t(:"change_volume_form.when_would_you_like_to_be_emailed_group") }
        form_tag(email_actions_set_group_volume_path, method: :put) do
          input(type: :hidden, name: "unsubscribe_token", value: @unsubscribe_token)
          input(type: :hidden, name: "discussion_id", value: @discussion_reader.discussion_id) if @discussion_reader
          input(type: :hidden, name: "poll_id", value: @stance.poll_id) if @stance
          volume_select(volume_options, selected: @membership.email_volume)
          input(type: "submit", value: t(:"common.action.save"))
        end
        p { i { t(:"change_volume_form.changes_all_discussions_and_polls_in_group") } }
      end

      h3 { t(:"change_volume_form.what_do_the_options_mean") }

      p do
        b { t(:"change_volume_form.quiet_desc") }
        plain " - "
        plain t(:"change_volume_form.quiet_explained")
      end
      p do
        b { t(:"change_volume_form.normal_desc") }
        plain " - "
        plain t(:"change_volume_form.normal_explained")
      end
      p { t(:"change_volume_form.normal_excludes_mentioning_html", url: "/email_preferences?unsubscribe_token=#{@unsubscribe_token}") }
      p do
        b { t(:"change_volume_form.loud_desc") }
        plain " - "
        plain t(:"change_volume_form.loud_explained")
      end
    end
  end

  private

  def volume_select(options, selected:)
    select(name: :value) do
      options.each do |label, value|
        if value == selected
          option(value: value, selected: true) { label }
        else
          option(value: value) { label }
        end
      end
    end
  end
end
