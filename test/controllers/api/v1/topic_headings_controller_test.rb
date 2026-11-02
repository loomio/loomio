require 'test_helper'

class Api::V1::TopicHeadingsControllerTest < ActionController::TestCase
  tests Api::V1::TopicItemsController

  test 'headings are a separate compact response with bounded pagination and jump targets' do
    topic = topics(:discussion_topic)
    topic.topicable.update!(description: '# Context', description_format: 'md')
    comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: '<h2>Reply</h2>', body_format: 'html'), actor: users(:member_normal))
    sign_in users(:member_normal)
    get :headings, params: {topic_id: topic.id, limit: 1}
    assert_response :success
    assert_equal ['Context'], response.parsed_body.fetch('sections').flat_map { |section| section.fetch('headings').pluck('title') }
    assert_equal 1, response.parsed_body.dig('meta', 'next_offset')
    assert_equal %w[meta sections], response.parsed_body.keys.sort
    get :headings, params: {topic_id: topic.id, limit: 1, offset: 1}
    row = response.parsed_body.fetch('sections').sole
    assert_equal({
      'headings' => [{'title' => 'Reply', 'level' => 2, 'index' => 0}],
      'topic_item_id' => comment.created_topic_item.id, 'sequence_id' => comment.created_topic_item.sequence_id,
      'model_type' => 'comment', 'model_id' => comment.id, 'field' => 'body',
      'position_key' => comment.created_topic_item.position_key, 'poll_id' => nil
    }, row)
    get :headings, params: {topic_id: topic.id, offset: 2}
    assert_empty response.parsed_body.fetch('sections')
    assert_nil response.parsed_body.dig('meta', 'next_offset')
  end

  test 'content without headings retains enough metadata for a later local update' do
    topic = topics(:discussion_topic)
    comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'No headings yet'), actor: users(:member_normal))
    sign_in users(:member_normal)
    get :headings, params: {topic_id: topic.id}
    assert_response :success
    section = response.parsed_body.fetch('sections').find { |row| row['model_type'] == 'comment' && row['model_id'] == comment.id }
    assert_empty section.fetch('headings')
    assert_equal comment.created_topic_item.position_key, section.fetch('position_key')
    assert_equal comment.created_topic_item.sequence_id, section.fetch('sequence_id')
    assert_equal 'body', section.fetch('field')
    assert_not section.key?('body')
  end

  %i[discussion_topic direct_topic].each do |topic_fixture|
    %i[guest_normal guest_admin_normal].each do |role|
      test "#{role} can read headings in #{topic_fixture}" do
        topic = topics(topic_fixture)
        topic.topicable.update!(description: '# Allowed context', description_format: 'md')
        sign_in users(role)
        get :headings, params: {topic_id: topic.id}
        assert_response :success
        assert_equal ['Allowed context'], response.parsed_body.fetch('sections').flat_map { |section| section.fetch('headings').pluck('title') }
      end
    end
    %i[alien_loud non_guest_loud former_guest_loud inactive_guest_loud].each do |role|
      test "#{role} cannot read headings in #{topic_fixture}" do
        topic = topics(topic_fixture)
        topic.topicable.update!(description: '# Secret context', description_format: 'md')
        sign_in users(role)
        get :headings, params: {topic_id: topic.id}
        assert_includes [401, 403], response.status
        assert_not_includes response.body, 'Secret context'
      end
    end
  end

  test 'signed-out visitors can only read headings from public threads' do
    topic = topics(:public_discussion_topic)
    topic.topicable.update!(description: '# Public context', description_format: 'md')
    get :headings, params: {topic_id: topic.id}
    assert_response :success
    assert_equal ['Public context'], response.parsed_body.fetch('sections').flat_map { |section| section.fetch('headings').pluck('title') }
    get :headings, params: {topic_id: topics(:discussion_topic).id}
    assert_response :forbidden
  end
end
