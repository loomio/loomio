require 'test_helper'
require 'csv'

class WeightedPollResultsTest < ActiveSupport::TestCase
  setup do
    @group = groups(:group)
    @admin = users(:admin)
    @voter = users(:user)
  end

  test 'proposal results show votes and weighted votes across email, chatbots, and exports' do
    poll = create_weighted_poll('proposal', %w[agree disagree], 1)

    rendered_results(poll).each_value do |output|
      assert_includes output, 'Weighted votes'
      assert_not_includes output, 'Weighted points'
      assert_includes output, '2.33'
    end

    csv = CSV.parse(PollExporter.new(poll).to_csv)
    option_headers = csv[csv.index(['poll_options']) + 1]
    vote_headers = csv[csv.index(['votes']) + 1]
    assert_includes option_headers, 'unweighted_score'
    assert_includes vote_headers, 'vote_weight'
    assert_includes csv.flatten, '2.33'
  end

  test 'score poll results show points and weighted points across email, chatbots, and exports' do
    poll = create_weighted_poll('score', %w[Alpha Beta], 4)
    pending = poll.results.find { |row| row[:id] == -1 }
    assert_operator pending[:voter_percent], :>, 0
    assert_equal 0, pending[:score], 'uncast vote weight is not a total of awarded points'
    assert_nil pending[:score_percent]

    rendered_results(poll).each_value do |output|
      assert_includes output, 'Points'
      assert_includes output, 'Weighted points'
      assert_not_includes output, 'Weighted votes'
      assert_includes output, '9.32'
    end

    csv = CSV.parse(PollExporter.new(poll).to_csv)
    option_headers = csv[csv.index(['poll_options']) + 1]
    assert_includes option_headers, 'unweighted_score'
    assert_includes csv.flatten, '4'
    assert_includes csv.flatten, '9.32'
  end

  test 'one point poll results show voters and weighted votes across email, chatbots, and exports' do
    poll = create_weighted_poll('poll', %w[Alpha Beta], 1)

    rendered_results(poll).each_value do |output|
      assert_includes output, 'Voters'
      assert_includes output, 'Weighted votes'
      assert_not_includes output, 'Weighted points'
    end

    csv = CSV.parse(PollExporter.new(poll).to_csv)
    option_headers = csv[csv.index(['poll_options']) + 1]
    assert_includes option_headers, 'unweighted_score'
  end

  test 'unweighted CSV exports effective weight one with a stable result schema' do
    poll = create_weighted_poll('poll', %w[Alpha Beta], 1)
    poll.update_columns(opened_at: nil)
    poll.update!(weighted_voting: false)
    poll.update_counts!

    csv = CSV.parse(PollExporter.new(poll.reload).to_csv)
    option_headers = csv[csv.index(['poll_options']) + 1]
    vote_headers = csv[csv.index(['votes']) + 1]
    assert_includes option_headers, 'unweighted_score'
    assert_includes vote_headers, 'vote_weight'
    option_row = csv[(csv.index(['poll_options']) + 2)...csv.index(['votes'])].find { |row| row[2] == 'Alpha' }
    assert_equal '1', option_row[option_headers.index('score')]
    assert_equal '1', option_row[option_headers.index('unweighted_score')]
    voter_row = csv[(csv.index(['votes']) + 2)..].find { |row| row[2] == @voter.id.to_s }
    assert_equal '1', voter_row[vote_headers.index('vote_weight')]
    assert_equal '1', VoteWeight.format(poll.stances.latest.find_by!(participant: @voter).weight)
  end

  test 'unweighted results print whole scores without a decimal point' do
    poll = PollService.create(params: {
      title: 'Plain score', poll_type: 'score', group_id: @group.id,
      poll_option_names: %w[Alpha Beta], closing_at: 1.day.from_now, notify_on_open: false
    }, actor: @admin)
    option = poll.poll_options.first
    poll.stances.latest.find_by!(participant: @voter).update!(
      cast_at: Time.current, stance_choices_attributes: [{poll_option_id: option.id, score: 4}]
    )
    poll.update_counts!

    result = poll.reload.results.find { |row| row[:id] == option.id }
    assert_equal 4, result[:score]
    email = rendered_results(poll).fetch(:email)
    assert_includes email, '>4<'
    assert_not_includes email, '4.0'
  end

  test 'weighted quorum and support requirements use the same labels across email and chatbots' do
    poll = create_weighted_poll('proposal', %w[agree disagree], 1)
    poll.update!(quorum_pct: 50)
    poll.poll_options.first.update!(test_operator: 'gte', test_against: 'voter_percent', test_percent: 60)

    components = [
      Views::NotificationMailer::Poll::Rules.new(poll: poll),
      Views::Chatbot::Matrix::Rules.new(poll: poll),
      Views::Chatbot::Markdown::Poll.new(topic_item: poll.created_topic_item, poll: poll, recipient: @voter)
    ]
    components.each do |component|
      output = ApplicationController.renderer.render(component, layout: false)
      assert_includes output, '50% of eligible vote weight must participate'
      assert_includes output.downcase, 'agree needs at least 60% of eligible vote weight'
    end

    components = [
      Views::NotificationMailer::Poll::Uncast.new(poll: poll),
      Views::Chatbot::Matrix::Uncast.new(poll: poll)
    ]
    components.each do |component|
      output = ApplicationController.renderer.render(component, layout: false)
      assert_includes output, "#{poll.participation_pct}% of vote weight)"
    end
  end

  private

  def create_weighted_poll(poll_type, option_names, score)
    poll = PollService.create(params: {
      title: 'Weighted result', poll_type: poll_type, group_id: @group.id,
      poll_option_names: option_names, weighted_voting: true,
      closing_at: 1.day.from_now, notify_on_open: false
    }, actor: @admin)
    option = poll.poll_options.first
    poll.stances.latest.find_by!(participant: @voter).update!(
      weight: '2.33', cast_at: Time.current,
      stance_choices_attributes: [{poll_option_id: option.id, score: score}]
    )
    poll.update_counts!
    poll.reload
  end

  def rendered_results(poll)
    topic_item = poll.created_topic_item
    components = {
      email: Views::NotificationMailer::Poll::Results::Simple.new(poll: poll, recipient: @voter),
      matrix: Views::Chatbot::Matrix::Simple.new(poll: poll, recipient: @voter),
      markdown: Views::Chatbot::Markdown::Poll.new(topic_item: topic_item, poll: poll, recipient: @voter),
      slack: Views::Chatbot::Slack::Poll.new(topic_item: topic_item, poll: poll, recipient: @voter),
      print: Views::Polls::Export.new(poll: poll, exporter: PollExporter.new(poll), recipient: @voter)
    }
    components.transform_values { |component| ApplicationController.renderer.render(component, layout: false) }
              .merge(thread_markdown: PollMarkdownResultsService.render(poll: poll, user: @voter))
  end
end
