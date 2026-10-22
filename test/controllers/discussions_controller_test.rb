require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  test "show 200 ssr and boot for signed in member" do
    sign_in @user
    get :show, params: { key: @discussion.key }
    assert_response 200
    assert_equal @discussion, assigns(:discussion)
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
end
