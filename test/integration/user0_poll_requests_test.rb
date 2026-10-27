require 'test_helper'

class User0PollRequestsTest < ActionDispatch::IntegrationTest
  setup do
    @actor = users(:admin)
    @actor.update_columns(api_key: SecureRandom.hex(32))
    @headers = { 'Authorization' => "Bearer #{@actor.api_key}" }
    @attributes = {
      group_id: groups(:group).id,
      title: "Ant's test poll",
      poll_type: 'poll',
      options: Array.new(60) { |index| "Option #{index + 1}" }
    }
  end

  test 'flat JSON creates a group draft with every option' do
    assert_poll_created(@attributes)
  end

  test 'nested JSON creates a group draft with every option' do
    assert_poll_created({ poll: @attributes })
  end

  test 'form arrays create a group draft with every option' do
    assert_poll_created(@attributes, as: nil)
  end

  %i[flat nested].each do |format|
    test "#{format} JSON creates detailed proposal options" do
      attributes = detailed_proposal_attributes
      payload = format == :nested ? { poll: attributes } : attributes

      post '/api/user0/polls', params: payload, headers: @headers, as: :json

      assert_response :success
      poll = Poll.find(response.parsed_body.fetch('polls').first.fetch('id'))
      assert_equal @attributes[:group_id], poll.group_id
      assert_equal 'optional', poll.stance_reason_required
      assert_equal attributes[:poll_options_attributes].map(&:stringify_keys),
                   poll.poll_options.map { |option| option.attributes.slice(*attributes[:poll_options_attributes].first.keys.map(&:to_s)) }
      serialized_options = response.parsed_body.fetch('poll_options').sort_by { |option| option.fetch('priority') }
      attributes[:poll_options_attributes].zip(serialized_options).each do |expected, actual|
        assert_equal expected.stringify_keys, actual.slice(*expected.keys.map(&:to_s))
      end
    end
  end

  test 'JSON creates a regular poll with detailed meanings and a shared reason prompt' do
    attributes = @attributes.except(:options).merge(
      reason_prompt: 'Why do you prefer this venue?',
      stance_reason_required: 'required',
      poll_options_attributes: [
        { name: 'Town hall', meaning: 'Central, accessible venue', priority: 0 },
        { name: 'Library', meaning: 'Smaller room with no hire fee', priority: 1 }
      ]
    )

    post '/api/user0/polls', params: attributes, headers: @headers, as: :json

    assert_response :success
    poll = Poll.find(response.parsed_body.fetch('polls').first.fetch('id'))
    assert_equal attributes[:reason_prompt], poll.reason_prompt
    assert_equal 'required', poll.stance_reason_required
    assert_equal ['Central, accessible venue', 'Smaller room with no hire fee'], poll.poll_options.pluck(:meaning)
  end

  test 'JSON edits detailed options by id while retaining omitted options' do
    poll = PollService.create(params: detailed_proposal_attributes, actor: @actor)
    support, oppose = poll.poll_options.to_a

    patch "/api/user0/polls/#{poll.id}", params: { poll_options_attributes: [
      { id: support.id, meaning: 'Updated explanation', prompt: 'What would improve this proposal?' },
      { name: 'Abstain', meaning: 'I leave the decision to others', icon: 'abstain', priority: 2 }
    ] }, headers: @headers, as: :json

    assert_response :success
    assert_equal 'Updated explanation', support.reload.meaning
    assert_equal 'What would improve this proposal?', support.prompt
    assert_equal ['Support', 'Oppose', 'Abstain'], poll.reload.poll_option_names
    assert_equal 'I would prefer another approach', oppose.reload.meaning

    patch "/api/user0/polls/#{poll.id}", params: {
      poll_options_attributes: [{ id: oppose.id, _destroy: true }]
    }, headers: @headers, as: :json

    assert_response :success
    assert_equal ['Support', 'Abstain'], poll.reload.poll_option_names
  end

  test 'flat JSON updates every option without losing virtual attributes' do
    poll = PollService.create(params: @attributes, actor: @actor)
    options = ['foo', 'bar', "Ant's choice"]

    patch "/api/user0/polls/#{poll.id}", params: { options: options }, headers: @headers, as: :json

    assert_response :success
    assert_equal options, poll.reload.poll_option_names
  end

  test 'JSON group creation enforces the fixture access matrix' do
    %i[member_normal alien_quiet guest_normal non_guest_loud former_member_loud inactive_member_loud server_admin].each do |role|
      actor = users(role)
      actor.update_columns(api_key: SecureRandom.hex(32))
      headers = { 'Authorization' => "Bearer #{actor.api_key}" }

      if role == :member_normal
        post '/api/user0/polls', params: @attributes, headers: headers, as: :json
        assert_response :success
        assert_equal @attributes[:group_id], response.parsed_body.fetch('polls').first.fetch('group_id')
      else
        assert_no_difference ['Poll.count', 'Topic.count', 'PollOption.count'] do
          post '/api/user0/polls', params: @attributes, headers: headers, as: :json
          assert_response :forbidden
        end
      end
    end
  end

  test 'JSON cannot assign protected poll attributes' do
    assert_no_difference ['Poll.count', 'Topic.count', 'PollOption.count'] do
      post '/api/user0/polls', params: @attributes.merge(author_id: users(:alien).id), headers: @headers, as: :json
      assert_response :bad_request
    end
  end

  test 'JSON creation requires a valid API key' do
    [nil, 'Bearer invalid'].each do |authorization|
      assert_no_difference ['Poll.count', 'Topic.count', 'PollOption.count'] do
        post '/api/user0/polls', params: @attributes, headers: { 'Authorization' => authorization }, as: :json
        assert_response :forbidden
      end
    end
  end

  test 'shared JSON handling preserves comment discussion context' do
    discussion = discussions(:discussion)

    post '/api/user0/comments', params: {
      discussion_id: discussion.id,
      body: "Ant's comment",
      body_format: 'md'
    }, headers: @headers, as: :json

    assert_response :success
    comment = Comment.find(response.parsed_body.fetch('comments').first.fetch('id'))
    assert_equal discussion, comment.parent
    assert_equal "Ant's comment", comment.body
  end

  test 'the legacy b2 path keeps the old poll field and reminder names' do
    post '/api/b2/polls', params: @attributes.merge(notify_on_closing_soon: 'undecided_voters', closing_at: 3.days.from_now), headers: @headers, as: :json
    assert_response :success
    legacy = response.parsed_body.fetch('polls').first
    poll = Poll.find(legacy.fetch('id'))
    assert_equal 'voters_uncast', poll.notify_on_closing_soon
    assert_equal 'undecided_voters', legacy.fetch('notify_on_closing_soon')
    assert_equal poll.vote_count_eligible, legacy.fetch('voters_count')
    assert_equal poll.vote_count_uncast, legacy.fetch('undecided_voters_count')
    %w[voters_count decided_voters_count undecided_voters_count cast_stances_pct].each { |field| assert legacy.key?(field), field }
    %w[vote_count_eligible vote_count_cast vote_count_uncast participation_pct quorum_shortfall].each { |field| assert_not legacy.key?(field), field }

    get "/api/user0/polls/#{poll.id}", headers: @headers
    current = response.parsed_body.fetch('polls').first
    assert_equal 'voters_uncast', current.fetch('notify_on_closing_soon')
    assert_equal poll.vote_count_eligible, current.fetch('vote_count_eligible')
    assert_not current.key?('voters_count')
  end

  test 'the legacy b2 path does not reveal participation hidden on open anonymous polls' do
    poll = PollService.create(params: {
      title: 'Legacy anonymous', poll_type: 'proposal', group_id: groups(:group).id, anonymous: true,
      hide_results: 'until_closed', stance_reason_required: 'disabled', notify_on_closing_soon: 'voters_uncast',
      poll_option_names: %w[agree disagree], closing_at: 3.days.from_now
    }, actor: @actor)

    get "/api/b2/polls/#{poll.id}", headers: @headers
    assert_response :success
    legacy = response.parsed_body.fetch('polls').first
    %w[decided_voters_count undecided_voters_count cast_stances_pct quorum_votes_required stance_counts].each do |field|
      assert_not legacy.key?(field), field
    end
  end

  test 'the legacy b2 path accepts and returns the old scoring setting names' do
    post '/api/b2/polls', params: @attributes.merge(poll_type: 'score', options: %w[Red Blue], min_score: 0, max_score: 5, closing_at: 3.days.from_now),
      headers: @headers, as: :json
    assert_response :success
    legacy = response.parsed_body.fetch('polls').first
    poll = Poll.find(legacy.fetch('id'))
    assert_equal [0, 5], [poll.score_min, poll.score_max]
    assert_equal [0, 5], legacy.values_at('min_score', 'max_score')
    %w[score_min score_max choice_count_min choice_count_max points_per_voter].each { |field| assert_not legacy.key?(field), field }
    result = legacy.fetch('results').first
    assert result.key?('voter_count')
    assert_not result.key?('vote_count')
  end

  private

  def detailed_proposal_attributes
    @attributes.except(:options).merge(
      poll_type: 'proposal',
      stance_reason_required: 'optional',
      poll_options_attributes: [
        { name: 'Support', meaning: 'I support adopting this proposal', prompt: 'What do you support about it?',
          icon: 'agree', priority: 0, test_operator: 'gte', test_percent: 50, test_against: 'score_percent' },
        { name: 'Oppose', meaning: 'I would prefer another approach', prompt: 'What would you change?',
          icon: 'disagree', priority: 1, test_operator: 'lte', test_percent: 25, test_against: 'voter_percent' }
      ]
    )
  end

  def assert_poll_created(payload, as: :json)
    assert_difference 'Poll.count', 1 do
      post '/api/user0/polls', params: payload, headers: @headers, as: as
      assert_response :success
    end

    poll = Poll.find(response.parsed_body.fetch('polls').first.fetch('id'))
    assert_equal @attributes[:title], poll.title
    assert_equal @attributes[:group_id], poll.group_id
    assert_equal @attributes[:options], poll.poll_option_names
    options = response.parsed_body.fetch('poll_options').select { |option| option.fetch('poll_id') == poll.id }
    assert_equal @attributes[:options], options.sort_by { |option| option.fetch('priority') }.pluck('name')
    assert poll.wip?
    assert_not poll.active?
    assert_nil poll.opened_at
    assert @actor.can?(:show, poll)

    get '/api/user0/polls', params: { group_id: poll.group_id, status: 'all' }, headers: @headers
    assert_response :success
    assert_includes response.parsed_body.fetch('polls').pluck('id'), poll.id
  end
end
