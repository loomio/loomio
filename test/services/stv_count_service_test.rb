require "test_helper"

class StvCountServiceTest < ActiveSupport::TestCase
  # Helper to create a minimal poll_option-like struct for the counters
  PollOptionStub = Struct.new(:id, :name)

  def build_options(names)
    names.each_with_index.map { |name, i| PollOptionStub.new(i + 1, name) }
  end

  # ── QuotaCalculator ──────────────────────────────────────────────

  test "droop quota: floor(votes/(seats+1)) + 1" do
    assert_equal 26, StvCountService::QuotaCalculator.calculate(100, 3, 'droop')
    assert_equal 51, StvCountService::QuotaCalculator.calculate(100, 1, 'droop')
    assert_equal 21, StvCountService::QuotaCalculator.calculate(100, 4, 'droop')
  end

  test "hare quota: votes / seats" do
    assert_in_delta 33.333, StvCountService::QuotaCalculator.calculate(100, 3, 'hare'), 0.01
    assert_equal 100.0, StvCountService::QuotaCalculator.calculate(100, 1, 'hare')
    assert_equal 25.0, StvCountService::QuotaCalculator.calculate(100, 4, 'hare')
  end

  # ── Scottish STV (WIGM) ──────────────────────────────────────────

  test "scottish droop: simple election where first prefs exceed quota" do
    # 3 seats, 100 voters, Droop quota = 26
    # A gets 40, B gets 35, C gets 15, D gets 10
    options = build_options(%w[A B C D])
    ballots = []
    40.times { ballots << [1, 2, 3, 4] }  # A > B > C > D
    35.times { ballots << [2, 3, 1, 4] }  # B > C > A > D
    15.times { ballots << [3, 4, 1, 2] }  # C > D > A > B
    10.times { ballots << [4, 3, 2, 1] }  # D > C > B > A

    counter = StvCountService::ScottishCounter.new(ballots, 3, 'droop', options)
    result = counter.count

    assert_equal 'scottish', result[:method]
    assert_equal 'droop', result[:quota_type]
    assert_equal 3, result[:seats]
    assert_equal 26, result[:quota]
    assert_equal 3, result[:elected].size

    elected_names = result[:elected].map { |e| e[:name] }
    # A and B should be elected first (both above quota)
    assert_includes elected_names, 'A'
    assert_includes elected_names, 'B'
    # C or D fills the third seat
    assert(elected_names.include?('C') || elected_names.include?('D'))
  end

  test "scottish droop: elimination when no one meets quota" do
    # 2 seats, 10 voters, Droop quota = 4
    options = build_options(%w[A B C])
    ballots = [
      [1, 2, 3],  # A > B > C
      [1, 2, 3],  # A > B > C
      [1, 2, 3],  # A > B > C
      [2, 1, 3],  # B > A > C
      [2, 1, 3],  # B > A > C
      [2, 1, 3],  # B > A > C
      [3, 1, 2],  # C > A > B
      [3, 2, 1],  # C > B > A
      [1, 3, 2],  # A > C > B
      [2, 3, 1],  # B > C > A
    ]

    counter = StvCountService::ScottishCounter.new(ballots, 2, 'droop', options)
    result = counter.count

    assert_equal 2, result[:elected].size
    elected_names = result[:elected].map { |e| e[:name] }
    # A has 4 first prefs, B has 4 first prefs, C has 2 - C should be eliminated
    assert_includes elected_names, 'A'
    assert_includes elected_names, 'B'
  end

  test "scottish hare: higher quota changes outcome" do
    # 2 seats, 10 voters, Hare quota = 5
    options = build_options(%w[A B C])
    ballots = [
      [1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3],  # 4 x A>B>C
      [2, 1, 3], [2, 1, 3], [2, 1, 3], [2, 1, 3],  # 4 x B>A>C
      [3, 1, 2], [3, 2, 1],                          # 2 x C>...
    ]

    counter = StvCountService::ScottishCounter.new(ballots, 2, 'hare', options)
    result = counter.count

    assert_equal 2, result[:elected].size
    assert_equal 5.0, result[:quota]
  end

  test "scottish: single seat (equivalent to IRV)" do
    options = build_options(%w[A B C])
    ballots = [
      [1, 2, 3], [1, 2, 3], [1, 3, 2],  # 3 x A first
      [2, 1, 3], [2, 1, 3],              # 2 x B first
      [3, 2, 1], [3, 2, 1], [3, 2, 1], [3, 2, 1],  # 4 x C first
    ]
    # Droop quota for 1 seat = floor(9/2)+1 = 5
    # Round 1: A=3, B=2, C=4 — no one meets 5, eliminate B
    # Round 2: A=3+2=5, C=4 — A meets quota
    counter = StvCountService::ScottishCounter.new(ballots, 1, 'droop', options)
    result = counter.count

    assert_equal 1, result[:elected].size
    assert_equal 'A', result[:elected].first[:name]
  end

  test "scottish: remaining candidates equal remaining seats" do
    options = build_options(%w[A B C])
    ballots = [
      [1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3],  # 5 x A
      [2, 3, 1], [2, 3, 1],  # 2 x B
      [3, 2, 1],             # 1 x C
    ]
    # 3 seats, 8 voters, Droop quota = 3
    # All 3 candidates should be elected eventually
    counter = StvCountService::ScottishCounter.new(ballots, 3, 'droop', options)
    result = counter.count

    assert_equal 3, result[:elected].size
    elected_names = result[:elected].map { |e| e[:name] }
    assert_includes elected_names, 'A'
    assert_includes elected_names, 'B'
    assert_includes elected_names, 'C'
  end

  test "scottish: exhausted ballots" do
    # Voters only rank one candidate
    options = build_options(%w[A B C])
    ballots = [
      [1], [1], [1], [1], [1],  # 5 x just A
      [2], [2], [2],            # 3 x just B
      [3],                       # 1 x just C
    ]
    # 2 seats, 9 voters, Droop quota = 4
    # A elected with surplus 1 — but A's ballots are exhausted, surplus lost
    # B=3, C=1 — eliminate C, C's ballot exhausted
    # B=3 — only remaining candidate, elected
    counter = StvCountService::ScottishCounter.new(ballots, 2, 'droop', options)
    result = counter.count

    assert_equal 2, result[:elected].size
    assert_equal 'A', result[:elected][0][:name]
    assert_equal 'B', result[:elected][1][:name]
  end

  test "scottish: round data includes transfers" do
    options = build_options(%w[A B C])
    ballots = [
      [1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3],
      [1, 3, 2],
      [2, 1, 3],
      [3, 2, 1],
    ]
    # 2 seats, 8 voters, Droop quota = 3
    # A has 6 first prefs, surplus = 3
    counter = StvCountService::ScottishCounter.new(ballots, 2, 'droop', options)
    result = counter.count

    assert result[:rounds].any?
    first_round = result[:rounds].first
    assert first_round[:elected].include?(1), "A (id=1) should be elected in round 1"
    assert first_round[:transfers].any?, "Should have transfer data"
  end

  # ── Meek STV ──────────────────────────────────────────────────────

  test "meek droop: simple election" do
    options = build_options(%w[A B C D])
    ballots = []
    40.times { ballots << [1, 2, 3, 4] }
    35.times { ballots << [2, 3, 1, 4] }
    15.times { ballots << [3, 4, 1, 2] }
    10.times { ballots << [4, 3, 2, 1] }

    counter = StvCountService::MeekCounter.new(ballots, 3, 'droop', options)
    result = counter.count

    assert_equal 'meek', result[:method]
    assert_equal 'droop', result[:quota_type]
    assert_equal 3, result[:seats]
    assert_equal 3, result[:elected].size

    elected_names = result[:elected].map { |e| e[:name] }
    assert_includes elected_names, 'A'
    assert_includes elected_names, 'B'
  end

  test "meek hare: higher quota" do
    options = build_options(%w[A B C])
    ballots = [
      [1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3],
      [2, 1, 3], [2, 1, 3], [2, 1, 3], [2, 1, 3],
      [3, 1, 2], [3, 2, 1],
    ]

    counter = StvCountService::MeekCounter.new(ballots, 2, 'hare', options)
    result = counter.count

    assert_equal 2, result[:elected].size
  end

  test "meek: single seat IRV equivalent" do
    options = build_options(%w[A B C])
    ballots = [
      [1, 2, 3], [1, 2, 3], [1, 3, 2],
      [2, 1, 3], [2, 1, 3],
      [3, 2, 1], [3, 2, 1], [3, 2, 1], [3, 2, 1],
    ]

    counter = StvCountService::MeekCounter.new(ballots, 1, 'droop', options)
    result = counter.count

    assert_equal 1, result[:elected].size
    # C has most first prefs (4), but not majority. B eliminated.
    # B's voters go to A -> A gets 5 = majority
    assert_equal 'A', result[:elected].first[:name]
  end

  test "meek: keep values decrease for elected candidates" do
    options = build_options(%w[A B C])
    ballots = []
    6.times { ballots << [1, 2, 3] }
    3.times { ballots << [2, 3, 1] }
    1.times { ballots << [3, 2, 1] }

    counter = StvCountService::MeekCounter.new(ballots, 2, 'droop', options)
    result = counter.count

    assert_equal 2, result[:elected].size
    # Check that rounds contain keep_values
    assert result[:rounds].first[:keep_values].present?
  end

  test "meek: exhausted ballots handled" do
    options = build_options(%w[A B C])
    ballots = [
      [1], [1], [1], [1], [1],
      [2], [2], [2],
      [3],
    ]

    counter = StvCountService::MeekCounter.new(ballots, 2, 'droop', options)
    result = counter.count

    assert_equal 2, result[:elected].size
    elected_names = result[:elected].map { |e| e[:name] }
    assert_includes elected_names, 'A'
    assert_includes elected_names, 'B'
  end

  # ── Edge Cases ────────────────────────────────────────────────────

  test "empty ballots return empty result" do
    options = build_options(%w[A B C])

    scottish = StvCountService::ScottishCounter.new([], 2, 'droop', options)
    result = scottish.count
    assert_equal 0, result[:elected].size

    meek = StvCountService::MeekCounter.new([], 2, 'droop', options)
    result = meek.count
    assert_equal 0, result[:elected].size
  end

  test "more seats than candidates: all candidates elected" do
    options = build_options(%w[A B])
    ballots = [[1, 2], [2, 1], [1, 2]]

    counter = StvCountService::ScottishCounter.new(ballots, 5, 'droop', options)
    result = counter.count
    assert_equal 2, result[:elected].size

    counter = StvCountService::MeekCounter.new(ballots, 5, 'droop', options)
    result = counter.count
    assert_equal 2, result[:elected].size
  end

  test "unanimous first preference" do
    options = build_options(%w[A B C])
    ballots = []
    10.times { ballots << [1, 2, 3] }

    counter = StvCountService::ScottishCounter.new(ballots, 1, 'droop', options)
    result = counter.count
    assert_equal 1, result[:elected].size
    assert_equal 'A', result[:elected].first[:name]
  end

  # ── Integration with StvCountService.count ────────────────────────

  test "StvCountService.count dispatches to scottish counter" do
    group = groups(:test_group)
    user = users(:normal_user)
    group.add_admin!(user)

    poll = Poll.new(
      title: "Board Election",
      poll_type: 'stv',
      author: user,
      group: group,
      closing_at: 1.day.from_now,
      stv_seats: 2,
      stv_method: 'scottish',
      stv_quota: 'droop',
      specified_voters_only: true
    )
    poll.poll_option_names = %w[Alice Bob Carol]
    poll.save!
    poll.create_missing_created_event!

    alice = poll.poll_options.find_by(name: 'Alice')
    bob = poll.poll_options.find_by(name: 'Bob')
    carol = poll.poll_options.find_by(name: 'Carol')

    # Cast votes: 3 voters prefer Alice > Bob > Carol
    # score = rank placement (1 = first choice)
    3.times do
      voter = User.create!(name: "Voter #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@test.com")
      group.add_member!(voter)
      stance = poll.stances.build(participant: voter, poll: poll)
      stance.stance_choices.build(poll_option: alice, score: 1)
      stance.stance_choices.build(poll_option: bob, score: 2)
      stance.stance_choices.build(poll_option: carol, score: 3)
      stance.cast_at = Time.current
      stance.save!
    end

    # 2 voters prefer Bob > Carol > Alice
    2.times do
      voter = User.create!(name: "Voter #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@test.com")
      group.add_member!(voter)
      stance = poll.stances.build(participant: voter, poll: poll)
      stance.stance_choices.build(poll_option: bob, score: 1)
      stance.stance_choices.build(poll_option: carol, score: 2)
      stance.stance_choices.build(poll_option: alice, score: 3)
      stance.cast_at = Time.current
      stance.save!
    end

    poll.update_counts!

    result = StvCountService.count(poll)

    assert_equal 'scottish', result[:method]
    assert_equal 2, result[:elected].size
    elected_names = result[:elected].map { |e| e[:name] }
    assert_includes elected_names, 'Alice'
    assert_includes elected_names, 'Bob'
  end

  test "StvCountService.count dispatches to meek counter" do
    group = groups(:test_group)
    user = users(:normal_user)
    group.add_admin!(user)

    poll = Poll.new(
      title: "Board Election Meek",
      poll_type: 'stv',
      author: user,
      group: group,
      closing_at: 1.day.from_now,
      stv_seats: 2,
      stv_method: 'meek',
      stv_quota: 'hare',
      specified_voters_only: true
    )
    poll.poll_option_names = %w[Alice Bob Carol]
    poll.save!
    poll.create_missing_created_event!

    alice = poll.poll_options.find_by(name: 'Alice')
    bob = poll.poll_options.find_by(name: 'Bob')
    carol = poll.poll_options.find_by(name: 'Carol')

    # score = rank placement (1 = first choice)
    3.times do
      voter = User.create!(name: "Voter #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@test.com")
      group.add_member!(voter)
      stance = poll.stances.build(participant: voter, poll: poll)
      stance.stance_choices.build(poll_option: alice, score: 1)
      stance.stance_choices.build(poll_option: bob, score: 2)
      stance.stance_choices.build(poll_option: carol, score: 3)
      stance.cast_at = Time.current
      stance.save!
    end

    2.times do
      voter = User.create!(name: "Voter #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@test.com")
      group.add_member!(voter)
      stance = poll.stances.build(participant: voter, poll: poll)
      stance.stance_choices.build(poll_option: bob, score: 1)
      stance.stance_choices.build(poll_option: carol, score: 2)
      stance.stance_choices.build(poll_option: alice, score: 3)
      stance.cast_at = Time.current
      stance.save!
    end

    poll.update_counts!

    result = StvCountService.count(poll)

    assert_equal 'meek', result[:method]
    assert_equal 2, result[:elected].size
    elected_names = result[:elected].map { |e| e[:name] }
    assert_includes elected_names, 'Alice'
    assert_includes elected_names, 'Bob'
  end
end
