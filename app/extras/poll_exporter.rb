class PollExporter

  def initialize (poll)
    @poll = poll
  end

  def to_csv (opts={})
    CSV.generate do |csv|
      # [Poll]
      #
      # Title
        csv << ["Export for #{@poll.title}"]
        # details

        csv << []

        csv << ["Author", "closed at", "group", 'Url', "Outcome-Author", "Outcome-Created At", "Outcome-Statement"]

        # closing / closed at
        # Author name
        # group name (if part of group)
        # link to the poll (poll_url(poll))
        # Author name
        # created_at (when the outcome was set)
        # statement

        outcome = @poll.outcomes.last

        csv << [@poll.author.name, @poll.closing_at, @poll.group.name, "#{}", outcome&.author, outcome&.created_at, outcome&.statement]



        #
        # ----------------------- PATH A
        # [Poll Option] (ordered by priority)
        # Option name
        # (color)
        #
        # [Stance Choices]
        # User name
        # created_at
        # Score (might not need for proposal / count / meeting / poll)
    end
  end
end
