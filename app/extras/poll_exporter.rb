class PollExporter
  include Routing

  def initialize(poll)
    @poll = poll
  end

  def file_name
    "poll-#{@poll.id}-#{@poll.key}-#{@poll.title.parameterize}.csv"
  end

  def meta_table
    outcome = @poll.current_outcome

    {
      id: @poll.id,
      group_id: @poll.group_id,
      discussion_id: @poll.discussion_id,
      author_id: @poll.author.id,
      title: @poll.title,
      author_name: @poll.author.name,
      created_at: @poll.created_at,
      closed_at: @poll.closed_at,
      decided_voters_count: @poll.decided_voters_count,
      undecided_voters_count: @poll.undecided_voters_count,
      voters_count: @poll.voters_count,
      details: @poll.details,
      group_name: @poll.group&.full_name,
      discussion_title: @poll.discussion&.title,
      outcome_author_id: outcome&.author_id,
      outcome_author_name: outcome&.author&.name,
      outcome_created_at: outcome&.created_at,
      outcome_statement: outcome&.statement,
      poll_url: poll_url(@poll)
    }.compact
  end

  def to_csv(opts={})
    CSV.generate do |csv|
      csv << ['poll']
      csv << meta_table.keys
      csv << meta_table.values
      csv << ['poll_options']
      results = PollService.calculate_results(@poll, @poll.poll_options)
      keys = %w[id poll_id name name_format rank score score_percent max_score_percent voter_percent average voter_count color]
      csv << keys
      results.each { |r| csv << r.slice(*keys).values }
      csv << ['votes']
      csv << ['id', 'poll_id', 'voter_id', 'voter_name', 'created_at', 'updated_at', 'reason', 'reason_format'] + @poll.poll_option_names
      @poll.stances.latest.each do |stance|
        line = [
          stance.id,
          stance.poll_id,
          stance.participant_id,
          stance.author_name,
          stance.created_at&.iso8601,
          stance.updated_at&.iso8601,
          stance.reason,
          stance.reason_format]

        @poll.poll_options.each do |poll_option|
          line.push(stance.option_scores[poll_option.id.to_s] || nil)
        end
        csv << line
      end
    end
  end
end
