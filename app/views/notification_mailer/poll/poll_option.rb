# frozen_string_literal: true

class Views::NotificationMailer::Poll::PollOption < Views::ApplicationMailer::Component

  def initialize(poll:, poll_option:, stance: nil, recipient: nil)
    @poll = poll
    @poll_option = poll_option
    @stance = stance
    @recipient = recipient
  end

  def view_template
    display_name = case @poll.poll_option_name_format
    when 'i18n' then t(@poll_option.name)
    when 'iso8601' then format_iso8601_for_humans(@poll_option.name, @recipient.time_zone, @recipient.date_time_pref)
    else TranslationService.plain_text(@poll_option, :name, @recipient)
    end

    score = @stance && @stance.option_scores[@poll_option.id.to_s]
    link = @poll.active? && tracked_url(@poll, recipient: @recipient, args: { poll_option_id: @poll_option.id })
    semantic_option = @poll.has_option_icon && @poll_option.icon
    border_color = semantic_option ? @poll_option.color : AppConfig.theme[:primary_color]
    container_class = semantic_option ? "poll-mailer__poll-option-container--semantic" : "poll-mailer__poll-option-container"

    table(
      class: "#{container_class} mb-2 pa-1",
      style: "border: 1px solid #{border_color}; border-collapse: separate; border-radius: 4px; width: 100%; max-width: 600px"
    ) do
      tr(class: "poll-mailer__poll-option") do
        td(style: "width: 48px; height: 48px; text-align: center") do
          optional_link_wrapper(link) do
            render_icon(display_name, score)
          end
        end
        td(class: "pl-4") do
          optional_link_wrapper(link) { plain display_name }
          div(class: "text-caption") do
            optional_link_wrapper(link) { plain TranslationService.plain_text(@poll_option, :meaning, @recipient) }
          end
        end
      end
    end
  end

  private

  def optional_link_wrapper(link, &block)
    if link
      a(href: link, class: "text-decoration-none", &block)
    else
      span(&block)
    end
  end

  def render_icon(display_name, score)
    if @poll.has_option_icon && @poll_option.icon
      img(src: image_path("poll_mailer/vote-button-#{@poll_option.icon.to_s.downcase}.png"), width: 48, height: 48, alt: display_name, style: 'display: inline-block')
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
        img(src: image_path("poll_mailer/vote-button-#{icon}.png"), width: 48, height: 48, alt: display_name, style: 'display: inline-block')
      else
        selection_indicator("☐")
      end
    end
  end

  def selection_indicator(character)
    span(class: "poll-mailer__option-indicator", style: "font-size: 24px; line-height: 24px") { plain character }
  end
end
