module StvCountService
  class ScottishCounter
    # Weighted Inclusive Gregory Method (WIGM) as used in Scottish local
    # elections (Scottish Local Government Elections Order 2011, Schedule 1,
    # rules 46–53).
    #
    # The count proceeds in stages. At the start of each stage every continuing
    # candidate whose votes reach the quota is elected, all together. The stage
    # then does one thing:
    #
    #   * transfers the largest untransferred surplus, moving every paper the
    #     elected candidate holds to its next continuing preference at
    #     value × surplus / total; or, when no surplus remains,
    #   * excludes the continuing candidate with the fewest votes, moving their
    #     papers to the next continuing preference at their current value.
    #
    # Papers only ever move to continuing candidates, so a surplus never lands
    # on a candidate who has already been elected. Papers with no further
    # continuing preference become non-transferable.
    #
    # Values are exact Rationals. Rule 49(3) calculates each transferred
    # paper's new value to five decimal places, ignoring any remainder, so
    # every value and total is a whole number of 0.00001 votes and comparisons
    # with the quota are exact.

    include TieExploration

    VALUE_SCALE = 100_000

    Paper = Struct.new(:prefs, :count, :value, :holder)

    def initialize(ballots, seats, quota_type, poll_options)
      @seats = seats
      @quota_type = quota_type
      @candidate_ids = poll_options.map(&:id)
      @candidate_names = poll_options.each_with_object({}) { |po, h| h[po.id] = po.name }

      # Blank ballots are not valid votes (rule 47 counts valid papers for the
      # quota). Identical ballots follow identical paths, so count them as one
      # parcel.
      @ballots = ballots.reject(&:empty?).tally
    end

    # One pass of the count, choosing from `tie_choices` at each tie the rules
    # cannot break (see TieExploration).
    def count_pass(tie_choices)
      return empty_result if @ballots.empty?

      @tie_choices = tie_choices.dup
      @papers = @ballots.map { |prefs, count| Paper.new(prefs, count, Rational(1), nil) }
      @history = []
      @unresolved_tie = nil
      @elected = []
      @rounds = []
      @continuing = Set.new(@candidate_ids)
      @surplus_pending = []
      @retained = {}
      @rounding_loss = Rational(0)
      @quota = QuotaCalculator.calculate(@papers.sum(&:count), @seats, @quota_type)

      @papers.each { |paper| paper.holder = next_continuing(paper) }

      loop do
        totals = current_totals
        round_data = {
          round: @rounds.size + 1,
          tallies: format_tallies(totals),
          elected: [],
          eliminated: [],
          transfers: {},
          quota: format_number(@quota),
          non_transferable: format_number(exhausted_votes + @rounding_loss)
        }
        @rounds << round_data
        @history << totals

        elect_reaching_quota(totals, round_data)
        break if @elected.size >= @seats

        # Rule 53: when the continuing candidates fit the remaining seats,
        # they are all elected.
        if @continuing.size <= @seats - @elected.size
          @continuing.sort_by { |cid| -totals[cid] }.each { |cid| elect_candidate(cid, round_data) }
          @continuing.clear
          break
        end

        if @surplus_pending.any?
          # Rule 50: transfer the largest surplus first.
          largest = @surplus_pending.map { |cid| totals[cid] }.max
          cid = break_tie(@surplus_pending.select { |pending| totals[pending] == largest }, :max, round_data)
          break unless cid

          transfer_surplus(cid, totals[cid], round_data)
        else
          # Rule 51: exclude the candidate with the fewest votes.
          lowest = @continuing.map { |cid| totals[cid] }.min
          tied_cids = @continuing.select { |cid| totals[cid] == lowest }

          # Excluding candidates with no votes moves no papers, so when none of
          # them can be elected the order they go in cannot matter.
          if lowest.zero? && @continuing.size - tied_cids.size >= @seats - @elected.size
            cid = tied_cids.min
          else
            cid = break_tie(tied_cids, :min, round_data)
            break unless cid
          end

          exclude(cid, round_data)
        end
      end

      {
        quota: format_number(@quota),
        seats: @seats,
        method: 'scottish',
        quota_type: @quota_type,
        elected: @elected,
        tied: [],
        rounds: @rounds,
        unresolved_tie: @unresolved_tie
      }.compact
    end

    private

    def empty_result
      { quota: 0, seats: @seats, method: 'scottish', quota_type: @quota_type, elected: [], tied: [], rounds: [] }
    end

    # Votes held by each continuing or elected candidate. An elected candidate
    # whose surplus has been transferred keeps exactly the quota.
    def current_totals
      totals = @continuing.each_with_object({}) { |cid, h| h[cid] = Rational(0) }
      @elected.each { |e| totals[e[:poll_option_id]] = @retained.fetch(e[:poll_option_id], Rational(0)) }
      @papers.each do |paper|
        totals[paper.holder] += paper.count * paper.value if paper.holder && totals.key?(paper.holder)
      end
      totals
    end

    # Votes on papers with no continuing preference left. Together with the
    # value lost by truncating transfer values, these are the non-transferable
    # votes in a Scottish stage report.
    def exhausted_votes
      @papers.sum(Rational(0)) { |paper| paper.holder ? 0 : paper.count * paper.value }
    end

    def elect_reaching_quota(totals, round_data)
      reached = @continuing.select { |cid| totals[cid] >= @quota }.sort_by { |cid| -totals[cid] }
      reached.each do |cid|
        break if @elected.size >= @seats

        elect_candidate(cid, round_data)
        @continuing.delete(cid)
        @surplus_pending << cid if totals[cid] > @quota
      end
    end

    def elect_candidate(cid, round_data)
      @elected << {
        poll_option_id: cid,
        name: @candidate_names[cid],
        round_elected: round_data[:round]
      }
      round_data[:elected] << cid
    end

    # Rule 49: every paper the candidate holds moves on at
    # value × surplus / total, truncated to five decimal places, leaving the
    # candidate with the quota.
    def transfer_surplus(cid, total, round_data)
      @surplus_pending.delete(cid)
      surplus = total - @quota
      transfers, moved = move_papers_from(cid) { |value| truncate_value(value * surplus / total) }
      @rounding_loss += surplus - moved
      @retained[cid] = @quota
      round_data[:transfers][cid.to_s] = format_tallies(transfers) if transfers.any?
    end

    # Rule 51: the excluded candidate's papers move on at their current value.
    def exclude(cid, round_data)
      @continuing.delete(cid)
      round_data[:eliminated] << cid
      transfers, _moved = move_papers_from(cid) { |value| value }
      round_data[:transfers][cid.to_s] = format_tallies(transfers) if transfers.any?
    end

    # Moves the candidate's papers to their next continuing preferences,
    # revaluing each with the block. Returns the votes received by each
    # candidate and the total value moved, including papers that exhaust.
    def move_papers_from(cid)
      transfers = Hash.new(Rational(0))
      moved = Rational(0)
      @papers.each do |paper|
        next unless paper.holder == cid

        paper.value = yield(paper.value)
        paper.holder = next_continuing(paper)
        moved += paper.count * paper.value
        transfers[paper.holder] += paper.count * paper.value if paper.holder
      end
      [transfers, moved]
    end

    def next_continuing(paper)
      paper.prefs.find { |cid| @continuing.include?(cid) }
    end

    def truncate_value(value)
      Rational((value * VALUE_SCALE).floor, VALUE_SCALE)
    end

    def format_tallies(hash)
      hash.transform_keys(&:to_s).transform_values { |v| format_number(v) }
    end

    # Stored results are JSON, so whole numbers stay integers and fractions
    # become floats rounded for display.
    def format_number(value)
      value.to_r.denominator == 1 ? value.to_i : value.to_f.round(6)
    end
  end
end
