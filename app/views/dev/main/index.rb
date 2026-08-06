# frozen_string_literal: true

class Views::Dev::Main::Index < Phlex::HTML
  POLL_TYPES = %w[count check proposal poll dot_vote score count meeting ranked_choice stv].freeze
  POLL_SCENARIOS = %w[
    poll_created
    poll_scheduled
    poll_reminder
    poll_outcome_created
    poll_outcome_review_due
    poll_stance_created
    poll_closing_soon
    poll_closing_soon_with_vote
    poll_closing_soon_author
    poll_user_mentioned
    poll_expired_author
    poll_options_added_author
  ].freeze
  FORMATS = %w[compare email matrix markdown print csv].freeze

  def initialize(routes:)
    @routes = routes
  end

  def view_template
    ul do
      @routes.sort.each do |route|
        li { a(href: route) { route } }
      end
    end

    h2 { "poll scenarios" }
    p { "Add &anonymous=1 or &hide_results=until_closed or until_vote if you like" }

    ul do
      POLL_TYPES.each do |poll_type|
        POLL_SCENARIOS.each do |scenario|
          li do
            plain "#{poll_type} #{scenario}: "
            FORMATS.each_with_index do |format, index|
              a(href: "/dev/polls/test_poll_scenario?poll_type=#{poll_type}&scenario=#{scenario}&format=#{format}") { format }
              plain " | " if index < FORMATS.length - 1
            end
          end
        end
      end
    end
  end
end
