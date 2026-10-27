require 'test_helper'

class Api::V1::SearchIndexVisibilityTest < ActionController::TestCase
  tests Api::V1::SearchController

  setup do
    PgSearch::Document.delete_all
    PgSearch::Document.connection.execute(<<~SQL)
      INSERT INTO pg_search_words (word, document_count) VALUES ('indexvisibility', 100)
      ON CONFLICT (word) DO UPDATE SET document_count = EXCLUDED.document_count
    SQL
  end

  [ nil, :admin, :member_normal, :guest_normal, :guest_admin_normal, :alien_loud,
   :non_guest_loud, :former_member_loud, :former_guest_loud, :inactive_member_loud,
   :inactive_guest_loud, :server_admin ].each do |role|
    test "stale comment documents respect deletion and access for #{role || 'signed out readers'} in every search mode" do
      sign_in users(role) if role
      [ :discussion_topic, :direct_topic ].each do |fixture|
        topic = topics(fixture)
        author = users(:guest_normal)
        comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'indexvisibility'), actor: author)
        TopicItemService.update_tags(topic_item: comment.created_topic_item, tags: [ 'Visibility' ], actor: fixture == :discussion_topic ? users(:admin) : author)
        ReindexSearchDocumentWorker.perform_now('Comment', comment.id)
        roles = {
          admin: fixture == :discussion_topic, member_normal: fixture == :discussion_topic,
          guest_normal: true, guest_admin_normal: true,
          alien_loud: false, non_guest_loud: false, former_member_loud: false,
          former_guest_loud: false, inactive_member_loud: false, inactive_guest_loud: false,
          server_admin: false
        }

        [ false, true ].each do |discarded|
          comment.update_columns(discarded_at: Time.current) if discarded
          assert PgSearch::Document.exists?(searchable: comment)
          [ { query: 'indexvisibility' }, { query: 'indexvisibilty' }, { author_id: author.id }, { tag: 'Visibility' } ].each do |params|
            get :index, params: params
            assert_response :success
            assert_equal roles.fetch(role, false) && !discarded, result_includes?(comment), "#{fixture}: #{role}, #{params}, discarded=#{discarded}"
          end
        end
      end
    end
  end

  test 'stale vote reasons honor live result visibility anonymity and redaction before reindexing' do
    [ :discussion_topic, :direct_topic ].each do |fixture|
      topic = topics(fixture)
      poll = create_poll(topic)
      author = users(:guest_normal)
      stance = poll.stances.latest.find_by!(participant: author)
      stance.choice = 'Agree'
      stance.reason = 'indexvisibility vote reason'
      StanceService.create(stance: stance, actor: author)
      ReindexSearchDocumentWorker.perform_now('Stance', stance.id)
      assert PgSearch::Document.exists?(searchable: stance)

      %w[off until_vote until_closed].each do |mode|
        [ nil, Time.current ].each do |closed_at|
          poll.update_columns(hide_results: Poll.hide_results.fetch(mode), closed_at: closed_at)
          [ :admin, :guest_normal, :guest_admin_normal ].each do |role|
            sign_in users(role)
            [ { query: 'indexvisibility' }, { query: 'indexvisibilty' }, { author_id: author.id } ].each do |params|
              get :index, params: params
              allowed = (fixture == :discussion_topic || role != :admin) && (mode != 'until_closed' || closed_at.present?)
              assert_equal allowed, result_includes?(stance), "#{fixture}: #{mode}, #{role}, #{params}"
            end
          end
        end
      end

      StanceService.redact(stance: stance, actor: poll.author)
      assert PgSearch::Document.exists?(searchable: stance)
      get :index, params: { query: 'indexvisibility' }
      assert_not result_includes?(stance)
      StanceService.unredact(stance: stance, actor: poll.author)
      get :index, params: { query: 'indexvisibility' }
      assert result_includes?(stance)

      poll.update_columns(anonymous: true)
      get :index, params: { query: 'indexvisibility' }
      assert_not result_includes?(stance)
      ReindexSearchDocumentWorker.perform_now('Stance', stance.id)
      assert_not PgSearch::Document.exists?(searchable: stance)
    end
  end

  test 'discarded polls hide stale poll outcome and deeply nested comment documents' do
    topic = topics(:discussion_topic)
    topic.update!(max_depth: 1)
    poll = create_poll(topic)
    PollService.close(poll: poll, actor: poll.author)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: poll, statement: 'indexvisibility outcome'), actor: poll.author)
    comment = CommentService.create(comment: Comment.new(parent: outcome, body: 'indexvisibility parent'), actor: users(:guest_normal))
    nested = CommentService.create(comment: Comment.new(parent: comment, body: 'indexvisibility nested'), actor: users(:guest_normal))
    records = [ poll, outcome, comment, nested ]
    records.each(&:update_pg_search_document)
    sign_in users(:guest_normal)
    get :index, params: { query: 'indexvisibility' }
    records.each { |record| assert result_includes?(record) }

    PollService.discard(poll: poll, actor: poll.author)
    records.each { |record| assert PgSearch::Document.exists?(searchable: record) }
    [ { query: 'indexvisibility' }, { query: 'indexvisibilty' }, { author_id: users(:guest_normal).id } ].each do |params|
      get :index, params: params
      records.each { |record| assert_not result_includes?(record) }
    end
    ReindexPollWorker.perform_now(poll.id)
    records.each { |record| assert_not PgSearch::Document.exists?(searchable: record) }
  end

  test 'stale documents cannot follow a poll into a topic the searcher cannot access' do
    poll = create_poll(topics(:discussion_topic))
    poll.update_pg_search_document
    sign_in users(:member_normal)
    get :index, params: { query: 'indexvisibility' }
    assert result_includes?(poll)

    poll.update_columns(topic_id: topics(:alien_discussion_topic).id)
    get :index, params: { query: 'indexvisibility' }
    assert_not result_includes?(poll)
  end

  private

  def create_poll(topic)
    PollService.create(params: { topic_id: topic.id, title: 'indexvisibility poll', poll_type: 'proposal',
      closing_at: 2.days.from_now, poll_option_names: [ 'Agree' ] }, actor: topic.topicable.author)
  end

  def result_includes?(record)
    response.parsed_body.fetch('search_results').any? do |row|
      row['searchable_type'] == record.class.name && row['searchable_id'] == record.id
    end
  end
end
