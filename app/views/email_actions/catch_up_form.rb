# frozen_string_literal: true

class Views::EmailActions::CatchUpForm < Views::Application::Component
  include Phlex::Rails::Helpers::FormTag

  def initialize(email_catch_up_day:, unsubscribe_token:, topic_id: nil, group_id: nil)
    @email_catch_up_day = email_catch_up_day
    @unsubscribe_token = unsubscribe_token
    @topic_id = topic_id
    @group_id = group_id
  end

  def view_template
    form_tag(email_actions_set_catch_up_path, method: :put, class: 'email-action-form') do
      input(type: :hidden, name: 'unsubscribe_token', value: @unsubscribe_token) if @unsubscribe_token
      input(type: :hidden, name: 'topic_id', value: @topic_id) if @topic_id
      input(type: :hidden, name: 'group_id', value: @group_id) if @group_id
      label(for: 'email_catch_up_day') { t(:'email_actions.catch_up_schedule') }
      select(name: 'email_catch_up_day', id: 'email_catch_up_day') do
        Views::EmailActions::CatchUp::DAY_OPTIONS.each do |value, key|
          option(value: value, selected: value == selected_day) { t(:"email_actions.catch_up_days.#{key}") }
        end
      end
      input(type: :submit, id: 'email_catch_up_save', value: t(:'common.action.save'), class: 'btn--accent--raised')
    end
    script do
      raw safe(<<~JS)
        (() => {
          const schedule = document.getElementById('email_catch_up_day');
          const save = document.getElementById('email_catch_up_save');
          const savedValue = schedule.value;
          const updateSave = () => { save.disabled = schedule.value === savedValue; };
          schedule.addEventListener('change', updateSave);
          updateSave();
        })();
      JS
    end
  end

  private

  def selected_day
    @email_catch_up_day.nil? ? 'never' : @email_catch_up_day.to_s
  end
end
