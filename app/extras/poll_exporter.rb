class PollExporter

  def initialize (poll)
    @poll = poll
  end

  def meta_table
    outcome = @poll.current_outcome
    engagement = nil
    I18n.with_locale(:en) {
      voted = @poll.stances_count
      total = @poll.members.count
      engagement =  I18n.t(:'export.poll.percent_voted', num:voted ,denom:total, percent:"#{(voted*100/total)}%")
    }
    {
      author: @poll.author.name,
      closing_at:  (@poll.closing_at unless @poll.closed_at) ,
      closed_at: @poll.closed_at,
      engagement:engagement,
      group_name: @poll.group.full_name,
      outcome_author: outcome&.author,
      outcome_created_at: outcome&.created_at,
      outcome_statement: outcome&.statement,
    }.compact
  end

  def stance_matrix
    rows = []
    rows << ["Participant", @poll.poll_options.map {|po| po.display_name}, "Reason"].flatten

    totals = [0]*@poll.poll_options.size

    ## for each participant show the
    @poll.stances.latest.each do |stance|
      user = stance.participant
      row = [user.name]

      @poll.poll_options.each do |poll_option|
        # find the value for this stance_choice for poll option in this stance
        stance_choice = stance.stance_choices.find {|choice| choice.poll_option.id == poll_option.id}
        row << (stance_choice&.score||0).to_s
      end
      row << stance.reason

      rows << row
    end

    rows << ["total", @poll.poll_options.map(&:total_score)].flatten
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

  def to_csv (opts={})
    CSV.generate do |csv|
      # [Poll]
      #
      # Title
        csv << ["Export for #{@poll.title}"]

        meta_table.keys.each {|key|
          csv<<[key.to_s.humanize, meta_table[key]]
        }
        csv << []
        stance_matrix.each {|row|csv<<row}
        ## Aditional for each option show the users that have chosen and their reason
        if(@poll.is_single_vote?)
          csv << []
          nametable = user_reasons

          ## each option has a table
          nametable.keys.each do |key|
            csv << [key]
            nametable[key].each {|row|csv<<row}
          end
        end
    end
  end
end
