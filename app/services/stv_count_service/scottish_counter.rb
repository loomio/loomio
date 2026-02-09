module StvCountService
  class ScottishCounter
    # Weighted Inclusive Gregory Method (WIGM) as used in Scottish local elections.
    #
    # When a candidate is elected with a surplus:
    #   transfer_value = surplus / total_votes_for_candidate
    #   Each ballot sitting with the elected candidate has its weight multiplied
    #   by transfer_value and moves to the next continuing preference.
    #   Exhausted ballots lose their weight (non-transferable).
    #
    # When a candidate is eliminated:
    #   Each ballot sitting with them transfers to next continuing preference
    #   at its current weight (unchanged).

    def initialize(ballots, seats, quota_type, poll_options)
      @seats = seats
      @quota_type = quota_type
      @candidate_ids = poll_options.map(&:id)
      @candidate_names = poll_options.each_with_object({}) { |po, h| h[po.id] = po.name }

      # Each ballot: { prefs: [ordered poll_option_ids], weight: Float }
      @ballots = ballots.map { |prefs| { prefs: prefs.dup, weight: 1.0 } }
    end

    def count
      @elected = []
      @eliminated = []
      @rounds = []
      @continuing = @candidate_ids.dup

      return empty_result if @ballots.empty?

      @quota = QuotaCalculator.calculate(@ballots.size, @seats, @quota_type)

      loop do
        break if @elected.size >= @seats
        break if @continuing.empty?

        tallies = tally_votes

        round_data = {
          round: @rounds.size + 1,
          tallies: format_tallies(tallies),
          elected: [],
          eliminated: [],
          transfers: {},
          quota: round_to(6, @quota)
        }

        # If remaining candidates <= remaining seats, elect them all
        remaining_seats = @seats - @elected.size
        if @continuing.size <= remaining_seats
          @continuing.each do |cid|
            elect_candidate(cid, round_data)
          end
          @continuing.clear
          @rounds << round_data
          break
        end

        # Elect candidates meeting quota (highest first)
        over_quota = tallies.select { |_cid, votes| votes >= @quota }
                           .sort_by { |_cid, votes| -votes }

        if over_quota.any?
          over_quota.each do |cid, votes|
            break if @elected.size >= @seats
            elect_candidate(cid, round_data)
            @continuing.delete(cid)

            surplus = votes - @quota
            if surplus > 0 && @continuing.any?
              transfer_value = surplus / votes
              transfers = redistribute_elected(cid, transfer_value)
              round_data[:transfers][cid.to_s] = format_tallies(transfers) if transfers.any?
            else
              # No surplus or no continuing candidates — zero out ballots for this candidate
              zero_out_ballots_for(cid)
            end
          end
        else
          # Eliminate candidate with fewest votes; tie-break by lowest id
          min_votes = tallies.values.min
          eliminated_cid = tallies.select { |_cid, v| v == min_votes }.keys.min

          @eliminated << eliminated_cid
          @continuing.delete(eliminated_cid)
          round_data[:eliminated] << eliminated_cid

          transfers = redistribute_eliminated(eliminated_cid)
          round_data[:transfers][eliminated_cid.to_s] = format_tallies(transfers) if transfers.any?
        end

        @rounds << round_data

        # Safety: prevent infinite loops
        break if @rounds.size > @candidate_ids.size * 2
      end

      {
        quota: round_to(6, @quota),
        seats: @seats,
        method: 'scottish',
        quota_type: @quota_type,
        elected: @elected,
        rounds: @rounds
      }
    end

    private

    def empty_result
      { quota: 0, seats: @seats, method: 'scottish', quota_type: @quota_type, elected: [], rounds: [] }
    end

    def elect_candidate(cid, round_data)
      @elected << {
        poll_option_id: cid,
        name: @candidate_names[cid],
        round_elected: round_data[:round]
      }
      round_data[:elected] << cid
    end

    def tally_votes
      tallies = @continuing.each_with_object({}) { |cid, h| h[cid] = 0.0 }
      @ballots.each do |ballot|
        next if ballot[:weight] <= 0
        top = top_continuing(ballot[:prefs])
        tallies[top] += ballot[:weight] if top
      end
      tallies
    end

    def top_continuing(prefs)
      prefs.find { |cid| @continuing.include?(cid) }
    end

    # For a candidate who just got elected: find all ballots currently sitting
    # with them, multiply weight by transfer_value, and let them flow to next pref.
    def redistribute_elected(elected_cid, transfer_value)
      transfers = Hash.new(0.0)
      @ballots.each do |ballot|
        next if ballot[:weight] <= 0
        top = top_sitting_with(ballot[:prefs], elected_cid)
        next unless top == elected_cid

        next_pref = ballot[:prefs].find { |cid| @continuing.include?(cid) }
        old_weight = ballot[:weight]
        ballot[:weight] = old_weight * transfer_value

        if next_pref
          transfers[next_pref] += ballot[:weight]
        end
        # If exhausted, weight is effectively lost (ballot still exists but
        # won't tally for anyone since no continuing preference found)
      end
      transfers
    end

    # For an eliminated candidate: transfer ballots at full weight to next preference.
    def redistribute_eliminated(eliminated_cid)
      transfers = Hash.new(0.0)
      @ballots.each do |ballot|
        next if ballot[:weight] <= 0
        top = top_sitting_with(ballot[:prefs], eliminated_cid)
        next unless top == eliminated_cid

        next_pref = ballot[:prefs].find { |cid| @continuing.include?(cid) }
        if next_pref
          transfers[next_pref] += ballot[:weight]
        end
        # Weight unchanged; ballot naturally flows to next continuing pref on re-tally
      end
      transfers
    end

    # Find the top preference that is either the target candidate or still continuing.
    # This tells us which candidate this ballot is "sitting with".
    def top_sitting_with(prefs, target_cid)
      prefs.find { |cid| cid == target_cid || @continuing.include?(cid) }
    end

    # Zero out ballots sitting with a candidate who was elected with no surplus.
    def zero_out_ballots_for(cid)
      @ballots.each do |ballot|
        top = top_sitting_with(ballot[:prefs], cid)
        ballot[:weight] = 0.0 if top == cid
      end
    end

    def format_tallies(hash)
      hash.transform_keys(&:to_s).transform_values { |v| round_to(6, v) }
    end

    def round_to(precision, value)
      value.round(precision)
    end
  end
end
