require 'test_helper'

class TopicHeadingsServiceTest < ActiveSupport::TestCase
  test 'HTML labels are plain text and duplicate headings retain distinct positions' do
    text = '<h1>Agenda &amp; <em>background</em></h1><h2> </h2><h2>Agenda</h2><h3>Agenda</h3><p>Text</p>'
    assert_equal [
      {index: 0, level: 1, title: 'Agenda & background'},
      {index: 2, level: 2, title: 'Agenda'},
      {index: 3, level: 3, title: 'Agenda'}
    ], HasRichText.headings(text, 'html')
  end

  test 'Markdown supports all heading levels, setext headings and non-Latin labels but excludes code' do
    text = "# Agenda\n\n## Second\n\n### Third\n\n#### Fourth\n\n##### Fifth\n\n###### 日本語\n\nUnderlined\n---\n\n```\n# Code\n```\n\nOrdinary text"
    headings = HasRichText.headings(text, 'md')
    assert_equal [1, 2, 3, 4, 5, 6, 2], headings.pluck(:level)
    assert_equal ['Agenda', 'Second', 'Third', 'Fourth', 'Fifth', '日本語', 'Underlined'], headings.pluck(:title)
    assert_equal (0..6).to_a, headings.pluck(:index)
    assert_empty HasRichText.headings(nil, 'html')
    assert_empty HasRichText.headings('No headings', 'md')
  end

  test 'outline follows thread order and omits removed content and descendants of removed polls' do
    topic = topics(:discussion_topic)
    discussion = topic.topicable
    discussion.update!(description: '# Context', description_format: 'md')
    poll = create_poll
    comment = CommentService.create(comment: Comment.new(parent: poll, body: '<h2>Comment</h2>', body_format: 'html'), actor: users(:member))
    poll.update!(closed_at: Time.current)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: poll, statement: '# Outcome', statement_format: 'md'), actor: users(:admin))
    assert_equal ['Context', 'Details', 'Comment', 'Outcome'], headings_for(topic).pluck(:title)

    comment.discard!
    assert_equal ['Context', 'Details', 'Outcome'], headings_for(topic).pluck(:title)
    comment.undiscard!
    poll.discard!
    assert_equal ['Context'], headings_for(topic).pluck(:title)
  end

  test 'vote reason headings obey until-vote and until-closed visibility even for their author and admins' do
    poll = create_poll
    stance = poll.stances.latest.find_by!(participant: users(:member))
    stance.reason = '# Vote reason'
    stance.reason_format = 'md'
    stance.choice = 'Agree'
    StanceService.create(stance: stance, actor: users(:member))
    %w[off until_vote until_closed].each do |mode|
      poll.update!(hide_results: mode)
      [LoggedOutUser.new, users(:member), users(:admin), users(:guest_normal)].each do |viewer|
        titles = headings_for(poll.topic, viewer).select { |row| row[:field] == :reason }.pluck(:title)
        visible = mode == 'off' || (mode == 'until_vote' && viewer.id == stance.participant_id)
        assert_equal visible ? ['Vote reason'] : [], titles, "#{mode}, viewer #{viewer.id}"
      end
    end
    poll.update!(closed_at: Time.current)
    assert_includes headings_for(poll.topic).pluck(:title), 'Vote reason'
    stance.update!(redacted_at: Time.current)
    assert_not_includes headings_for(poll.topic).pluck(:title), 'Vote reason'
    stance.update!(redacted_at: nil, revoked_at: Time.current)
    assert_not_includes headings_for(poll.topic).pluck(:title), 'Vote reason'
  end

  test 'anonymous polls contribute details but never expose legacy reasons or voter associations' do
    poll = create_poll(anonymous: true)
    assert_equal ['Details'], headings_for(poll.topic).select { |row| row[:model_type] == 'poll' }.pluck(:title)
    assert_empty headings_for(poll.topic).select { |row| row[:model_type] == 'stance' }
  end

  test 'cached automatic translations supply labels without calling the translation provider' do
    topic = topics(:discussion_topic)
    topic.topicable.update!(description: '# Original', description_format: 'md')
    user = users(:user)
    user.update!(auto_translate: true, selected_locale: 'fr')
    Translation.create!(translatable: topic.topicable, language: 'fr', fields: {'description' => '<h1>Contexte traduit</h1>'})
    TranslationService.stub(:available?, true) do
      assert_equal ['Contexte traduit'], headings_for(topic, user).pluck(:title)
    end
  end

  private

  def headings_for(topic, user = users(:admin))
    items = TopicHeadingsService.items(topic).order(:position_key, :id).preload(:itemable).to_a
    TopicHeadingsService.sections(items, user).flat_map do |section|
      section[:headings].map { |heading| section.except(:headings).merge(heading) }
    end
  end

  def create_poll(**options)
    PollService.create(params: {
      topic_id: topics(:discussion_topic).id, title: 'Heading navigation',
      details: '<h2>Details</h2>', details_format: 'html',
      poll_type: 'proposal', poll_option_names: %w[Agree Disagree], closing_at: 1.day.from_now
    }.merge(options), actor: users(:admin))
  end
end
