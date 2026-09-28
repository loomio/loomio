require 'test_helper'

# Guards the cost of serializing poll results.
#
# Unweighted polls must cost no more than they did before vote weights existed.
# Master at 6001ebe707 measured 4/7, 29/32, and 38/47 for these scenarios, with
# one poll reload per option. Attaching the poll to its options removed those
# reloads, so the counts below no longer grow with options or polls. Do not
# raise them to absorb new work; find the extra query instead.
#
# Weighted polls may add a constant number of queries, but their cost must not
# grow with the number of options, voters, or polls faster than unweighted
# polls do.
class Api::V1::PollResultsQueryCountTest < ActionController::TestCase
  tests Api::V1::PollsController

  SMALL = {options_count: 2, voters_count: 2}
  LARGE = {options_count: 5, voters_count: 8}
  WEIGHTED_OVERHEAD_MAX = 2

  setup do
    @admin = users(:admin)
    @group = groups(:group)
    sign_in @admin
  end

  test "unweighted poll results do not grow with options or voters" do
    small = build_voted_poll(**SMALL)
    large = build_voted_poll(**LARGE)

    assert_equal 2, calculate_results_queries(small)
    assert_equal 2, calculate_results_queries(large)
    assert_equal 27, show_queries(small)
    assert_equal 27, show_queries(large)
  end

  test "unweighted poll index does not grow with the number of polls" do
    assert_equal 35, index_queries(polls_count: 1)
    assert_equal 35, index_queries(polls_count: 4)
  end

  test "weighted poll results cost a bounded constant more than unweighted results" do
    @group.update!(vote_weights_allowed: true)
    unweighted_small = build_voted_poll(**SMALL)
    unweighted_large = build_voted_poll(**LARGE)
    weighted_small = build_voted_poll(**SMALL, weighted: true)
    weighted_large = build_voted_poll(**LARGE, weighted: true)

    [[:calculate_results_queries, 'calculate_results'], [:show_queries, 'show']].each do |measure, label|
      unweighted = [send(measure, unweighted_small), send(measure, unweighted_large)]
      weighted = [send(measure, weighted_small), send(measure, weighted_large)]

      assert_equal unweighted[1] - unweighted[0], weighted[1] - weighted[0],
        "weighted #{label} queries grow with options and voters: #{weighted.inspect} vs unweighted #{unweighted.inspect}"
      assert_operator weighted[0] - unweighted[0], :<=, WEIGHTED_OVERHEAD_MAX,
        "weighted #{label} adds too many queries: #{weighted[0]} vs unweighted #{unweighted[0]}"
    end
  end

  test "weighted poll index cost does not grow with the number of polls" do
    @group.update!(vote_weights_allowed: true)
    unweighted = [index_queries(polls_count: 1), index_queries(polls_count: 4)]
    weighted = [index_queries(polls_count: 1, weighted: true), index_queries(polls_count: 4, weighted: true)]

    assert_equal unweighted[1] - unweighted[0], weighted[1] - weighted[0],
      "weighted index queries grow faster per poll: #{weighted.inspect} vs unweighted #{unweighted.inspect}"
    assert_operator weighted[0] - unweighted[0], :<=, WEIGHTED_OVERHEAD_MAX
  end

  private

  def calculate_results_queries(poll)
    poll = Poll.find(poll.id)
    count_queries { PollService.calculate_results(poll, poll.poll_options.to_a) }
  end

  def show_queries(poll)
    count_queries { get :show, params: {id: poll.key} }
  end

  # Replace the group's visible polls so the index lists exactly polls_count.
  def index_queries(polls_count:, weighted: false)
    Poll.where(topic_id: @group.topics.select(:id)).update_all(discarded_at: Time.current)
    polls_count.times { build_voted_poll(options_count: 3, voters_count: 3, weighted:) }
    count_queries { get :index, params: {group_key: @group.key} }
  end

  def build_voted_poll(options_count:, voters_count:, weighted: false)
    params = {
      title: 'Query count', poll_type: 'poll', group_id: @group.id,
      poll_option_names: Array.new(options_count) { |i| "Option #{i}" },
      closing_at: 3.days.from_now
    }
    params[:vote_weights_enabled] = true if weighted
    poll = PollService.create(params:, actor: @admin)
    assert poll.persisted?, poll.errors.full_messages.to_sentence

    voters = Array.new(voters_count) do |i|
      user = User.create!(name: "Voter #{i}", email: "query-count-#{poll.id}-#{i}@example.com", email_verified: true)
      @group.add_member!(user).tap { |membership| membership.update_columns(weight: 1 + i) if weighted }
      user
    end
    PollService.invite(poll:, actor: @admin, params: {recipient_user_ids: voters.map(&:id), notify_recipients: false})

    options = poll.poll_options.to_a
    voters.each_with_index do |voter, i|
      poll.stances.latest.find_by!(participant: voter).update!(
        cast_at: Time.current,
        stance_choices_attributes: [{poll_option_id: options[i % options.length].id, score: 1}]
      )
    end
    poll.update_counts!
    poll.reload
  end

  def count_queries(&block)
    queries = 0
    counter = ->(*, payload) { queries += 1 unless payload[:name] == 'SCHEMA' || payload[:cached] }
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &block)
    queries
  end
end
