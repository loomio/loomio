# frozen_string_literal: true

module Views::Chatbot::Markdown::Concerns
  private

  def render_notification_text(event, poll)
    url = polymorphic_url(event.eventable)
    message = event.recipient_message
    poll_type = poll ? t("poll_types.#{poll.poll_type}") : nil
    title = plain_text(event.eventable.title_model, :title)

    md t("notifications.without_title.#{event.kind}",
         actor: event.user.name,
         title: "[#{title}](#{url})",
         poll_type: poll_type,
         site_name: AppConfig.theme[:site_name])
    md "\n"

    if message.present?
      md "\n#{message}\n"
    end
  end

  def render_title(eventable)
    md "**[#{eventable.title}](#{polymorphic_url(eventable)})**\n"
  end

  def render_body(eventable)
    md render_markdown(eventable.body, eventable.body_format)
    md "\n"
    render_attachments(eventable)
  end

  def render_attachments(resource)
    return unless resource.attachments.any?

    md "**#{t(:'common.attachments')}**\n"
    resource.files.each do |file|
      download_url = Rails.application.routes.url_helpers.rails_blob_url(
        file, only_path: false, host: ENV['CANONICAL_HOST']
      )
      md "- [#{file.blob.filename.base}](#{download_url})\n"
    end
  end

  def render_outcome(poll)
    return unless poll.current_outcome

    md "*#{t(:"poll_common.outcome")}*\n"

    if (option = poll.current_outcome.poll_option)
      if poll.poll_option_name_format == 'iso8601'
        md "Event: #{poll.current_outcome.event_summary}\n"
        md "Date: #{format_iso8601_for_humans(option.name, @recipient.time_zone, @recipient.date_time_pref)}\n"
        md "Location: #{poll.current_outcome.event_location}\n"
      end
    end

    md render_markdown(poll.current_outcome.statement, poll.current_outcome.statement_format)
    md "\n"
    md "*#{t(:"poll_types.#{poll.poll_type}")}*\n"
  end

  def render_vote(poll)
    if poll.anonymous?
      md "#{t(:"poll_common_action_panel.anonymous")}\n"
    end

    if poll.closed?
      md "#{t(:"poll_common_form.closed")} #{format_date_for_humans(poll.closed_at, @recipient.time_zone, @recipient.date_time_pref)}\n"
    end

    if poll.active?
      if poll.is_single_choice?
        md "**#{t(:'poll_common.have_your_say')}**\n"
        poll.results.each do |option|
          next if option[:id] == 0
          name = case option[:name_format]
                 when 'i18n' then t(option[:name])
                 when 'iso8601' then format_iso8601_for_humans(option[:name], @recipient.time_zone, @recipient.date_time_pref)
                 else option[:name]
                 end
          md "- [#{name}](#{polymorphic_url(poll, poll_option_id: option[:id])})\n"
        end
      else
        md "**[#{t('poll_common.vote_now')}](#{polymorphic_url(poll)})**\n"
        md "\n"
        md "#{t(:"poll_mailer.common.you_have_until", when: format_date_for_humans(poll.closing_at, @recipient.time_zone, @recipient.date_time_pref))}\n"
      end
    end

    if poll.wip?
      md "#{t(:"poll_common_action_panel.draft_mode", poll_type: t("poll_types.#{poll.poll_type}"))}\n"
    end
  end

  def render_rules(poll)
    return unless poll.quorum_pct || poll.results.any? { |r| r[:test_operator] }

    md "**#{t('poll_common_action_panel.for_this_poll_type_to_be_valid', poll_type: t("poll_types.#{poll.poll_type}"))}**\n"

    if poll.quorum_pct
      md "- #{t('poll_common_percent_voted.pct_of_eligible_voters_must_participate', pct: poll.quorum_pct)}\n"
    end

    poll.results.select { |r| r['test_operator'] }.each do |option|
      md "- #{t("poll_option_form.name_#{option['test_operator']}_#{option['test_against']}", percent: option['test_percent'], name: option['name'])}\n"
    end
  end

  def render_results(poll)
    if (poll.decided_voters_count > 0) || poll.closed_at
      if poll.show_results?
        md "**#{t(poll.closed_at ? :'poll_common.results' : :'poll_common.current_results')}**\n"
        md "\n"

        if poll.poll_type == "meeting"
          render_meeting_table(poll)
        else
          render_simple_table(poll)
        end

        md "\n"
      else
        md "**#{t('poll_common_action_panel.results_hidden_until_closed')}**\n"
      end

      render_undecided(poll)
    end
  end

  def render_simple_table(poll)
    table = Terminal::Table.new do |tbl|
      tbl.style = { border: :unicode }
      tbl.headings = poll.result_columns.map { |col| simple_heading_for(col) }.compact
      poll.results.each do |option|
        tbl << poll.result_columns.map { |col| simple_cell_for(col, option) }.compact
      end
    end

    md "```\n#{table}\n```\n"
  end

  def render_meeting_table(poll)
    blocks = { 0 => '  ', 1 => "\u2591\u2591", 2 => "\u2593\u2593" }
    votes_label = t(:'poll_common.votes')

    table = Terminal::Table.new do |tbl|
      tbl.style = { border: :unicode }
      tbl.headings = [poll.time_zone, votes_label, *poll.decided_voters.map(&:avatar_initials)]
      poll.poll_options.each do |poll_option|
        tbl << [
          option_name(poll_option.name, poll.poll_option_name_format, @recipient.time_zone, @recipient.date_time_pref),
          ((poll_option.total_score.to_f) / 2).to_s.gsub('.0', ''),
          *poll.decided_voters.map { |user| blocks[poll_option.voter_scores.fetch(user.id.to_s, 0)] }
        ]
      end
    end

    md "```\n#{table}\n```\n"
  end

  def render_undecided(poll)
    nom = poll.decided_voters_count
    dnom = poll.voters_count
    pct = dnom > 0 ? (nom.to_f / dnom.to_f * 100).to_i : 0

    md "#{t('poll_common_percent_voted.pct_participation', num: nom, total: dnom, pct: pct)}\n"

    if poll.active? && poll.undecided_voters.any?
      md "**#{t('poll.waiting_for_votes_from')}**: #{poll.undecided_voters.map(&:username).join(', ')}\n"
    end
  end

  def render_discussion_undecided(eventable)
    usernames = eventable.polls.map(&:undecided_voters).flatten.uniq.map(&:username)
    return unless usernames.any?

    md "**#{t('poll.waiting_for_votes_from')}**: #{usernames.join(', ')}\n"
  end

  def render_stance_choices(stance)
    stance.stance_choices.each do |choice|
      md "#{option_name(choice.poll_option.name, stance.poll.poll_option_name_format, @recipient.time_zone, @recipient.date_time_pref)}\n"
    end
  end

  def render_meeting_stance_choices(stance)
    blocks = { 0 => '  ', 1 => "\u2591\u2591", 2 => "\u2593\u2593" }
    vote_label = t(:'poll_common.vote')

    table = Terminal::Table.new do |tbl|
      tbl.style = { border: :unicode }
      tbl.headings = [stance.poll.time_zone, vote_label]
      stance.stance_choices.each do |stance_choice|
        tbl << [
          option_name(stance_choice.poll_option.name, stance.poll.poll_option_name_format, @recipient.time_zone, @recipient.date_time_pref),
          blocks[stance_choice.score]
        ]
      end
    end

    md "```\n#{table}\n```\n"
  end

  # Private helpers for render_simple_table
  def simple_heading_for(col)
    case col
    when 'chart' then t(:"poll_common.results")
    when 'name' then t('common.option')
    when 'score_percent' then t('poll_ranked_choice_form.pct_of_points')
    when 'votes_cast_percent' then t('poll_ranked_choice_form.pct_of_votes_cast')
    when 'voter_percent' then t('poll_ranked_choice_form.pct_of_voters')
    when 'rank' then t('poll_ranked_choice_form.rank')
    when 'score' then t('poll_ranked_choice_form.points')
    when 'average' then t('poll_ranked_choice_form.mean')
    when 'voter_count' then t('membership_card.voters')
    when 'votes' then t('poll_common.votes')
    when 'voters' then nil
    end
  end

  def simple_cell_for(col, option)
    case col
    when 'chart'
      if ['pie', 'bar'].include? @poll.chart_type
        ("\u2593" * (option[:max_score_percent].to_i / 10)) + (' ' * (10 - (option[:max_score_percent].to_i / 10)))
      end
    when 'name'
      option_name(option[:name], option[:name_format], @recipient.time_zone, @recipient.date_time_pref)
    when 'rank' then { value: option[:rank], alignment: :right }
    when 'score' then { value: option[:score], alignment: :right }
    when 'voter_count', 'votes' then { value: option[:voter_count], alignment: :right }
    when 'average' then { value: option[:average].round(1), alignment: :right }
    when 'voter_percent' then { value: option[:voter_percent].round, alignement: :right }
    when 'score_percent', 'votes_cast_percent'
      { value: option[:score_percent].nil? ? '' : option[:score_percent].round, alignment: :right }
    when 'voters' then nil
    end
  end
end
