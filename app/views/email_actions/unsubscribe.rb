# frozen_string_literal: true

class Views::EmailActions::Unsubscribe < Views::BasicLayout
  include Phlex::Rails::Helpers::FormTag

  VOLUMES = %w[quiet normal loud].freeze

  def initialize(topic_reader:, membership:, unsubscribe_token:, push_enabled:, email_catch_up_day:, **layout_args)
    super(**layout_args)
    @topic_reader = topic_reader
    @membership = membership
    @unsubscribe_token = unsubscribe_token
    @push_enabled = push_enabled
    @email_catch_up_day = email_catch_up_day
  end

  def view_template
    render_styles
    main(class: "sistema") do
      h1 { t(:"email_settings_page.header") }

      if @topic_reader
        h3 { "#{t(:'common.thread')}: #{@topic_reader.topic.topicable.title}" }
        notification_form(
          action: email_actions_set_discussion_volume_path,
          record: @topic_reader,
          topic_id: @topic_reader.topic_id,
          apply_to_group: @membership.present?
        )
      elsif @membership
        h3 { "#{t(:'common.group')}: #{@membership.group.full_name}" }
        notification_form(
          action: email_actions_set_group_volume_path,
          record: @membership,
          group_id: @membership.group_id
        )
      end

      p { t(:"push_notifications.enable_from_loomio") } unless @push_enabled
    end
  end

  private

  def render_styles
    style do
      plain <<~CSS
        .notification-settings-form { max-width: 640px; }
        .delivery-method { margin-bottom: 24px; }
        .delivery-method label, .volume-settings legend { display: block; font-weight: 500; margin-bottom: 8px; }
        .volume-settings { border: 0; margin: 0 0 24px; padding: 0; }
        .volume-choice { align-items: start; display: grid; gap: 4px 10px; grid-template-columns: auto 1fr; margin: 12px 0; }
        .volume-choice input { grid-row: 1 / span 2; margin-top: 4px; }
        .volume-choice label { cursor: pointer; }
        .volume-choice-title { display: block; font-weight: 500; }
        .volume-choice-description { display: block; opacity: 0.72; }
        .apply-to-group { align-items: start; display: flex; gap: 8px; margin: 24px 0; }
        .apply-to-group input { margin-top: 4px; }
        .notification-settings-form .volume-settings { display: none; }
        .notification-settings-form.push-disabled .volume-email,
        .notification-settings-form:has(.delivery-method-select option[value="email"]:checked) .volume-email,
        .notification-settings-form:has(.delivery-method-select option[value="push"]:checked) .volume-push,
        .notification-settings-form:has(.delivery-method-select option[value="email_and_push"]:checked) .volume-email,
        .notification-settings-form:has(.delivery-method-select option[value="email_and_push"]:checked) .volume-push { display: block; }
      CSS
    end
  end

  def notification_form(action:, record:, topic_id: nil, group_id: nil, apply_to_group: false)
    form_class = "notification-settings-form #{@push_enabled ? 'push-enabled' : 'push-disabled'}"
    form_tag(action, method: :put, class: form_class) do
      input(type: :hidden, name: "unsubscribe_token", value: @unsubscribe_token)
      input(type: :hidden, name: "topic_id", value: topic_id) if topic_id
      input(type: :hidden, name: "group_id", value: group_id) if group_id

      delivery_method_select(record) if @push_enabled
      volume_radios(record, :email)
      volume_radios(record, :push) if @push_enabled
      catch_up_hint if @email_catch_up_day
      apply_to_group_checkbox if apply_to_group
      input(type: "submit", value: t(:"common.action.save"))
    end
  end

  def delivery_method_select(record)
    div(class: "delivery-method") do
      label(for: "delivery_method") { t(:"change_volume_form.delivery_method") }
      setting_select(
        "delivery_channel",
        %w[email push email_and_push].map { |channel| [t(:"change_volume_form.#{channel}_channel"), channel] },
        selected: delivery_channel(record),
        id: "delivery_method",
        class_name: "delivery-method-select"
      )
    end
  end

  def volume_radios(record, channel)
    fieldset(class: "volume-settings volume-#{channel}") do
      legend { t(:"change_volume_form.volume_#{channel}_label") }
      VOLUMES.each do |volume|
        id = "#{record.class.model_name.singular}_volume_#{channel}_#{volume}"
        div(class: "volume-choice") do
          input(
            type: :radio,
            id: id,
            name: "volume_#{channel}",
            value: volume,
            checked: record.public_send("volume_#{channel}") == volume
          )
          label(for: id) do
            span(class: "volume-choice-title") { t(volume_title_key(volume, channel)) }
            span(class: "volume-choice-description") do
              t(volume_description_key(volume, channel), context: t(notification_context_key))
            end
          end
        end
      end
    end
  end

  def apply_to_group_checkbox
    div(class: "apply-to-group") do
      input(type: :checkbox, id: "apply_to_group", name: "apply_to_group", value: "1")
      label(for: "apply_to_group") do
        t(:"change_volume_form.apply_to_all_threads_in_group", group: @membership.group.full_name)
      end
    end
  end

  def catch_up_hint
    key = case @email_catch_up_day
    when 7 then :"change_volume_form.catch_up_daily_hint"
    when 8 then :"change_volume_form.catch_up_every_second_day_hint"
    else :"change_volume_form.catch_up_weekly_hint"
    end
    p(class: "text-medium-emphasis") { t(key) }
  end

  def notification_context_key
    @topic_reader ? :"change_volume_form.context.thread" : :"change_volume_form.context.group"
  end

  def volume_title_key(volume, channel)
    if volume == "quiet"
      return :"change_volume_form.catch_up_only_option" if channel == :email && @email_catch_up_day
      return :"change_volume_form.no_#{channel}_updates_option"
    end
    return :"change_volume_form.when_notified_option" if volume == "normal"

    :"change_volume_form.all_activity_option"
  end

  def volume_description_key(volume, channel)
    if volume == "quiet"
      return :"change_volume_form.catch_up_only_with_notifications_description" if channel == :email && @email_catch_up_day
      return :"change_volume_form.no_#{channel}_updates_description"
    end
    if volume == "normal"
      suffix = channel == :email && @email_catch_up_day ? "_with_catch_up" : ""
      return :"change_volume_form.#{channel}_when_notified#{suffix}_description"
    end

    :"change_volume_form.#{channel}_all_activity_description"
  end

  def delivery_channel(record)
    email = record.email_enabled?
    push = record.push_enabled?
    return "email_and_push" if email && push
    return "push" if push

    "email"
  end

  def setting_select(name, options, selected:, id:, class_name: nil)
    select(id: id, name: name.to_s, class: class_name) do
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
