require "test_helper"

class ChatbotMatrixPhlexComparisonTest < ActiveSupport::TestCase
  def setup
    super
    @group = groups(:test_group)
    @user = users(:discussion_author)
    @group.add_admin!(@user)

    @recipient = LoggedOutUser.new(
      locale: 'en',
      time_zone: 'Pacific/Auckland',
      date_time_pref: 'iso'
    )

    @discussion = Discussion.create!(
      title: "Chatbot Test Discussion",
      description: "<p>Discussion body text for chatbot</p>",
      description_format: "html",
      private: true,
      author: @user,
      group: @group
    )
    @discussion.create_missing_created_event!

    ActionMailer::Base.deliveries.clear
  end

  def normalize(html)
    result = html
      .gsub(/\s+/, ' ')        # collapse whitespace
      .gsub(/>\s+</, '><')     # remove whitespace between tags
      .gsub(/>\s+/, '>')       # remove whitespace after opening tags
      .gsub(/\s+</, '<')       # remove whitespace before closing tags
      .gsub("'", '"')          # normalize quotes
      .gsub('&amp;', '&')      # normalize entity encoding
      .gsub(' />', '>')        # normalize self-closing tags
      .gsub('<tr></tr>', '')    # remove empty tr (HAML bug)
      .gsub(/<thead>(.*?)<\/thead>/m) { |m| m.gsub(/<\/?tr>/, '') } # normalize thead tr wrapping
      .strip

    # Normalize HTML attribute order within tags
    result.gsub(/<(\w+)((?:\s+[\w-]+="[^"]*")+)\s*\/?>/) do |match|
      tag = $1
      attrs_str = $2
      closing = match.end_with?('/>') ? '>' : match[-1]
      attrs = attrs_str.scan(/\s+([\w-]+="[^"]*")/).flatten.sort
      "<#{tag} #{attrs.join(' ')}#{closing}"
    end
  end

  def render_haml(template_name, event:, poll: nil)
    ApplicationController.renderer.render(
      layout: nil,
      template: "chatbot/matrix/#{template_name}",
      assigns: { poll: poll, event: event, recipient: @recipient }
    )
  end

  def render_phlex(component)
    ApplicationController.renderer.render(component, layout: false)
  end

  def compare(template_name, component, event:, poll: nil)
    haml_raw = render_haml(template_name, event: event, poll: poll)
    phlex_raw = render_phlex(component)
    haml_html = normalize(haml_raw)
    phlex_html = normalize(phlex_raw)

    if haml_html != phlex_html
      puts "\n=== HAML (#{template_name}) ==="
      puts haml_raw
      puts "\n=== Phlex (#{template_name}) ==="
      puts phlex_raw
      puts "=== END ==="
    end

    assert_equal haml_html, phlex_html, "Phlex output differs from HAML for #{template_name}"
  end

  test "discussion template matches" do
    event = @discussion.created_event

    component = Views::Chatbot::Matrix::Discussion.new(
      event: event, poll: nil, recipient: @recipient
    )

    compare('discussion', component, event: event)
  end

  test "notification template matches for discussion" do
    event = @discussion.created_event

    component = Views::Chatbot::Matrix::Notification.new(
      event: event, poll: nil, recipient: @recipient
    )

    compare('notification', component, event: event)
  end

  test "notification template matches for poll" do
    poll = Poll.create!(
      title: "Test Proposal",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain]
    )
    poll.create_missing_created_event!
    event = poll.created_event

    component = Views::Chatbot::Matrix::Notification.new(
      event: event, poll: poll, recipient: @recipient
    )

    compare('notification', component, event: event, poll: poll)
  end

  test "poll template matches for active proposal" do
    poll = Poll.create!(
      title: "Active Proposal",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain]
    )
    poll.create_missing_created_event!
    event = poll.created_event

    component = Views::Chatbot::Matrix::Poll.new(
      event: event, poll: poll, recipient: @recipient
    )

    compare('poll', component, event: event, poll: poll)
  end

  test "poll template matches for closed proposal with votes" do
    poll = Poll.create!(
      title: "Closed Proposal",
      poll_type: "proposal",
      closing_at: 1.day.from_now,
      group: @group,
      discussion: @discussion,
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

    component = Views::Chatbot::Matrix::Poll.new(
      event: event, poll: poll, recipient: @recipient
    )

    compare('poll', component, event: event, poll: poll)
  end

  test "poll template matches for meeting poll" do
    option1 = 3.days.from_now.beginning_of_hour.iso8601
    option2 = 4.days.from_now.beginning_of_hour.iso8601

    poll = Poll.create!(
      title: "Meeting Poll",
      poll_type: "meeting",
      closing_at: 2.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: [option1, option2]
    )
    poll.create_missing_created_event!
    event = poll.created_event

    component = Views::Chatbot::Matrix::Poll.new(
      event: event, poll: poll, recipient: @recipient
    )

    compare('poll', component, event: event, poll: poll)
  end
end
