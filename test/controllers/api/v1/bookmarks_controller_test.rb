require 'test_helper'

class Api::V1::BookmarksControllerTest < ActionController::TestCase
  def build_comment(author)
    comment = Comment.new(body: "Test comment", parent: discussions(:discussion), author: author)
    CommentService.create(comment: comment, actor: author)
    comment
  end

  test "create bookmarks the comment when authorized" do
    user = users(:admin)
    comment = build_comment(user)

    sign_in user
    assert_difference 'Bookmark.count', 1 do
      post :create, params: { bookmark: { bookmarkable_id: comment.id, bookmarkable_type: 'Comment' } }
    end
    assert_response :success
    assert Bookmark.exists?(user: user, bookmarkable: comment)
  end

  test "create is idempotent — bookmarking twice keeps a single bookmark" do
    user = users(:admin)
    comment = build_comment(user)

    sign_in user
    post :create, params: { bookmark: { bookmarkable_id: comment.id, bookmarkable_type: 'Comment' } }
    assert_no_difference 'Bookmark.count' do
      post :create, params: { bookmark: { bookmarkable_id: comment.id, bookmarkable_type: 'Comment' } }
    end
    assert_response :success
  end

  test "create responds forbidden when user cannot see the record" do
    author = users(:admin)
    comment = build_comment(author)

    outsider = User.create!(
      name: "Outsider",
      email: "outsider-#{SecureRandom.hex(4)}@example.com",
      username: "outsider#{SecureRandom.hex(4)}",
      email_verified: true
    )

    sign_in outsider
    assert_no_difference 'Bookmark.count' do
      post :create, params: { bookmark: { bookmarkable_id: comment.id, bookmarkable_type: 'Comment' } }
    end
    assert_response :forbidden
  end

  test "index returns empty collection when logged out" do
    get :index
    assert_response :success
    assert_equal [], JSON.parse(response.body)['bookmarks']
  end

  test "index returns only the current user's bookmarks" do
    user = users(:admin)
    other = users(:user)
    comment = build_comment(user)

    mine = Bookmark.create!(user: user, bookmarkable: comment)
    Bookmark.create!(user: other, bookmarkable: comment)

    sign_in user
    get :index
    assert_response :success
    ids = JSON.parse(response.body)['bookmarks'].map { |b| b['id'] }
    assert_equal [mine.id], ids
  end

  test "destroy soft-discards the bookmark and drops it from the index" do
    user = users(:admin)
    comment = build_comment(user)
    bookmark = Bookmark.create!(user: user, bookmarkable: comment)

    sign_in user
    assert_no_difference 'Bookmark.count' do
      delete :destroy, params: { id: bookmark.id }
    end
    assert_response :success
    assert bookmark.reload.discarded?

    get :index
    refute_includes JSON.parse(response.body)['bookmarks'].map { |b| b['id'] }, bookmark.id
  end

  test "re-bookmarking a discarded item undiscards the same row" do
    user = users(:admin)
    comment = build_comment(user)
    bookmark = Bookmark.create!(user: user, bookmarkable: comment, discarded_at: Time.now)

    sign_in user
    assert_no_difference 'Bookmark.count' do
      post :create, params: { bookmark: { bookmarkable_id: comment.id, bookmarkable_type: 'Comment' } }
    end
    assert_response :success
    refute bookmark.reload.discarded?
  end

  test "destroy forbidden for another user's bookmark" do
    user = users(:admin)
    other = users(:user)
    comment = build_comment(user)
    bookmark = Bookmark.create!(user: other, bookmarkable: comment)

    sign_in user
    assert_no_difference 'Bookmark.count' do
      delete :destroy, params: { id: bookmark.id }
    end
    assert_response :forbidden
  end

  test "create does not allow anonymous stances to be enumerated as bookmark targets" do
    voter = users(:member)
    stance = anonymous_stance_for(voter)
    sign_in users(:user)

    assert_no_difference 'Bookmark.count' do
      post :create, params: {bookmark: {bookmarkable_id: stance.id, bookmarkable_type: 'Stance'}}
    end

    assert_response :not_found
    assert_equal I18n.t('common.anonymous'), stance.author.name
    refute_includes response.body, voter.name
    refute_includes response.body, stance.id.to_s
  end

  test "index excludes legacy stance bookmarks" do
    user = users(:user)
    stance = anonymous_stance_for(users(:member))
    bookmark = Bookmark.create!(user: user, bookmarkable: stance)
    sign_in user

    get :index

    assert_response :success
    refute_includes JSON.parse(response.body).fetch('bookmarks').map { |record| record['id'] }, bookmark.id
  end

  private

  def anonymous_stance_for(voter)
    poll = PollService.create(params: {
      title: 'Anonymous bookmark target',
      poll_type: 'proposal',
      group_id: groups(:group).id,
      anonymous: true,
      hide_results: 'until_closed',
      poll_option_names: %w[Agree Disagree],
      closing_at: 1.day.from_now
    }, actor: users(:admin))
    poll.stances.latest.find_by!(participant_id: voter.id)
  end
end
