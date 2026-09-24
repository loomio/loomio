# frozen_string_literal: true

class Views::EmailActions::CatchUp < Views::BasicLayout
  include Phlex::Rails::Helpers::FormTag

  DAY_OPTIONS = [
    ['never', :never],
    ['7', :every_day],
    ['8', :every_second_day],
    ['1', :monday],
    ['2', :tuesday],
    ['3', :wednesday],
    ['4', :thursday],
    ['5', :friday],
    ['6', :saturday],
    ['0', :sunday]
  ].freeze

  def initialize(email_catch_up_day:, unsubscribe_token:, **layout_args)
    super(**layout_args)
    @email_catch_up_day = email_catch_up_day
    @unsubscribe_token = unsubscribe_token
  end

  def view_template
    main(class: 'sistema email-action-page') do
      h1 { t(:'email_actions.catch_up_title') }
      p { t(:'email_actions.catch_up_description') }
      form_tag(email_actions_set_catch_up_path, method: :put, class: 'email-action-form') do
        input(type: :hidden, name: 'unsubscribe_token', value: @unsubscribe_token) if @unsubscribe_token
        label(for: 'email_catch_up_day') { t(:'email_actions.catch_up_schedule') }
        select(name: 'email_catch_up_day', id: 'email_catch_up_day') do
          DAY_OPTIONS.each do |value, key|
            option(value: value, selected: value == selected_day) { t(:"email_actions.catch_up_days.#{key}") }
          end
        end
        input(type: :submit, id: 'email_catch_up_save', value: t(:'common.action.save'), class: 'btn--accent--raised')
      end
      script do
        plain <<~JS
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
  end

  private

  def selected_day
    @email_catch_up_day.nil? ? 'never' : @email_catch_up_day.to_s
  end
end
