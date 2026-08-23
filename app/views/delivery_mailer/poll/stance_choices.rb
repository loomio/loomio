# frozen_string_literal: true

class Views::DeliveryMailer::Poll::StanceChoices < Views::ApplicationMailer::Component

  def initialize(poll:, stance:, recipient: nil)
    @poll = poll
    @stance = stance
    @recipient = recipient
  end

  def view_template
    return unless @poll.is_single_choice?

    table do
      @stance.stance_choices.order("score desc").limit(5).each do |stance_choice|
        poll_option = stance_choice.poll_option
        display_name = case @poll.poll_option_name_format
        when 'i18n' then t(poll_option.name)
        when 'iso8601' then format_iso8601_for_humans(poll_option.name, @recipient.time_zone, @recipient.date_time_pref)
        else TranslationService.plain_text(poll_option, :name, @recipient)
        end

        score = @stance && @stance.option_scores[poll_option.id.to_s]

        tr do
          td(valign: "top") do
            render_icon(poll_option, display_name, score)
          end
          td(valign: "top") { plain display_name }
        end
      end
    end
  end

  private

  def render_icon(poll_option, display_name, score)
    if @poll.has_option_icon && poll_option.icon
      img(src: image_path("poll_mailer/vote-button-#{poll_option.icon.to_s.downcase}.png"), width: 24, height: 24, alt: display_name, style: 'display: inline-block')
      return
    end

    case @poll.poll_type
    when 'poll'
      if @poll.is_single_choice?
        selection_indicator((score && score > 0) ? "●" : "○")
      else
        selection_indicator((score && score > 0) ? "☑" : "☐")
      end
    when 'score', 'dot_vote'
      if score
        div(class: "text-h6") { plain score.to_s }
      else
        selection_indicator("☐")
      end
    when 'ranked_choice'
      if score
        div(class: "text-h6") { plain "##{@poll.minimum_stance_choices - score + 1}" }
      else
        selection_indicator("☐")
      end
    when 'stv'
      if score
        div(class: "text-h6") { plain "##{score}" }
      else
        selection_indicator("☐")
      end
    when 'meeting'
      if score
        icon = { 0 => 'disagree', 1 => 'abstain', 2 => 'agree' }[score]
        img(src: image_path("poll_mailer/vote-button-#{icon}.png"), width: 24, height: 24, alt: display_name, style: 'display: inline-block')
      else
        selection_indicator("☐")
      end
    end
  end

  def selection_indicator(character)
    span(class: "poll-mailer__option-indicator", style: "font-size: 24px; line-height: 24px") { plain character }
  end
end
