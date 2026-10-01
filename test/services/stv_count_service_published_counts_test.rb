require "test_helper"
require_relative "../support/blt_election"

# Checks the STV counters against counts published by other software, and
# checks invariants that every count must keep.
class StvCountServicePublishedCountsTest < ActiveSupport::TestCase
  def load_election(name)
    BltElection.parse(file_fixture("stv/#{name}.blt").read)
  end

  def names_by_id(election)
    election.options.to_h { |option| [option.id.to_s, option.name] }
  end

  # Every vote is held by a candidate or is non-transferable, at every stage.
  def assert_votes_conserved(result, ballot_count, message)
    result[:rounds].each do |round|
      held = round[:tallies].values.sum + round[:non_transferable]
      assert_in_delta ballot_count, held, 0.0001, "#{message}, round #{round[:round]}"
    end
  end

  # Official Scottish council counts: the ballots as a BLT preference profile,
  # and the report of every candidate's votes at every stage.
  SCOTTISH_COUNTS = {
    "linn07" => ["David Ritchie", "Sadie Docherty", "John McKenzie", "Margot Clark"],
    "dundee22_strathmartine" => ["John ALEXANDER", "Kevin KEENAN", "Stewart HUNTER", "Daniel COLEMAN"],
    "dundee22_west_end" => ["Fraser MACPHERSON", "Nadia EL-NAKLA", "Bill CAMPBELL", "Michael CRICHTON"],
    "dundee22_coldside" => ["Heather ANDERSON", "Mark FLYNN", "George MCIRVINE", "Helen WRIGHT"],
    "dundee22_maryfield" => ["Georgia CRUICKSHANK", "Ken LYNN", "Lynne SHORT"],
    "dundee22_north_east" => ["Jax FINNEGAN", "Steven ROME", "Willie SAWERS"],
    "dundee22_east_end" => ["Will DAWSON", "Dorothy MCHUGH", "Christina ROBERTS"],
    "dundee22_the_ferry" => ["Kevin CORDELL", "Craig DUNCAN", "DEREK SCOTT", "Pete SHEARS"]
  }.freeze

  SCOTTISH_COUNTS.each do |name, winners|
    test "scottish count matches every stage of the official #{name} report" do
      election = load_election(name)
      expected = JSON.parse(file_fixture("stv/#{name}_stages.json").read)
      names = names_by_id(election)

      result = StvCountService::ScottishCounter.new(election.ballots, election.seats, 'droop', election.options).count

      assert_equal expected["valid_votes"], election.ballots.size
      assert_equal expected["quota"].to_r, result[:quota]
      assert_equal expected["stages"].size, result[:rounds].size

      # Each round starts from the totals at the end of the matching stage and
      # elects the candidates the report marks elected at that stage. It then
      # does what the report's next stage does: transfers a surplus or
      # excludes a candidate.
      expected["stages"].each_with_index do |stage, i|
        round = result[:rounds][i]
        round_number = round[:round]

        stage["votes"].each do |candidate, votes|
          next if votes.nil?

          # Reports show an excluded candidate with no votes; tallies omit them.
          tally = round[:tallies][names.key(candidate)] || 0
          assert_equal votes, format("%.5f", tally), "#{candidate} in round #{round_number}"
        end
        assert_equal stage["non_transferable"], format("%.5f", round[:non_transferable]), "non-transferable in round #{round_number}"
        assert_equal stage["elected"].sort, round[:elected].map { |cid| names[cid.to_s] }.sort, "elected in round #{round_number}"

        next_stage = expected["stages"][i + 1] || {}
        assert_equal next_stage.fetch("excluded", []), round[:eliminated].map { |cid| names[cid.to_s] }, "excluded in round #{round_number}"
        surplus_ids = round[:transfers].keys - round[:eliminated].map(&:to_s)
        assert_equal [next_stage["surplus"]].compact, surplus_ids.map { |cid| names[cid] }, "surplus transferred in round #{round_number}"
      end

      assert_equal winners.sort, result[:elected].map { |e| e[:name] }.sort
      assert_votes_conserved(result, election.ballots.size, name)
    end
  end

  test "meek count matches the Hill–Wichmann–Woodall reference count of the ERS97 model election" do
    # The reference report (from OpenTally's validation data) gives totals to
    # two decimal places at the stages where surpluses were distributed. The
    # reference treats each exclusion and the following redistribution as
    # separate stages, so its stages 1, 2, 4, 6, 9 and 11 correspond to our
    # rounds 1, 2, 4, 5, 7 and 9.
    election = load_election("ers97")
    names = names_by_id(election)
    rows = CSV.parse(file_fixture("stv/ers97_meek_reference.csv").read)
    rounds_for_columns = { 1 => 1, 3 => 2, 5 => 4, 7 => 5, 9 => 7, 11 => 9 }

    result = StvCountService::MeekCounter.new(election.ballots, election.seats, 'droop', election.options).count

    rounds_for_columns.each do |column, round_number|
      round = result[:rounds][round_number - 1]

      rows.each do |row|
        label, value, state = row[0], row[column], row[column + 1]
        case label
        when "Stage:", "Comment:" then next
        when "Quota" then assert_equal value.to_f, round[:quota].round(2), "quota in round #{round_number}"
        when "Exhausted" then assert_in_delta value.to_f, round[:non_transferable], 0.02, "exhausted in round #{round_number}"
        else
          next if state == "EX"

          assert_equal value.to_f, round[:tallies][names.key(label)].round(2), "#{label} in round #{round_number}"
        end
      end
    end

    elected = rows.select { |row| row[12] == "EL" }.map(&:first)
    assert_equal elected.sort, result[:elected].map { |e| e[:name] }.sort
    assert_votes_conserved(result, election.ballots.size, "ERS97")
  end

  test "random elections conserve votes, fill every seat or report a tie, and keep within the seats" do
    rng = Random.new(20261001)

    200.times do |i|
      election = BltElection.random(rng)

      [StvCountService::ScottishCounter, StvCountService::MeekCounter].each do |counter|
        %w[droop hare].each do |quota_type|
          message = "election #{i}, #{counter.name.demodulize}, #{quota_type}:\n#{election.to_blt}"
          result = counter.new(election.ballots, election.seats, quota_type, election.options).count

          assert_votes_conserved(result, election.ballots.size, message)
          assert_operator result[:elected].size, :<=, election.seats, message
          if result[:tied].empty?
            assert_equal election.seats, result[:elected].size, message
          else
            assert_operator result[:elected].size + result[:tied].size, :>, election.seats, message
          end
        end
      end
    end
  end
end
