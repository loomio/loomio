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

    Paper = Struct.new(:prefs, :count, :value, :holder)

    def initialize(ballots, seats, quota_type, poll_options)
      @seats = seats
      @quota_type = quota_type
      @candidate_ids = poll_options.map(&:id)
      @candidate_names = poll_options.each_with_object({}) { |po, h| h[po.id] = po.name }

      # Identical ballots follow identical paths, so count them as one parcel.
      @papers = ballots.tally.map { |prefs, count| Paper.new(prefs.dup, count, 1.0, nil) }
    end

    def count
      return empty_result if @papers.empty?

      @elected = []
      @rounds = []
      @continuing = Set.new(@candidate_ids)
      @surplus_pending = []
      @retained = {}
      @tied = []
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
          quota: round_to(6, @quota)
        }
        @rounds << round_data

        elect_reaching_quota(totals, round_data)
        break if @elected.size >= @seats

        # Rule 53: when the continuing candidates fit the remaining seats,
        # they are all elected.
        if @continuing.size <= @seats - @elected.size
          @continuing.sort_by { |cid| -totals[cid] }.each { |cid| elect_candidate(cid, round_data) }
          @continuing.clear
          break
        end

        if (cid = @surplus_pending.max_by { |pending| totals[pending] })
          transfer_surplus(cid, totals[cid], round_data)
        else
          lowest = totals.slice(*@continuing).values.min
          tied_cids = @continuing.select { |cid| totals[cid] == lowest }

          if tied_cids.size > 1 && @continuing.size - 1 <= @seats - @elected.size
            # Tie affects the outcome: record it and stop counting.
            @tied = @continuing.map { |cid| { poll_option_id: cid, name: @candidate_names[cid] } }
            round_data[:tied] = @continuing.to_a
            break
          end

          exclude(tied_cids.min, round_data)
        end
      end

      {
        quota: round_to(6, @quota),
        seats: @seats,
        method: 'scottish',
        quota_type: @quota_type,
        elected: @elected,
        tied: @tied,
        rounds: @rounds
      }
    end

    private

    def empty_result
      { quota: 0, seats: @seats, method: 'scottish', quota_type: @quota_type, elected: [], tied: [], rounds: [] }
    end

    # Votes held by each continuing or elected candidate. An elected candidate
    # whose surplus has been transferred keeps exactly the quota.
    def current_totals
      totals = @continuing.each_with_object({}) { |cid, h| h[cid] = 0.0 }
      @elected.each { |e| totals[e[:poll_option_id]] = @retained.fetch(e[:poll_option_id], 0.0) }
      @papers.each do |paper|
        totals[paper.holder] += paper.count * paper.value if paper.holder && totals.key?(paper.holder)
      end
      totals
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
    # value × surplus / total, leaving the candidate with the quota.
    def transfer_surplus(cid, total, round_data)
      @surplus_pending.delete(cid)
      surplus = total - @quota
      transfers = move_papers_from(cid) { |value| value * surplus / total }
      @retained[cid] = @quota
      round_data[:transfers][cid.to_s] = format_tallies(transfers) if transfers.any?
    end

    # Rule 51: the excluded candidate's papers move on at their current value.
    def exclude(cid, round_data)
      @continuing.delete(cid)
      round_data[:eliminated] << cid
      transfers = move_papers_from(cid) { |value| value }
      round_data[:transfers][cid.to_s] = format_tallies(transfers) if transfers.any?
    end

    def move_papers_from(cid)
      transfers = Hash.new(0.0)
      @papers.each do |paper|
        next unless paper.holder == cid

        paper.value = yield(paper.value)
        paper.holder = next_continuing(paper)
        transfers[paper.holder] += paper.count * paper.value if paper.holder
      end
      transfers
    end

    def next_continuing(paper)
      paper.prefs.find { |cid| @continuing.include?(cid) }
    end

    def format_tallies(hash)
      hash.transform_keys(&:to_s).transform_values { |v| round_to(6, v) }
    end

    def round_to(precision, value)
      value.round(precision)
    end
  end
end
