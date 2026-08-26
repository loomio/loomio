require "test_helper"

class ChatbotSlackPhlexTest < ActiveSupport::TestCase
  def setup
    super
    @group = groups(:group)
    @user = users(:user)

    @recipient = LoggedOutUser.new(
      locale: 'en',
      time_zone: 'Pacific/Auckland',
      date_time_pref: 'iso'
    )

    @discussion = discussions(:discussion)
    @discussion.update_columns(title: "Chatbot Test Discussion", description: "<p>Discussion body text for chatbot</p>")

    ActionMailer::Base.deliveries.clear
  end

  def render_phlex(component)
    ApplicationController.renderer.render(component, layout: false)
  end

  test "poll component renders for active proposal" do
    poll = Poll.create!(
      title: "Active Proposal",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      topic: @discussion.topic,
      author: @user,
      poll_option_names: %w[agree disagree abstain]
    )
    poll.create_missing_created_topic_item!
    topic_item = poll.created_topic_item

    component = Views::Chatbot::Slack::Poll.new(topic_item: topic_item, poll: poll, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "created a proposal"
    assert_includes output, "Active Proposal"
    # Slack mrkdwn converts **bold** to *bold* and [text](url) to <url|text>
    assert_match(/<http.*\|Active Proposal>/, output)
  end

  test "poll component renders for closed proposal with votes" do
    poll = Poll.create!(
      title: "Closed Proposal",
      poll_type: "proposal",
      closing_at: 1.day.from_now,
      topic: @discussion.topic,
      author: @user,
      poll_option_names: %w[agree disagree abstain],
      specified_voters_only: true
    )
    poll.create_missing_created_topic_item!

    agree_option = poll.poll_options.find_by!(name: I18n.t('poll_proposal_options.agree'))
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: agree_option, score: 1)
    stance.save!

    poll.update!(closed_at: Time.current, closing_at: Time.current)
    poll.reload
    topic_item = poll.created_topic_item

    component = Views::Chatbot::Slack::Poll.new(topic_item: topic_item, poll: poll, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Closed Proposal"
    assert_includes output, I18n.t('poll_common.results').downcase.capitalize
  end

  test "discussion component renders" do
    topic_item = @discussion.created_topic_item

    component = Views::Chatbot::Slack::Discussion.new(topic_item: topic_item, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Chatbot Test Discussion"
    assert_includes output, "Discussion body text for chatbot"
  end

  test "notification component renders" do
    topic_item = @discussion.created_topic_item

    component = Views::Chatbot::Slack::Notification.new(topic_item: topic_item, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Chatbot Test Discussion"
  end

  test "notification component renders for poll" do
    poll = Poll.create!(
      title: "Test Proposal",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      topic: @discussion.topic,
      author: @user,
      poll_option_names: %w[agree disagree abstain]
    )
    poll.create_missing_created_topic_item!
    topic_item = poll.created_topic_item

    component = Views::Chatbot::Slack::Notification.new(topic_item: topic_item, poll: poll, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Test Proposal"
  end

  test "notification component renders for stance" do
    poll = Poll.create!(
      title: "Stance Notification Poll",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      topic: @discussion.topic,
      author: @user,
      poll_option_names: %w[agree disagree abstain],
      specified_voters_only: true
    )
    poll.create_missing_created_topic_item!

    agree_option = poll.poll_options.find_by!(name: I18n.t('poll_proposal_options.agree'))
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: agree_option, score: 1)
    stance.save!
    topic_item = TopicItems::StanceCreated.create!(itemable: stance)

    component = Views::Chatbot::Slack::Notification.new(topic_item: topic_item, poll: poll, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Stance Notification Poll"
    assert_includes output, @user.name
  end

  test "comment component renders" do
    comment = Comment.create!(
      body: "Test comment body",
      body_format: "md",
      parent: @discussion,
      author: @user
    )
    comment.create_missing_created_topic_item!
    topic_item = comment.created_topic_item

    component = Views::Chatbot::Slack::Comment.new(topic_item: topic_item, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Test comment body"
    assert_includes output, "Chatbot Test Discussion"
  end

  test "slack_component class method returns correct components" do
    topic_item = @discussion.created_topic_item

    component = ChatbotService.slack_component('discussion', topic_item: topic_item, poll: nil, recipient: @recipient)
    assert_instance_of Views::Chatbot::Slack::Discussion, component

    component = ChatbotService.slack_component('notification', topic_item: topic_item, poll: nil, recipient: @recipient)
    assert_instance_of Views::Chatbot::Slack::Notification, component

    component = ChatbotService.slack_component('unknown', topic_item: topic_item, poll: nil, recipient: @recipient)
    assert_instance_of Views::Chatbot::Slack::Notification, component
  end
end
