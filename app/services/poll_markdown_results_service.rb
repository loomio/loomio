class PollMarkdownResultsService
  def self.render(poll:, user:)
    new(poll, user).render
  end

  def initialize(poll, user)
    @poll = poll
    @user = user
  end

  # Mirror the chatbot result branches while emitting native Markdown tables.
  def render
    case poll.poll_type
    when "meeting" then meeting_results
    when "stv" then stv_results
    else simple_results
    end
  end

  private

  attr_reader :poll, :user

  def simple_results
    columns = poll.result_columns.reject { |column| %w[chart voters].include?(column) }
    columns << "voters"
    rows = poll.results.map do |result|
      columns.map { |column| simple_cell(column, result) }
    end
    markdown_table(columns.map { |column| simple_heading(column) }, rows)
  end

  def meeting_results
    voters = voter_stances.map(&:participant)
    headings = [poll.time_zone, t("poll_common.votes"), *voters.map { |voter| voter_label(voter) }]
    rows = poll.poll_options.map do |option|
      scores = voter_stances.map do |stance|
        score = stance.stance_choices.find { |choice| choice.poll_option_id == option.id }&.score.to_i
        {0 => t("thread_markdown.unavailable"), 1 => t("thread_markdown.available_if_needed"), 2 => t("thread_markdown.available")}.fetch(score)
      end
      [option_name(option.name, poll.poll_option_name_format), format_number(option.total_score.to_f / 2), *scores]
    end
    markdown_table(headings, rows)
  end

  def stv_results
    results = poll.stv_results
    return simple_results unless results

    sections = []
    elected = results["elected"] || []
    tied = results["tied"] || []
    rounds = results["rounds"] || []
    quota = results["quota"]

    if elected.any?
      rows = elected.map do |candidate|
        id = candidate["poll_option_id"].to_s
        round = rounds.find { |item| item["round"] == candidate["round_elected"] }
        first = rounds.first&.dig("tallies", id)
        final = round&.dig("tallies", id)
        [candidate["name"], candidate["round_elected"], format_number(first), format_number(final), format_number(final && quota ? final - quota : nil)]
      end
      sections << "#### #{t('poll_stv_results.elected')}\n\n#{markdown_table([t('poll_stv_results.candidate'), t('poll_stv_results.round_elected'), t('poll_stv_results.first_preferences'), t('poll_stv_results.final_tally'), t('poll_stv_results.quota_surplus')], rows)}"
    end

    if tied.any?
      rows = tied.map do |candidate|
        first = rounds.first&.dig("tallies", candidate["poll_option_id"].to_s)
        [candidate["name"], format_number(first)]
      end
      sections << "#### #{t('poll_stv_results.tied')}\n\n#{markdown_table([t('poll_stv_results.candidate'), t('poll_stv_results.first_preferences')], rows)}"
    end

    if rounds.any?
      elected_so_far = []
      eliminated_so_far = []
      states = rounds.map do |round|
        elected_so_far += round["elected"] || []
        eliminated_so_far += round["eliminated"] || []
        [elected_so_far.dup, eliminated_so_far.dup]
      end
      rows = poll.poll_options.map do |candidate|
        values = rounds.each_with_index.map do |round, index|
          tally = round["tallies"]&.dig(candidate.id.to_s)
          previous = index.positive? && (states[index - 1][0].include?(candidate.id) || states[index - 1][1].include?(candidate.id))
          if previous
            "-"
          elsif (round["elected"] || []).include?(candidate.id)
            "#{format_number(tally)} ✓"
          elsif (round["eliminated"] || []).include?(candidate.id)
            "#{format_number(tally)} ✗"
          elsif (round["tied"] || []).include?(candidate.id)
            "#{format_number(tally)} ≈"
          else
            format_number(tally)
          end
        end
        [candidate.name, *values]
      end
      table = markdown_table([t('poll_stv_results.candidate'), *rounds.map { |round| round["round"] }], rows)
      sections << "#{table}\n\n#{t('poll_stv_results.quota_info', method: t("poll_stv_results.method_#{results['method']}"), quota_type: t("poll_stv_results.quota_#{results['quota_type']}"), quota: format_number(quota))}\n\n✓ = #{t('poll_stv_results.elected')}, ✗ = #{t('poll_stv_results.not_elected')}, ≈ = #{t('poll_stv_results.tied')}"
    end

    sections.join("\n\n")
  end

  def simple_heading(column)
    {
      "name" => t("common.option"),
      "score_percent" => t("poll_ranked_choice_form.pct_of_points"),
      "votes_cast_percent" => t("poll_ranked_choice_form.pct_of_votes_cast"),
      "voter_percent" => t("poll_ranked_choice_form.pct_of_voters"),
      "target_percent" => t("thread_markdown.target"),
      "rank" => t("poll_ranked_choice_form.rank"),
      "score" => t("poll_ranked_choice_form.points"),
      "average" => t("poll_ranked_choice_form.mean"),
      "stv_status" => t("poll_common.status"),
      "voter_count" => t("membership_card.voters"),
      "votes" => t("poll_common.votes"),
      "voters" => t("thread_markdown.voters")
    }.fetch(column)
  end

  def simple_cell(column, result)
    case column
    when "name" then option_name(result[:name], result[:name_format])
    when "stv_status" then result[:stv_status] ? t("poll_stv_results.#{result[:stv_status]}") : ""
    when "rank", "score" then result[column.to_sym]
    when "voter_count", "votes" then result[:voter_count]
    when "average" then result[:average].round(1)
    when "voter_percent" then percent(result[:voter_percent])
    when "score_percent", "votes_cast_percent" then percent(result[:score_percent])
    when "target_percent" then percent(result[:target_percent])
    when "voters" then voters_for_result(result)
    end
  end

  def voters_for_result(result)
    return t("thread_markdown.no_voters") if result[:voter_count].to_i.zero?
    return t("thread_markdown.anonymous") if poll.anonymous?

    voters = case result[:id].to_i
    when -1
      poll.undecided_voters.map(&:name)
    when 0
      voter_stances.select(&:none_of_the_above?).map { |stance| stance.participant.name }
    else
      voter_stances.filter_map do |stance|
        choice = stance.stance_choices.find { |item| item.poll_option_id == result[:id] }
        next unless choice

        poll.has_variable_score ? "#{voter_label(stance.participant)} (#{t('thread_markdown.score', value: choice.score)})" : voter_label(stance.participant)
      end
    end
    voters.sort.join("; ").presence || t("thread_markdown.no_voters")
  end

  def voter_stances
    @voter_stances ||= poll.stances.latest.decided.where(revoked_at: nil, redacted_at: nil).where.not(cast_at: nil).includes(:participant, :stance_choices).to_a
  end

  def voter_label(voter)
    poll.anonymous? ? t("thread_markdown.anonymous") : voter.name
  end

  def option_name(name, format)
    case format
    when "i18n" then t(name)
    when "iso8601" then ApplicationController.helpers.format_iso8601_for_humans(name, user.time_zone, user.date_time_pref)
    else name
    end
  end

  def markdown_table(headings, rows)
    header = "| #{headings.map { |value| table_cell(value) }.join(' | ')} |"
    separator = "| #{headings.map { '---' }.join(' | ')} |"
    body = rows.map { |row| "| #{row.map { |value| table_cell(value) }.join(' | ')} |" }
    [header, separator, *body].join("\n")
  end

  def table_cell(value)
    value.to_s.squish.gsub("\\", "\\\\").gsub("|", "\\|")
  end

  def percent(value)
    value.nil? ? "" : "#{value.round}%"
  end

  def format_number(value)
    return "-" if value.nil?
    value == value.to_i ? value.to_i.to_s : value.round(2).to_s
  end

  def t(key, **options)
    I18n.t(key, **options)
  end
end
