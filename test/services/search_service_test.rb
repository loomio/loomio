require 'test_helper'

class SearchServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @group = groups(:group)
    @discussion = discussions(:discussion)
    PgSearch::Document.delete_all
  end

  # -- reindex_by_discussion_id --

  test "reindex_by_discussion_id creates a pg_search document for the discussion" do
    SearchService.reindex_by_discussion_id(@discussion.id)

    assert PgSearch::Document.where(searchable_type: 'Discussion', searchable_id: @discussion.id).exists?
  end

  test "reindex_by_discussion_id replaces an existing document" do
    SearchService.reindex_by_discussion_id(@discussion.id)
    first_count = PgSearch::Document.where(searchable_type: 'Discussion', searchable_id: @discussion.id).count

    SearchService.reindex_by_discussion_id(@discussion.id)
    second_count = PgSearch::Document.where(searchable_type: 'Discussion', searchable_id: @discussion.id).count

    assert_equal first_count, second_count
  end

  test "reindex_by_discussion_id removes all documents for a discarded discussion" do
    comment = Comment.new(parent: @discussion, body: 'Secret deleted comment')
    CommentService.create(comment: comment, actor: @user)
    SearchService.reindex_by_discussion_id(@discussion.id)
    assert PgSearch::Document.where(discussion_id: @discussion.id).exists?

    discarded_at = Time.current
    @discussion.update_columns(discarded_at: discarded_at)
    @discussion.topic.update_columns(discarded_at: discarded_at)
    SearchService.reindex_by_discussion_id(@discussion.id)

    refute PgSearch::Document.where(discussion_id: @discussion.id).exists?
  end

  test "reindex_by_discussion_id removes legacy documents when only the discussion is discarded" do
    comment = Comment.new(parent: @discussion, body: 'Legacy deleted comment')
    CommentService.create(comment: comment, actor: @user)
    SearchService.reindex_by_discussion_id(@discussion.id)
    assert PgSearch::Document.where(discussion_id: @discussion.id).exists?

    @discussion.update_columns(discarded_at: Time.current)
    SearchService.reindex_by_discussion_id(@discussion.id)

    refute PgSearch::Document.where(discussion_id: @discussion.id).exists?
  end

  # -- reindex_by_comment_id --

  test "reindex_by_comment_id creates a pg_search document for the comment" do
    comment = comments(:public_discussion_comment)
    SearchService.reindex_by_comment_id(comment.id)

    assert PgSearch::Document.where(searchable_type: 'Comment', searchable_id: comment.id).exists?
  end

  test "reindex_by_comment_id replaces an existing document" do
    comment = comments(:public_discussion_comment)
    SearchService.reindex_by_comment_id(comment.id)
    first_count = PgSearch::Document.where(searchable_type: 'Comment', searchable_id: comment.id).count

    SearchService.reindex_by_comment_id(comment.id)
    second_count = PgSearch::Document.where(searchable_type: 'Comment', searchable_id: comment.id).count

    assert_equal first_count, second_count
  end

  # -- reindex_by_author_id --

  test "reindex_by_author_id creates pg_search documents for discussions authored by the user" do
    SearchService.reindex_by_author_id(@admin.id)

    assert PgSearch::Document.where(author_id: @admin.id).exists?
  end

  test "reindex_by_author_id clears previous documents before reindexing" do
    SearchService.reindex_by_author_id(@admin.id)
    count_after_first = PgSearch::Document.where(author_id: @admin.id).count

    SearchService.reindex_by_author_id(@admin.id)
    count_after_second = PgSearch::Document.where(author_id: @admin.id).count

    assert_equal count_after_first, count_after_second
  end

  # -- reindex_by_poll_id --

  test "reindex_by_poll_id creates a pg_search document for the poll" do
    poll = PollService.create(
      actor: @admin,
      params: {
        title: 'Test poll for search',
        poll_type: 'proposal',
        group_id: @group.id,
        closing_at: 3.days.from_now,
        poll_option_names: %w[agree disagree abstain]
      }
    )

    PgSearch::Document.delete_all

    SearchService.reindex_by_poll_id(poll.id)

    assert PgSearch::Document.where(searchable_type: 'Poll', searchable_id: poll.id).exists?
  end

  test "rebuild_words retains established multilingual words" do
    PgSearch::Document.create!(
      searchable_type: 'Discussion',
      searchable_id: 1,
      content: 'democracia',
      ts_content: "'democracia':1"
    )
    PgSearch::Document.create!(
      searchable_type: 'Discussion',
      searchable_id: 2,
      content: 'democracia',
      ts_content: "'democracia':1"
    )
    PgSearch::Document.create!(
      searchable_type: 'Discussion',
      searchable_id: 3,
      content: 'democracia',
      ts_content: "'democracia':1"
    )

    SearchService.rebuild_words

    assert_equal 3, ActiveRecord::Base.connection.select_value(<<~SQL.squish)
      SELECT document_count
      FROM pg_search_words
      WHERE word = 'democracia'
    SQL
  end
end
