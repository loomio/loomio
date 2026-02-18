# frozen_string_literal: true

class Views::Chatbot::Matrix::Vote < Views::Chatbot::Base
  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    if @poll.anonymous?
      p { t(:"poll_common_action_panel.anonymous") }
    end

    if @poll.active?
      h5 { t(:'poll_common.have_your_say') }

      if @poll.is_single_choice?
        ul do
          @poll.results.each do |option|
            next if option[:id] == 0
            li do
              a(href: polymorphic_url(@poll, poll_option_id: option[:id])) do
                plain option_name(option[:name], option[:name_format], @recipient.time_zone, @recipient.date_time_pref)
              end
            end
          end
        end
      else
        h3 { link_to t('poll_common.vote_now'), polymorphic_url(@poll) }
      end
    elsif @poll.scheduled?
      ul do
        @poll.results.each do |option|
          next if option[:id] == 0
          li { plain option_name(option[:name], option[:name_format], @recipient.time_zone, @recipient.date_time_pref) }
        end
      end
    end

    if @poll.wip?
      p { t(:"poll_common_action_panel.draft_mode", poll_type: t("poll_types.#{@poll.poll_type}")) }
    end
  end
end
