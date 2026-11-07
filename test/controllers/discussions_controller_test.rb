require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  test "member receives the app shell with session and thread records without SSR" do
    sign_in @user
    get :show, params: { key: @discussion.key }
    assert_response 200
    assert_equal @discussion, assigns(:discussion)
    assert_select '#loading-placeholder'
    assert_select '.context-panel', count: 0
    data = initial_data
    assert_equal @user.id, data.dig('boot', 'current_user_id')
    assert_equal @user.email, data['boot']['users'].find { |user| user['id'] == @user.id }['email']
    assert_includes thread_records['discussions'].pluck('id'), @discussion.id
    assert_includes response.headers['Cache-Control'], 'no-store'
    assert_select "link[rel='canonical'][href=?]", discussion_url(@discussion)
  end

  test "public bootstrap is signed out and JSON cannot escape its script element" do
    discussion = discussions(:public_discussion)
    text = '</script><script id="injected">alert(1)</script>&'
    discussion.update_column(:description, text)
    get :show, params: { key: discussion.key }

    assert_response :success
    assert_nil initial_data.dig('boot', 'current_user_id')
    assert_equal text, thread_records['discussions'].find { |row| row['id'] == discussion.id }['description']
    assert_select 'script#injected', count: 0
    assert_includes response.headers['Cache-Control'], 'no-store'
  end

  test 'browser and bot metadata contain a short excerpt without the context heading' do
    discussion = discussions(:public_discussion)
    description = '<h2>Context</h2><p>Clarify responsibilities &amp; share "progress".</p>' \
      '<p>' + ('More useful information. ' * 30) + '</p>'
    discussion.update_columns(description: description, description_format: 'html')

    ['Mozilla/5.0', 'Googlebot'].each do |agent|
      @request.user_agent = agent
      get :show, params: {key: discussion.key}
      assert_response :success
      assert_select 'meta[name="description"][property="og:description"]', count: 1 do |tags|
        excerpt = tags.first['content']
        assert excerpt.start_with?('Clarify responsibilities & share "progress".')
        assert_operator excerpt.length, :<=, 200
        refute_includes excerpt, 'Context'
        refute_includes excerpt, '<br>'
      end
    end

    assert_equal description, discussion.reload.description
  end

  test "signed-in public thread boot includes its group outside the viewer's directory" do
    sign_in users(:alien)
    discussion = discussions(:public_discussion)

    get :show, params: {key: discussion.key}

    assert_response :success
    assert_includes initial_data.fetch('boot').fetch('groups').pluck('id'), discussion.group_id
    refute thread_records.key?('groups')
    assert_equal 'group', initial_data.fetch('requests').first.fetch('params').fetch('exclude_types')
  end

  test "thread bootstrap respects group and direct topic access and reader scope" do
    %i[discussion_topic direct_topic].each do |name|
      topic = topics(name)
      allowed = name == :discussion_topic ? %i[member_normal admin guest_normal guest_admin_normal] : %i[guest_normal guest_admin_normal]
      allowed.each do |role|
        user = users(role)
        sign_in user
        get :show, params: { key: topic.topicable.key }
        assert_response :success
        assert_equal user.id, initial_data.dig('boot', 'current_user_id')
        row = thread_records['topics'].find { |record| record['id'] == topic.id }
        assert_equal TopicReader.for(user: user, topic: topic).admin, row['reader_admin']
        sign_out
      end
      %i[alien former_member_loud former_guest_loud non_guest_loud server_admin].each do |role|
        sign_in users(role)
        get :show, params: { key: topic.topicable.key }
        assert_response :forbidden
        assert_select '#initial-data', count: 0
        sign_out
      end
      get :show, params: { key: topic.topicable.key }
      assert_response :forbidden
      assert_select '#initial-data', count: 0
    end
  end

  test "crawler and export responses retain static content without personal bootstrap data" do
    discussion = discussions(:public_discussion)
    get :show, params: { key: discussion.key, export: 1 }
    assert_select '.context-panel__heading', text: discussion.title
    assert_select '#initial-data', count: 0

    @request.user_agent = 'Googlebot'
    get :show, params: { key: discussion.key }
    assert_select '.context-panel__heading', text: discussion.title
    assert_select '#initial-data', count: 0
  end

  test "embedded poll records respect hidden results and anonymous ballots before and after closing" do
    @discussion.topic.update!(polls_one_at_a_time: false)
    [false, true].each do |anonymous|
      modes = anonymous ? ['until_closed'] : %w[off until_vote until_closed]
      modes.each do |mode|
        poll = PollService.create(params: {
          topic_id: @discussion.topic_id, title: "Results #{anonymous} #{mode}", poll_type: 'proposal',
          anonymous: anonymous, hide_results: mode, poll_option_names: %w[Agree Disagree], closing_at: 3.days.from_now
        }, actor: users(:admin))
        if anonymous
          ballot = poll.anonymous_ballots.build(anonymous_ballot_choices_attributes: [{poll_option_id: poll.poll_options.first.id, score: 1}])
          AnonymousBallotService.create(anonymous_ballot: ballot, actor: @user)
        else
          stance = poll.stances.latest.find_by!(participant: users(:admin))
          stance.choice = 'Agree'
          stance.reason = 'Sensitive vote reason'
          StanceService.create(stance: stance, actor: users(:admin))
        end

        sign_in @user
        get :show, params: { key: @discussion.key }
        assert_response :success
        records = thread_records
        data = records['polls'].find { |row| row['id'] == poll.id }
        assert_equal mode != 'until_closed', data.key?('scores_by_option')
        if mode == 'until_closed' && !anonymous
          refute_includes records.fetch('stances', []).select { |row| row['poll_id'] == poll.id }.to_json, 'Sensitive vote reason'
        end
        if anonymous
          assert_equal true, data['anonymous_ballot_submitted']
          refute data.key?('vote_count_cast')
          refute records.key?('anonymous_ballots')
          refute records.key?('anonymous_poll_voters')
          assert_empty records.fetch('stances', []).select { |row| row['poll_id'] == poll.id }
        end

        PollService.close(poll: poll, actor: users(:admin))
        get :show, params: { key: @discussion.key }
        data = thread_records['polls'].find { |row| row['id'] == poll.id }
        assert_equal [1, 0], data['scores_by_option']
        sign_out
      end
    end
  end

  test "private discussion pages and feeds reject revoked and unrelated accounts" do
    discussion = topics(:discussion_topic).topicable
    %i[former_member_loud former_guest_loud alien server_admin].each do |role|
      sign_in users(role)
      [:html, :xml].each do |format|
        get :show, params: { key: discussion.key }, format: format

        assert_response :forbidden
        refute_includes response.body, discussion.description
      end
      sign_out
    end
  end

  test "public discussion has a clean canonical URL" do
    discussion = discussions(:public_discussion)
    get :show, params: { key: discussion.key, offset: 0, limit: 1, export: 1, sign_in: 1 }

    assert_response 200
    assert_select "link[rel='canonical'][href=?]", discussion_url(discussion)
    assert_select "meta[property='og:url'][content=?]", discussion_url(discussion)
    assert_select "meta[name='robots'][content='noindex,follow']"
    assert_select "a.navbar__sign-in[href='/dashboard']"
  end

  test "SSR batches uploaded avatars for comments and poll results" do
    discussion = discussions(:discussion)
    authors = [users(:admin), users(:user), users(:member)]
    authors.each do |author|
      blob = ActiveStorage::Blob.create_before_direct_upload!(filename: "avatar.png", byte_size: 10, checksum: "avatar", content_type: "image/png", metadata: {identified: true, analyzed: true, width: 128, height: 128})
      author.uploaded_avatar.attach(blob)
      author.update_column(:avatar_kind, "uploaded")
    end
    12.times do |index|
      author = authors[index % authors.size]
      comment = Comment.create!(parent: discussion, user: author, body: "Avatar comment #{index}", body_format: "html")
      TopicItem.create!(topic: discussion.topic, itemable: comment, user: author, kind: "new_comment", sequence_id: index + 2, position_key: "00000-#{format('%05d', index + 2)}", depth: 1)
    end
    poll = PollService.create(params: {title: "Avatar poll", poll_type: "proposal", topic_id: discussion.topic.id, poll_option_names: ["Agree", "Disagree"], closing_at: 1.day.from_now}, actor: users(:admin))
    authors.each do |author|
      stance = poll.stances.latest.find_or_initialize_by(participant: author)
      stance.update!(cast_at: Time.current, stance_choices_attributes: [{poll_option_id: poll.poll_options.first.id}])
    end
    poll.update_counts!

    queries = []
    sign_in @user
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
      if payload[:sql].start_with?('SELECT "active_storage_attachments".*') && payload[:binds].any? { |bind| bind.value_for_database == "uploaded_avatar" } && !payload[:cached]
        queries << payload[:sql]
      end
    end
    ActiveRecord::Base.uncached { get :show, params: {key: discussion.key, export: 1} }

    assert_response :success
    assert_select ".new-comment", count: 12
    assert_select ".email-results-table img.email-avatar[src*='/rails/active_storage/']", count: 3
    assert_operator queries.size, :<=, 5, queries.join("\n")
    assert_empty queries.grep(/\bLIMIT\b/), queries.join("\n")
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test "public discussion SSR does not render unsafe Markdown URLs" do
    discussion = discussions(:public_discussion)
    discussion.update!(
      description: "[unsafe](javascript&#58;alert(1))",
      description_format: "md"
    )

    get :show, params: { key: discussion.key, export: 1 }

    assert_response :success
    assert_select ".context-panel__description a[href='#']", text: "unsafe"
    assert_select "[href^='javascript:'], [src^='javascript:']", count: 0
    assert_select "[href^='data:'], [src^='data:']", count: 0
  end

  test "public discussion clamps invalid pagination values" do
    discussion = discussions(:public_discussion)

    get :show, params: { key: discussion.key, offset: -1, limit: -1, export: 1 }

    assert_response :success
    assert_equal({ limit: 1, offset: 0 }, assigns(:pagination))
  end

  test "show 404 for non-existent discussion" do
    get :show, params: { key: 'doesnotexist' }
    assert_response 404
    assert_nil assigns(:discussion)
  end

  test "signed in displays xml feed" do
    sign_in @user
    get :show, params: { key: @discussion.key }, format: :xml
    assert_response 200
    assert_equal @discussion, assigns(:discussion)
  end

  test "signed out displays xml feed for public discussion" do
    discussion = discussions(:public_discussion)
    get :show, params: { key: discussion.key }, format: :xml
    assert_response 200
    assert_equal discussion, assigns(:discussion)
  end

  test "xml feed renders comment links using contextual topic route" do
    # Regression: comment_url was called with wrong params (key:, comment_id:)
    # causing ActionController::UrlGenerationError (missing required key :id)
    discussion = discussions(:public_discussion)
    get :show, params: { key: discussion.key }, format: :xml
    assert_response 200
    assert_match %r{/d/#{discussion.key}\?comment_id=\d+}, @response.body
  end

  private

  def thread_records
    initial_data['requests'].find { |request| request['params'].key?('discussion_key') }['records']
  end

  def initial_data
    JSON.parse(Nokogiri::HTML(response.body).at_css('#initial-data').text)
  end
end
