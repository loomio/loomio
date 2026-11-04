module StvCountService
  # Settles ties that the counting rules cannot break.
  #
  # The rules break a tie by looking back through earlier stages and, failing
  # that, by lot. Loomio does not draw lots: it reports a tie instead, but only
  # when the tie changes who is elected. A counter including this module
  # implements `count_pass(tie_choices)`, which counts until it meets a tie
  # with no preset choice and then stops, returning the partial result with
  # `unresolved_tie: { candidates:, continuing: }`. Each later pass is given
  # the choices to make at the ties it meets, in order.
  #
  # `count` tries every way of breaking every tie. When all of them elect the
  # same candidates, the tie did not matter and the count continues as if the
  # lowest candidate id had been chosen each time. Otherwise the result stops
  # at the first tie, elects the candidates who win in every branch, and
  # reports as tied those who win in only some branches. Should the branches
  # exceed PASSES_MAX, every continuing candidate at the first tie is reported
  # as tied.
  module TieExploration
    PASSES_MAX = 200

    def count
      first = count_pass([])
      return first unless first[:unresolved_tie]

      outcomes = Set.new
      @passes = 1
      complete = explore([], first, outcomes)

      if complete && outcomes.size == 1
        choices = []
        result = first
        while result[:unresolved_tie]
          choices << result[:unresolved_tie][:candidates].min
          result = count_pass(choices)
        end
        return result
      end

      tied_result(first, complete ? outcomes : nil)
    end

    private

    def explore(choices, result, outcomes)
      unless result[:unresolved_tie]
        outcomes << result[:elected].map { |e| e[:poll_option_id] }.to_set
        return true
      end

      result[:unresolved_tie][:candidates].all? do |cid|
        @passes += 1
        next false if @passes > PASSES_MAX

        branch = choices + [cid]
        explore(branch, count_pass(branch), outcomes)
      end
    end

    def tied_result(first, outcomes)
      elected_before = first[:elected].map { |e| e[:poll_option_id] }
      if outcomes
        elected_ids = outcomes.reduce(:&)
        possible_ids = outcomes.reduce(:|)
      else
        elected_ids = elected_before.to_set
        possible_ids = elected_ids | first[:unresolved_tie][:continuing]
      end

      elected = first[:elected] +
        @candidate_ids.select { |cid| elected_ids.include?(cid) && !elected_before.include?(cid) }
                      .map { |cid| { poll_option_id: cid, name: @candidate_names[cid], round_elected: nil } }
      tied = @candidate_ids.select { |cid| possible_ids.include?(cid) && !elected_ids.include?(cid) }
                           .map { |cid| { poll_option_id: cid, name: @candidate_names[cid] } }

      first.except(:unresolved_tie).merge(elected: elected, tied: tied)
    end

    # Breaks a tie by looking back through earlier stages, then by the next
    # preset choice. Returns nil and records the tie on the round when
    # neither decides it. `@history` holds each stage's totals, oldest first,
    # ending with the current stage; `pick` is :min or :max.
    def break_tie(cids, pick, round_data)
      cids = look_back(cids.sort, @history[0...-1], pick)
      return cids.first if cids.size == 1

      choice = @tie_choices.shift
      return choice if choice

      round_data[:tied] = cids
      @unresolved_tie = { candidates: cids, continuing: @continuing.to_a }
      nil
    end

    # Rules 50 and 52: break a tie by the votes the tied candidates held at
    # the most recent preceding stage at which they were unequal.
    def look_back(cids, history, pick)
      history.reverse_each do |totals|
        break if cids.size == 1

        best = cids.map { |cid| totals[cid] }.public_send(pick)
        cids = cids.select { |cid| totals[cid] == best }
      end
      cids
    end
  end
end
