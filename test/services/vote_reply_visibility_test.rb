require 'test_helper'

class VoteReplyVisibilityTest < ActiveSupport::TestCase
  test 'group and direct vote replies follow topic access regardless of voting' do
    [:discussion_topic, :direct_topic].each do |fixture|
      topic = topics(fixture)
      poll, stance = create_vote(topic: topic, hide_results: 'until_vote')
      voter = users(:guest_normal)
      reply = CommentService.create(comment: Comment.new(parent: stance, body: 'Early vote conversation'), actor: voter)
      nested = CommentService.create(comment: Comment.new(parent: reply, body: 'Nested vote conversation'), actor: voter)
      assert_predicate nested, :persisted?
      assert voter.can?(:show, nested)

      nonvoter = users(:guest_loud)
      refute poll.stances.latest.decided.exists?(participant_id: nonvoter.id)
      before_voting = CommentService.create(comment: Comment.new(parent: nested, body: 'Before voting'), actor: nonvoter)
      assert_predicate before_voting, :persisted?
      assert nonvoter.can?(:show, nested)

      [:former_guest_loud, :inactive_guest_loud, :non_guest_loud, :alien].each do |role|
        actor = users(role)
        refute actor.can?(:create, Comment.new(parent: nested, body: 'No access')), "#{fixture}: #{role}"
        refute actor.can?(:show, nested), "#{fixture}: #{role}"
      end
      refute LoggedOutUser.new.can?(:show, nested)

      assert_no_record_cache_fallbacks do
        payload = serialize(nested, user: voter)
        assert_equal reply.id, payload.fetch('comments').first.fetch('parent_id')
      end
      timeline = serialize(nested.created_topic_item, user: voter)
      assert timeline.fetch('polls').any? { |record| record['id'] == poll.id }

      stance.update!(revoked_at: Time.current)
      assert voter.can?(:create, Comment.new(parent: nested, body: 'Revoked vote'))
    end
  end

  test 'public until-closed polls refuse vote replies and exports until closing' do
    topic = topics(:public_discussion_topic)
    topic.group.add_admin!(users(:admin))
    poll, stance = create_vote(topic: topic, hide_results: 'until_closed', voter: users(:admin))
    assert_raises(CanCan::AccessDenied) do
      CommentService.create(comment: Comment.new(parent: stance, body: 'Early reply'), actor: users(:admin))
    end
    [users(:user), users(:alien), LoggedOutUser.new].each do |actor|
      refute actor.can?(:create, Comment.new(parent: stance, body: 'Hidden reply'))
    end
    [users(:admin), users(:user), users(:alien), LoggedOutUser.new].each do |actor|
      refute actor.can?(:export, poll)
    end
    PollService.close(poll: poll, actor: poll.author)
    assert users(:admin).can?(:create, Comment.new(parent: stance.reload, body: 'After closing'))
    assert users(:admin).can?(:export, poll)
  end

  test 'existing vote replies load normally while exports wait until closing' do
    poll, stance = create_vote(topic: topics(:discussion_topic), hide_results: 'off')
    reply = CommentService.create(comment: Comment.new(parent: stance, body: 'Private first reply'), actor: users(:guest_normal))
    nested = CommentService.create(comment: Comment.new(parent: reply, body: 'Private nested reply'), actor: users(:guest_normal))
    Reaction.create!(reactable: nested, user: users(:admin), reaction: 'secret-reaction')
    poll.update!(hide_results: 'until_closed')

    [users(:guest_normal), users(:admin), nil].each do |reader|
      payload = serialize(nested.reload, user: reader)
      comment = payload.fetch('comments').first
      assert_equal 'Private nested reply', comment['body']
      assert_equal reply.id, comment['parent_id']
      assert_equal nested.author_id, comment['author_id']
      assert_includes payload.to_json, 'secret-reaction'
    end

    shared = MessageChannelService.serialize_shared_models([nested.created_topic_item]).as_json.to_json
    assert_includes shared, 'Private nested reply'
    assert_includes shared, 'secret-reaction'
    markdown = ThreadMarkdownService.render(topic: poll.topic, user: users(:admin))
    assert_includes markdown, 'Private first reply'
    assert_includes markdown, 'Private nested reply'

    PollService.close(poll: poll, actor: poll.author)
    assert_equal 'Private nested reply', serialize(nested.reload, user: users(:guest_normal)).fetch('comments').first.fetch('body')
    assert_includes ThreadMarkdownService.render(topic: poll.topic, user: users(:admin)), 'Private nested reply'
  end

  test 'until-closed stance replies preserve group and direct topic access after closing' do
    [:discussion_topic, :direct_topic].each do |fixture|
      topic = topics(fixture)
      poll, stance = create_vote(topic: topic, hide_results: 'until_closed')
      roles = {member_normal: fixture == :discussion_topic, guest_normal: true, guest_admin_normal: true,
        alien_loud: false, non_guest_loud: false, former_member_loud: false, former_guest_loud: false,
        inactive_member_loud: false, inactive_guest_loud: false, server_admin: false}
      actors = roles.map { |role, allowed| [users(role), allowed] } + [[LoggedOutUser.new, false]]
      actors.each do |actor, allowed|
        assert_no_difference ['Comment.count', 'TopicItem.count', 'Notification.count'] do
          assert_raises(CanCan::AccessDenied) do
            CommentService.create(comment: Comment.new(parent: stance, body: 'Before closing'), actor: actor)
          end
        end
        assert_equal allowed, actor.can?(:create, Comment.new(parent: poll, body: 'Ordinary comment')), "#{fixture}: #{actor.name}"
      end
      PollService.close(poll: poll, actor: poll.author)
      stance.reload
      actors.each do |actor, allowed|
        comment = Comment.new(parent: stance, body: 'After closing')
        if allowed
          assert_predicate CommentService.create(comment: comment, actor: actor), :persisted?
        else
          assert_raises(CanCan::AccessDenied) { CommentService.create(comment: comment, actor: actor) }
        end
      end
    end
  end

  test 'a cached poll result setting cannot authorize a stance reply after the setting changes' do
    poll, stance = create_vote(topic: topics(:discussion_topic), hide_results: 'off')
    stance.poll # Prime the association before the setting changes.
    poll.update!(hide_results: 'until_closed')
    assert_no_difference ['Comment.count', 'TopicItem.count'] do
      assert_raises(CanCan::AccessDenied) do
        CommentService.create(comment: Comment.new(parent: stance, body: 'Stale reply'), actor: users(:guest_normal))
      end
    end
  end

  private

  def create_vote(topic:, hide_results:, voter: users(:guest_normal))
    topic.topicable.create_missing_created_topic_item! unless topic.topicable.created_topic_item
    poll = PollService.create(
      params: {topic_id: topic.id, title: 'Reply visibility', poll_type: 'proposal',
               poll_option_names: ['Agree', 'Disagree'], closing_at: 3.days.from_now, hide_results: hide_results},
      actor: topic.topicable.author
    )
    stance = poll.stances.latest.find_by!(participant_id: voter.id)
    stance.choice = 'Agree'
    stance.reason = 'A vote reason in the timeline'
    StanceService.create(stance: stance, actor: voter)
    [poll, stance.reload]
  end

  def serialize(record, user:)
    cache = RecordCache.for_collection([record], user&.id)
    MessageChannelService.serialize_models([record], scope: {cache: cache, current_user_id: user&.id}).as_json.deep_stringify_keys
  end
end
