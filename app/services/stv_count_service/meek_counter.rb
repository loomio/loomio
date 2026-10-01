module StvCountService
  class MeekCounter
    # Meek STV counting method.
    #
    # Each candidate has a "keep value" (initially 1.0) representing what fraction
    # of a vote they retain. Elected candidates have their keep value reduced so
    # they only keep quota-worth of votes; the rest flows through to later prefs.
    # Eliminated candidates have keep value set to 0, so votes pass through them
    # as if they were never in the race.
    #
    # The method iterates until keep values converge (change < OMEGA per iteration).
    #
    # Arithmetic is fixed point with nine decimal places, as in the Hill,
    # Wichmann and Woodall reference algorithm: votes and keep values are
    # Integers counting 0.000000001 units. Each share a candidate takes from a
    # ballot and each new keep value is rounded up, so the ballot's remaining
    # weight never goes negative and comparisons with the quota are exact.

    SCALE = 1_000_000_000
    OMEGA = 100        # convergence threshold, 0.0000001 votes
    MAX_ITERATIONS = 1000

    def initialize(ballots, seats, quota_type, poll_options)
      @seats = seats
      @quota_type = quota_type
      @candidate_ids = poll_options.map(&:id)
      @candidate_names = poll_options.each_with_object({}) { |po, h| h[po.id] = po.name }

      # Each ballot is an ordered array of poll_option_ids
      # Blank ballots hold no votes. Identical ballots follow identical paths,
      # so count them together.
      @ballots = ballots.reject(&:empty?).tally.map { |prefs, count| [prefs.dup, count] }
    end

    def count
      return empty_result if @ballots.empty?

      @elected = []
      @tied = []
      @eliminated_set = Set.new
      @rounds = []
      @continuing = Set.new(@candidate_ids)

      # Keep values: elected candidates < 1.0, eliminated = 0.0, continuing = 1.0
      @keep = @candidate_ids.each_with_object({}) { |cid, h| h[cid] = SCALE }

      loop do
        break if @elected.size >= @seats
        break if @continuing.empty?

        # Iterate to find stable vote distribution
        tallies, quota, excess = iterate_to_stability

        round_data = {
          round: @rounds.size + 1,
          tallies: format_tallies(tallies),
          elected: [],
          eliminated: [],
          quota: format_number(quota),
          keep_values: @keep.transform_values { |v| format_number(v) }.transform_keys(&:to_s)
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

        # Elect any candidate reaching the quota
        newly_elected = tallies.select { |cid, votes| @continuing.include?(cid) && reached_quota?(votes, quota) }
                               .sort_by { |_cid, votes| -votes }

        if newly_elected.any?
          newly_elected.each do |cid, votes|
            break if @elected.size >= @seats
            elect_candidate(cid, round_data)
            @continuing.delete(cid)
            # Update keep value: candidate keeps only quota-worth
            @keep[cid] = ceil_div(@keep[cid] * quota, votes) if votes > 0
          end
        else
          # Eliminate candidate with fewest votes
          continuing_tallies = tallies.select { |cid, _| @continuing.include?(cid) }
          min_votes = continuing_tallies.values.min
          tied_cids = continuing_tallies.select { |_cid, v| v == min_votes }.keys

          if tied_cids.size > 1 && @continuing.size - 1 <= (@seats - @elected.size)
            # Tie affects the outcome: record tie and stop counting
            @tied = @continuing.map { |cid| { poll_option_id: cid, name: @candidate_names[cid] } }
            round_data[:tied] = @continuing.to_a
            @rounds << round_data
            break
          end

          eliminated_cid = tied_cids.min
          @eliminated_set.add(eliminated_cid)
          @continuing.delete(eliminated_cid)
          @keep[eliminated_cid] = 0
          round_data[:eliminated] << eliminated_cid
        end

        @rounds << round_data

        # Safety
        break if @rounds.size > @candidate_ids.size * 2
      end

      {
        quota: @rounds.any? ? @rounds.last[:quota] : 0,
        seats: @seats,
        method: 'meek',
        quota_type: @quota_type,
        elected: @elected,
        tied: @tied,
        rounds: @rounds
      }
    end

    private

    def empty_result
      { quota: 0, seats: @seats, method: 'meek', quota_type: @quota_type, elected: [], tied: [], rounds: [] }
    end

    def elect_candidate(cid, round_data)
      @elected << {
        poll_option_id: cid,
        name: @candidate_names[cid],
        round_elected: round_data[:round]
      }
      round_data[:elected] << cid
    end

    # Distribute all ballots using current keep values, iterating until stable.
    # Returns [tallies_hash, quota, excess]
    def iterate_to_stability
      tallies = nil
      quota = nil
      excess = nil

      MAX_ITERATIONS.times do
        tallies = distribute_votes
        total_active = tallies.values.sum
        quota = compute_quota(total_active)
        excess = tallies.sum { |cid, v| @continuing.include?(cid) ? [v - quota, 0].max : 0 }

        # Update keep values for elected candidates
        changed = false
        tallies.each do |cid, votes|
          next unless @elected.any? { |e| e[:poll_option_id] == cid }
          next if votes == 0

          new_keep = ceil_div(@keep[cid] * quota, votes)
          if (new_keep - @keep[cid]).abs > OMEGA
            changed = true
          end
          @keep[cid] = new_keep
        end

        break unless changed
      end

      [tallies, quota, excess]
    end

    def distribute_votes
      tallies = @candidate_ids.each_with_object({}) { |cid, h| h[cid] = 0 }
      @exhausted = 0

      @ballots.each do |prefs, count|
        weight = SCALE

        prefs.each do |cid|
          keep = @keep[cid]
          next if keep == 0  # eliminated, skip

          share = [ceil_div(weight * keep, SCALE), weight].min
          tallies[cid] += share * count
          weight -= share
          break if weight == 0
        end

        @exhausted += weight * count  # whatever didn't go to any candidate
      end

      tallies
    end

    # Meek recomputes the quota from the votes still held by candidates on
    # each iteration, without rounding: the Droop quota is exactly
    # active / (seats + 1) and the Hare quota active / seats.
    def compute_quota(total_active)
      case @quota_type.to_s
      when 'hare' then Rational(total_active, @seats)
      else Rational(total_active, @seats + 1)
      end
    end

    # The exact Droop quota can be held by seats + 1 candidates at once, so a
    # candidate must exceed it. The Hare quota can only be held by `seats`
    # candidates, so reaching it is enough.
    def reached_quota?(votes, quota)
      @quota_type.to_s == 'hare' ? votes >= quota : votes > quota
    end

    def ceil_div(numerator, denominator)
      -(-numerator).div(denominator)
    end

    def format_tallies(hash)
      hash.select { |cid, _| @continuing.include?(cid) || @elected.any? { |e| e[:poll_option_id] == cid } }
          .transform_keys(&:to_s)
          .transform_values { |v| format_number(v) }
    end

    # Stored results are JSON, so convert fixed-point units to numbers there.
    def format_number(units)
      (units % SCALE).zero? ? (units / SCALE).to_i : (units.to_f / SCALE).round(9)
    end
  end
end
