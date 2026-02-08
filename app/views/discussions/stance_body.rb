# frozen_string_literal: true

class Views::Discussions::StanceBody < Views::Base
  def initialize(stance:, voter:, poll:, current_user:)
    @stance = stance
    @voter = voter
    @poll = poll
    @current_user = current_user
  end

  def view_template
    send(:"render_#{@poll.poll_type}")
  end

  private

  def render_proposal
    div(class: "layout align-center wrap") do
      h3(class: "thread-item__title text-body-2 d-flex") do
        a(href: user_url(@voter)) { plain @voter.name }
        @stance.stance_choices.each do |stance_choice|
          div(class: "poll-common-stance-choice mr-1 mb-1", row: "") do
            span do
              div(class: "v-avatar v-avatar--tile", style: "height: 24px; min-width: 24px; width: 24px;") do
                img(
                  alt: t("poll_#{@poll.poll_type}_options.#{stance_choice.poll_option.name.downcase}"),
                  src: "/img/#{stance_choice.poll_option.name.downcase}.svg"
                )
              end
            end
          end
        end
        span do
          span("aria-hidden": "true") { plain " \u00b7" }
        end
        span(class: "text--secondary text-body-2") do
          time_ago(@stance.created_at, @current_user)
        end
      end
    end
    render_reason
  end

  def render_check
    div(class: "layout align-center wrap") do
      h3(class: "thread-item__title text-body-2 d-flex") do
        a(href: user_url(@voter)) { plain @voter.name }
        @stance.stance_choices.each do |stance_choice|
          div(class: "poll-common-stance-choice mr-1 mb-1", row: "") do
            span do
              div(class: "v-avatar v-avatar--tile", style: "height: 24px; min-width: 24px; width: 24px;") do
                img(
                  alt: t("poll_#{@poll.poll_type}_options.#{stance_choice.poll_option.name}"),
                  src: "/img/#{stance_choice.poll_option.name}.svg"
                )
              end
            end
          end
        end
        span do
          span("aria-hidden": "true") { plain " \u00b7" }
        end
        span(class: "text--secondary text-body-2") do
          time_ago(@stance.created_at, @current_user)
        end
      end
    end
    render_reason
  end

  def render_poll
    div(class: "layout align-center wrap") do
      h3(class: "thread-item__title text-body-2 d-flex") do
        a(href: user_url(@voter)) { plain @voter.name }
        span do
          span("aria-hidden": "true") { plain " \u00b7" }
        end
        span(class: "text--secondary text-body-2") do
          time_ago(@stance.created_at, @current_user)
        end
      end
    end
    @stance.stance_choices.each do |stance_choice|
      div(class: "poll-common-stance-choice mx-1 mb-1 poll-common-stance-choice--poll text-body-2", row: "") do
        span { plain stance_choice.poll_option.name }
      end
    end
    render_reason
  end

  def render_meeting
    div(class: "layout align-center wrap") do
      h3(class: "thread-item__title text-body-2 d-flex") do
        a(href: user_url(@voter)) { plain @voter.name }
        span do
          span("aria-hidden": "true") { plain " \u00b7" }
        end
        span(class: "text--secondary text-body-2") do
          time_ago(@stance.created_at, @current_user)
        end
      end
    end
    @stance.stance_choices.each do |stance_choice|
      div(class: "poll-common-stance-choice mx-1 mb-1 poll-common-stance-choice--poll text-body-2", row: "") do
        span do
          time_ago(Time.parse(stance_choice.poll_option.name).in_time_zone, @current_user)
        end
      end
    end
    render_reason
  end

  def render_dot_vote
    div(class: "layout align-center wrap") do
      h3(class: "thread-item__title text-body-2 d-flex") do
        a(href: user_url(@voter)) { plain @voter.name }
        span do
          span("aria-hidden": "true") { plain " \u00b7" }
        end
        span(class: "text--secondary text-body-2") do
          time_ago(@stance.created_at, @current_user)
        end
      end
    end
    table(style: "width: 100%") do
      @stance.stance_choices.order("score desc").each do |stance_choice|
        tr do
          td { plain "#{stance_choice.score} - #{stance_choice.poll_option.name}" }
        end
        tr do
          td do
            table(style: "width: #{dot_vote_stance_choice_percentage_for(@stance, stance_choice)}%") do
              tr do
                td(height: "24px", style: "background-color: #{stance_choice.poll_option.color}")
              end
            end
          end
        end
      end
    end
    render_reason
  end

  def render_score
    div(class: "layout align-center wrap") do
      h3(class: "thread-item__title text-body-2", id: "event-1473") do
        a(href: user_url(@voter)) { plain @voter.name }
        span do
          span("aria-hidden": "true") { plain " \u00b7" }
        end
        span(class: "text--secondary text-body-2") do
          time_ago(@stance.created_at, @current_user)
        end
      end
    end
    table(style: "width: 100%") do
      @stance.stance_choices.order("score desc").each do |stance_choice|
        tr do
          td { plain "#{stance_choice.score} - #{stance_choice.poll_option.name}" }
        end
        tr do
          td do
            table(style: "width: #{score_stance_choice_percentage_for(@stance, stance_choice)}%") do
              tr do
                td(height: "24px", style: "background-color: #{stance_choice.poll_option.color}")
              end
            end
          end
        end
      end
    end
    render_reason
  end

  def render_ranked_choice
    div(class: "layout align-center wrap") do
      h3(class: "thread-item__title text-body-2 d-flex") do
        a(href: user_url(@voter)) { plain @voter.name }
        span do
          span("aria-hidden": "true") { plain " \u00b7" }
        end
        span(class: "text--secondary text-body-2") do
          time_ago(@stance.created_at, @current_user)
        end
      end
    end
    table(style: "width: 100%", cellspacing: 0) do
      @stance.stance_choices.order("score desc").each do |stance_choice|
        tr do
          td { render Views::EventMailer::Poll::Chip.new(color: stance_choice.poll_option.color) }
          td { plain "#{stance_choice.rank} - #{stance_choice.poll_option.name}" }
        end
      end
    end
    render_reason
  end

  def render_count
    render_proposal
  end

  def render_question
    render_proposal
  end

  def render_reason
    div(class: "poll-common-stance") do
      div(class: "lmo-markdown-wrapper text-body-2 text--primary poll-common-stance-created__reason") do
        raw MarkdownService.render_rich_text(@stance.reason, @stance.reason_format)
      end
    end
  end
end
