class PollExporter
  include Routing

  def initialize(poll)
    @poll = poll
  end

  def file_name
    "#{@poll.title.parameterize}-#{I18n.t("common.action.export").downcase}.csv"
  end

  def label(key, *opts)
    I18n.t("poll.export.#{key}", *opts)
  end

  def meta_table
    outcome = @poll.current_outcome

    {
      title: @poll.title,
      author_id: @poll.author.id,
      author_name: @poll.author.name,
      created_at: @poll.created_at,
      closed_at: @poll.closed_at,
      decided_voters_count: @poll.decided_voters_count,
      undecided_voters_count: @poll.undecided_voters_count,
      voters_count: @poll.voters_count,
      stances: @poll.voters_count,
      participants: @poll.members.count,
      details: @poll.details,
      group_name: @poll.group&.full_name,
      discussion_title: @poll.discussion&.title,
      outcome_author: outcome&.author,
      outcome_created_at: outcome&.created_at,
      outcome_statement: outcome&.statement,
      poll_url: poll_url(@poll)
    }.compact
  end

  def stance_matrix
    rows = []
    rows << [I18n.t("poll.export.participant"), I18n.t("poll.export.user_id"), @poll.poll_options.map(&:name), I18n.t("poll.export.reason")].flatten

    ## for each participant show the
    @poll.stances.latest.each do |stance|
      user = stance.participant
      row = [user.name, user.id]

      @poll.poll_options.each do |poll_option|
        # find the value for this stance_choice for poll option in this stance
        stance_choice = stance.stance_choices.find_by(poll_option: poll_option)
        row << (stance_choice&.score||0).to_s
      end
      row << stance.reason

      rows << row
    end

    rows << [label("total"), @poll.poll_options.map(&:total_score)].flatten
    rows
  end

  def stance_list
    rows = []
    rows << [["created_at", "author", 'id', "is_latest"].map{ |name_label| label(name_label) }, @poll.poll_options.map(&:display_name)].flatten

    ## for each stance in chronological order
    @poll.stances.sort_by(&:created_at).each do |stance|
      user = stance.participant
      row = [stance.created_at, user.name, user.id, stance.latest]

      @poll.poll_options.each do |poll_option|
        # find the stance choice with this poll option and get its score
        stance_choice = stance.stance_choices.find_by(poll_option: poll_option)
        row << (stance_choice&.score||0).to_s
      end

      rows << row
    end
    rows
  end

  def to_csv(opts={})
    CSV.generate do |csv|
      meta_table.each {|key, value| csv << [I18n.t("poll.export.#{key}"), value]}
      csv << []
      stance_matrix.each {|row| csv << row}
    end
  end
end
