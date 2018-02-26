class PollExporter

  include Routing

  def initialize (poll)
    @poll = poll
  end

  def file_name
    "#{@poll.title.parameterize}-export.csv"
  end

  def poll_info (current_user)
     PollEmailInfo.new(recipient: current_user, event: @poll.created_event, action_name: :export)
  end

  def label (key, *opts)
    I18n.t("poll.export.#{key.downcase}".to_sym, *opts)
  end

  def meta_table
    outcome = @poll.current_outcome
    engagement = nil
    voted = @poll.stances_count
    total = @poll.members.count
    engagement =  label('percent_voted', num:voted ,denom:total, percent:"#{(voted*100/total)}%")

    {
      title: @poll.title,
      author: @poll.author.name,
      created_at: @poll.created_at,
      closing_at:  (@poll.closing_at unless @poll.closed_at),
      closed_at: @poll.closed_at,
      engagement:engagement,
      stances: @poll.stances_count,
      participants: @poll.members.count,
      details: @poll.details,
      group_name: @poll.group.full_name,
      outcome_author: outcome&.author,
      outcome_created_at: outcome&.created_at,
      outcome_statement: outcome&.statement,
      poll_url: poll_url(@poll)
    }.compact
  end

  def stance_matrix
    rows = []
    rows << [label("Participant"), @poll.poll_options.map(&:display_name), label("Reason")].flatten

    totals = (1..@poll.poll_options.size).map { 0 }

    ## for each participant show the
    @poll.stances.latest.each do |stance|
      user = stance.participant
      row = [user.name, stance.reason]

      @poll.poll_options.each do |poll_option|
        # find the value for this stance_choice for poll option in this stance
        stance_choice = stance.stance_choices.find_by(poll_option: poll_option)
        row << (stance_choice&.score||0).to_s
      end

      rows << row
    end

    rows << [label("total"), @poll.poll_options.map(&:total_score)].flatten
    rows
  end

  def user_reasons
    options = {}

    @poll.poll_options.each do |option|
      rows = []
      options[option.display_name + "(#{option.total_score})"] = rows

      if option.stances.empty?
        rows << ["No stances for this poll option"]
      else
        option.stances.latest.each do |stance|
          rows << [stance.user.name, stance.reason]
        end
      end
      rows << []
    end

    options
  end

  def stance_list
    rows = []
    rows << ["created_at", "author ", "is_latest", @poll.poll_options.map(&:display_name)].flatten.map{ |name_label| label(name_label) }

    ## for each participant show the
    @poll.stances.sort_by(&:created_at).each do |stance|
      user = stance.participant
      row = [stance.created_at, user.name, stance.latest]

      @poll.poll_options.each do |poll_option|
        # find the value for this stance_choice for poll option in this stance
        stance_choice = stance.stance_choices.find_by(poll_option: poll_option)
        row << (stance_choice&.score||0).to_s
      end

      rows << row
    end
    rows
  end


  def to_csv (opts={})
    CSV.generate do |csv|
        meta_table.each {|key, value| csv << [key.to_s.humanize, value]}
        csv << []
        stance_matrix.each {|row| csv << row}
    end
  end
end
