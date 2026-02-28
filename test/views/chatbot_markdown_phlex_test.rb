require "test_helper"

class ChatbotMarkdownPhlexTest < ActiveSupport::TestCase
  def setup
    super
    @group = groups(:group)
    @user = users(:admin)

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
    poll.create_missing_created_event!
    event = poll.created_event

    component = Views::Chatbot::Markdown::Poll.new(event: event, poll: poll, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Active Proposal"
    assert_includes output, "created a proposal"
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
    poll.create_missing_created_event!

    agree_option = poll.poll_options.find_by!(name: I18n.t('poll_proposal_options.agree'))
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: agree_option, score: 1)
    stance.save!

    poll.update!(closed_at: Time.current, closing_at: Time.current)
    poll.reload
    event = poll.created_event

    component = Views::Chatbot::Markdown::Poll.new(event: event, poll: poll, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Closed Proposal"
    assert_includes output, I18n.t('poll_proposal_options.agree')
  end

  test "discussion component renders" do
    event = @discussion.created_event

    component = Views::Chatbot::Markdown::Discussion.new(event: event, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Chatbot Test Discussion"
  end

  test "notification component renders" do
    event = @discussion.created_event

    component = Views::Chatbot::Markdown::Notification.new(event: event, recipient: @recipient)
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
    poll.create_missing_created_event!
    event = poll.created_event

    component = Views::Chatbot::Markdown::Notification.new(event: event, poll: poll, recipient: @recipient)
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
    poll.create_missing_created_event!

    agree_option = poll.poll_options.find_by!(name: I18n.t('poll_proposal_options.agree'))
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: agree_option, score: 1)
    stance.save!
    event = Events::StanceCreated.create!(kind: 'stance_created', eventable: stance, user: @user)

    component = Views::Chatbot::Markdown::Notification.new(event: event, poll: poll, recipient: @recipient)
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
    comment.create_missing_created_event!
    event = comment.created_event

    component = Views::Chatbot::Markdown::Comment.new(event: event, recipient: @recipient)
    output = render_phlex(component)

    assert_includes output, "Test comment body"
    assert_includes output, "Chatbot Test Discussion"
  end

  test "markdown_component class method returns correct components" do
    event = @discussion.created_event

    component = ChatbotService.markdown_component('discussion', event: event, poll: nil, recipient: @recipient)
    assert_instance_of Views::Chatbot::Markdown::Discussion, component

    component = ChatbotService.markdown_component('notification', event: event, poll: nil, recipient: @recipient)
    assert_instance_of Views::Chatbot::Markdown::Notification, component

    component = ChatbotService.markdown_component('unknown', event: event, poll: nil, recipient: @recipient)
    assert_instance_of Views::Chatbot::Markdown::Notification, component
  end
end
