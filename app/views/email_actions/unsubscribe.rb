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
    style do
      plain <<~CSS
        .volume-email, .volume-push { display: none; }
        .delivery-email:checked ~ .volume-email,
        .delivery-push:checked ~ .volume-push,
        .delivery-both:checked ~ .volume-email,
        .delivery-both:checked ~ .volume-push { display: block; }
      CSS
    end
    main(class: "sistema") do
      h1 { t(:"email_settings_page.header") }

      if @topic_reader
        h3 { "#{t(:'common.thread')}: #{@topic_reader.topic.topicable.title}" }
        form_tag(email_actions_set_discussion_volume_path, method: :put) do
          input(type: :hidden, name: "unsubscribe_token", value: @unsubscribe_token)
          input(type: :hidden, name: "topic_id", value: @topic_reader.topic_id)
          volume_fields(@topic_reader)
          input(type: "submit", value: t(:"common.action.save"))
        end
      end

      if @membership
        h3 { "#{t(:'common.group')}: #{@membership.group.full_name}" }
        form_tag(email_actions_set_group_volume_path, method: :put) do
          input(type: :hidden, name: "unsubscribe_token", value: @unsubscribe_token)
          input(type: :hidden, name: "group_id", value: @membership.group_id) if @membership.group_id
          volume_fields(@membership)
          input(type: "submit", value: t(:"common.action.save"))
        end
        p { i { t(:"change_volume_form.changes_all_discussions_and_polls_in_group") } }
      end

      p { t(:"push_notifications.enable_from_loomio") }
    end
  end

  private

  def volume_fields(record)
    prefix = record.class.model_name.singular
    channel = delivery_channel(record)
    fieldset do
      legend { t(:"change_volume_form.volume_channel_label") }
      delivery_radio(prefix, "email", channel)
      delivery_radio(prefix, "push", channel)
      delivery_radio(prefix, "email_and_push", channel)

      volume_select(prefix, :email, record.volume_email)
      volume_select(prefix, :push, record.volume_push)
    end
  end

  def delivery_radio(prefix, channel, selected)
    id = "#{prefix}_delivery_#{channel}"
    input(
      type: :radio,
      id: id,
      name: "delivery_channel",
      value: channel,
      class: "delivery-#{channel == 'email_and_push' ? 'both' : channel}",
      checked: channel == selected
    )
    label(for: id) { t(:"change_volume_form.#{channel}_channel") }
    br
  end

  def volume_select(prefix, channel, volume)
    id = "#{prefix}_volume_#{channel}"
    div(class: "volume-#{channel}") do
      label(for: id) { t(:"change_volume_form.volume_#{channel}_label") }
      br
      setting_select(
        "volume_#{channel}",
        %w[quiet normal loud].map { |value| [ t(:"change_volume_form.#{volume_level_key(value)}"), value ] },
        selected: volume == "mute" ? "normal" : volume,
        id: id
      )
    end
  end

  def delivery_channel(record)
    email = record.email_volume_is_normal_or_loud?
    push = record.push_volume_is_normal_or_loud?
    return "email_and_push" if email && push
    return "push" if push

    "email"
  end

  def setting_select(name, options, selected:, id:)
    select(id: id, name: name.to_s) do
      options.each do |label, value|
        if value == selected
          option(value: value, selected: true) { label }
        else
          option(value: value) { label }
        end
      end
    end
  end

  def volume_level_key(value)
    { "loud" => "all_activity_option", "normal" => "when_notified_option", "quiet" => "muted_option" }.fetch(value)
  end
end
