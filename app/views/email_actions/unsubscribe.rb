# frozen_string_literal: true

class Views::EmailActions::Unsubscribe < Views::BasicLayout
  include Phlex::Rails::Helpers::FormTag

  def initialize(topic_reader:, membership:, unsubscribe_token:, **layout_args)
    super(**layout_args)
    @topic_reader = topic_reader
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

      if @topic_reader
        h3 { "#{t(:'common.thread')}: #{@topic_reader.topic.topicable.title}" }
        p { t(:"change_volume_form.when_would_you_like_to_be_emailed_discussion") }
        form_tag(email_actions_set_discussion_volume_path, method: :put) do
          input(type: :hidden, name: "unsubscribe_token", value: @unsubscribe_token)
          input(type: :hidden, name: "topic_id", value: @topic_reader.topic_id)
          volume_select(volume_options, selected: @topic_reader.volume)
          input(type: "submit", value: t(:"common.action.save"))
        end
      end

      if @membership
        h3 { "#{t(:'common.group')}: #{@membership.group.full_name}" }
        p { t(:"change_volume_form.when_would_you_like_to_be_emailed_group") }
        form_tag(email_actions_set_group_volume_path, method: :put) do
          input(type: :hidden, name: "unsubscribe_token", value: @unsubscribe_token)
          input(type: :hidden, name: "group_id", value: @membership.group_id) if @membership.group_id
          volume_select(volume_options, selected: @membership.volume)
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
