# frozen_string_literal: true

class Views::EmailActions::CatchUp < Views::BasicLayout
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
      render Views::EmailActions::CatchUpForm.new(
        email_catch_up_day: @email_catch_up_day,
        unsubscribe_token: @unsubscribe_token
      )
    end
  end
end
