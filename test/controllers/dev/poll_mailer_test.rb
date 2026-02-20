require 'test_helper'

# Email rendering tests using fixtures for users/group/discussion.
# Only creates polls (which are poll_type-specific) per test.
class Dev::PollMailerTest < ActiveSupport::TestCase
  include Dev::FakeDataHelper

  # POLL_TYPES = %w[proposal poll dot_vote score count meeting ranked_choice].freeze
  POLL_TYPES = %w[proposal].freeze

  setup do
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"
    @group = groups(:test_group)
    @actor = users(:group_admin)
    @observer = users(:normal_user)
    @voter = users(:another_user)
    @mentioned = users(:discussion_author)
    @discussion = discussions(:test_discussion)
    ActionMailer::Base.deliveries.clear
  end

  private

  def option_names_for(poll_type)
    case poll_type.to_s
    when 'proposal' then %w[agree abstain disagree block]
    when 'count' then %w[accept decline]
    when 'meeting' then [3.days.from_now.iso8601, 4.days.from_now.iso8601, 5.days.from_now.iso8601]
    else %w[Option_A Option_B Option_C]
    end
  end

  def poll_extra_config(poll_type)
    case poll_type.to_s
    when 'dot_vote' then {dots_per_person: 10}
    when 'meeting' then {time_zone: 'Asia/Seoul', can_respond_maybe: true}
    when 'ranked_choice' then {minimum_stance_choices: 3}
    when 'score' then {max_score: 9, min_score: 0}
    else {}
    end
  end

  def build_poll(poll_type:, anonymous: false, hide_results: :off, **overrides)
    Poll.new({
      title: "Test #{poll_type} poll",
      poll_type: poll_type,
      discussion: @discussion,
      group: @group,
      author: @actor,
      anonymous: anonymous,
      hide_results: hide_results,
      closing_at: 5.days.from_now,
      poll_option_names: option_names_for(poll_type),
      specified_voters_only: false
    }.merge(poll_extra_config(poll_type)).merge(overrides))
  end

  # Cast stance via service (triggers events/emails, requires open poll)
  # Returns the event from StanceService.update
  def cast_stance(poll, user)
    stance = poll.stances.find_by(participant_id: user.id, latest: true)
    return unless stance
    event = StanceService.update(stance: stance, actor: user, params: cast_stance_params(poll))
    stance.reload
    event
  end

  # Save stance directly (no authorization check, for closed polls / display purposes)
  def save_cast_stance(poll, user)
    stance = poll.stances.find_by(participant_id: user.id, latest: true)
    return unless stance
    choice = poll.poll_options.limit(poll.minimum_stance_choices).map.with_index do |option, i|
      [option.name, fake_score(poll, i)]
    end.to_h
    stance.update!(choice: choice, cast_at: Time.current)
    stance
  end

  def find_email_for(user)
    ActionMailer::Base.deliveries
      .select { |e| Array(e.to).include?(user.email) }
      .last
  end

  def parse_email(email)
    return nil unless email
    Nokogiri::HTML(email.body.parts.last.decoded)
  end

  # Scenario builders

  def build_poll_created(poll_type:, anonymous: false, hide_results: :off)
    @poll = build_poll(poll_type: poll_type, anonymous: anonymous, hide_results: hide_results)
    PollService.create(poll: @poll, actor: @actor, params: {notify_recipients: true})
    @scenario_observer = @observer
    @scenario_actor = @actor
    @email = find_email_for(@observer)
    @parsed_body = parse_email(@email)
  end

  def build_poll_outcome_created(poll_type:, anonymous: false, hide_results: :off)
    @poll = build_poll(poll_type: poll_type, anonymous: anonymous, hide_results: hide_results,
                       closed_at: 1.day.ago, closing_at: 1.day.ago)
    PollService.create(poll: @poll, actor: @actor)
    save_cast_stance(@poll, @voter)
    @poll.update_counts!
    outcome = Outcome.new(poll: @poll, author: @actor, statement: "The outcome statement")
    OutcomeService.create(outcome: outcome, actor: @actor, params: {recipient_emails: [@observer.email]})
    @scenario_observer = @observer
    @scenario_actor = @actor
    @email = find_email_for(@observer)
    @parsed_body = parse_email(@email)
  end

  def build_poll_outcome_review_due(poll_type:, anonymous: false, hide_results: :off)
    @poll = build_poll(poll_type: poll_type, anonymous: anonymous, hide_results: hide_results,
                       closed_at: 1.day.ago, closing_at: 1.day.ago)
    PollService.create(poll: @poll, actor: @actor)
    save_cast_stance(@poll, @voter)
    @poll.update_counts!
    outcome = Outcome.new(poll: @poll, author: @actor, statement: "The outcome statement", review_on: Date.today)
    outcome.save!
    Events::OutcomeReviewDue.publish!(outcome)
    @scenario_observer = @actor
    @scenario_actor = @actor
    @email = find_email_for(@actor)
    @parsed_body = parse_email(@email)
  end

  def build_poll_stance_created(poll_type:, anonymous: false, hide_results: :off)
    @poll = build_poll(poll_type: poll_type, anonymous: anonymous, hide_results: hide_results)
    PollService.create(poll: @poll, actor: @actor)
    topic = @poll.topic
    TopicReader.find_or_create_by!(topic: topic, user: @actor).set_volume!('loud') if topic
    event = cast_stance(@poll, @voter)
    @scenario_observer = @actor
    # Use the event's user for actor (AnonymousUser for anonymous polls)
    @scenario_actor = event.is_a?(Event) ? event.user : @voter
    @email = find_email_for(@actor)
    @parsed_body = parse_email(@email)
  end

  def build_poll_closing_soon(poll_type:, anonymous: false, hide_results: :off, notify_on_closing_soon: 'voters')
    @poll = build_poll(poll_type: poll_type, anonymous: anonymous, hide_results: hide_results,
                       created_at: 6.days.ago,
                       closing_at: 1.day.from_now.beginning_of_hour,
                       quorum_pct: 80,
                       notify_on_closing_soon: notify_on_closing_soon)
    PollService.create(poll: @poll, actor: @actor)
    # Cast a stance while poll is open so we have voter data
    save_cast_stance(@poll, @voter)
    @poll.update_counts!
    PollService.publish_closing_soon
    observer = (notify_on_closing_soon == 'author') ? @actor : @observer
    @scenario_observer = observer
    @scenario_actor = @actor
    @email = find_email_for(observer)
    @parsed_body = parse_email(@email)
  end

  def build_poll_user_mentioned(poll_type:, anonymous: false, hide_results: :off)
    @poll = build_poll(poll_type: poll_type, anonymous: anonymous, hide_results: hide_results)
    PollService.create(poll: @poll, actor: @actor)
    # Clear deliveries so we only see emails from the mention, not poll_announced
    ActionMailer::Base.deliveries.clear
    stance = @poll.stances.find_by(participant_id: @voter.id, latest: true)
    params = cast_stance_params(@poll)
    params[:reason] = "<p><span class='mention' data-mention-id='#{@mentioned.username}'>@#{@mentioned.name}</span></p>"
    params[:reason_format] = "html"
    StanceService.update(stance: stance, actor: @voter, params: params)
    @scenario_observer = @mentioned
    @scenario_actor = @voter
    @email = find_email_for(@mentioned)
    @parsed_body = parse_email(@email)
  end

  def build_poll_expired_author(poll_type:, anonymous: false, hide_results: :off)
    @poll = build_poll(poll_type: poll_type, anonymous: anonymous, hide_results: hide_results)
    PollService.create(poll: @poll, actor: @actor)
    # Cast stances while poll is still open, then expire it
    save_cast_stance(@poll, @voter)
    save_cast_stance(@poll, @observer)
    @poll.update_counts!
    @poll.update_attribute(:closing_at, 1.day.ago)
    PollService.expire_lapsed_polls
    @scenario_observer = @actor
    @scenario_actor = @actor
    @email = find_email_for(@actor)
    @parsed_body = parse_email(@email)
  end

  # Assertions

  def i18n_params
    {group:      @group.name,
     discussion: @discussion.title,
     voter:      "",
     poll:       @poll.title,
     title:      @poll.title,
     actor:      @scenario_actor.name,
     poll_type:  I18n.t("poll_types.#{@poll.poll_type}")}
  end

  def assert_text(selector, val)
    html = @parsed_body.css(selector).to_s.downcase
    assert_includes html, val.downcase, "Expected '#{selector}' HTML to include '#{val}'"
  end

  def assert_element(selector)
    assert @parsed_body.css(selector).to_s.length > 0, "Expected element '#{selector}' to exist"
  end

  def assert_notification_headline(key)
    html = @parsed_body.css('.base-mailer__event-headline').to_s
    assert_includes html, I18n.t(key, **i18n_params), "Expected headline to include i18n key '#{key}'"
  end

  def assert_no_email_sent
    assert_nil @email, "Expected no email to be sent to observer"
  end

  public

  POLL_TYPES.each do |poll_type|
    test "#{poll_type} created email" do
      build_poll_created(poll_type: poll_type)
      assert_notification_headline("notifications.without_title.poll_announced")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "anonymous #{poll_type} created email" do
      skip "while refacting"
      build_poll_created(poll_type: poll_type, anonymous: true)
      assert_notification_headline("notifications.without_title.poll_announced")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', I18n.t("poll_common_action_panel.anonymous"))
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "#{poll_type} outcome_created email" do
      build_poll_outcome_created(poll_type: poll_type)
      assert_notification_headline("notifications.without_title.outcome_created")
      assert_text('.poll-mailer-common-summary', "Outcome")
      assert_text('.poll-mailer__results-chart', "Results")
      assert_text('.poll-mailer-common-responses', "Responses")
    end

    test "#{poll_type} outcome_review_due email" do
      build_poll_outcome_review_due(poll_type: poll_type)
      assert_notification_headline("notifications.without_title.outcome_review_due")
      assert_text('.poll-mailer-common-summary', "Outcome")
      assert_text('.poll-mailer__results-chart', "Results")
      assert_text('.poll-mailer-common-responses', "Responses")
    end

    test "anonymous #{poll_type} outcome_created email" do
      skip "while refacting"
      build_poll_outcome_created(poll_type: poll_type, anonymous: true)
      assert_notification_headline("notifications.without_title.outcome_created")
      assert_text('.poll-mailer-common-summary', "Outcome")
      assert_text('.poll-mailer__results-chart', "Results")
      assert_text('.poll-mailer-common-responses', I18n.t("poll_common_action_panel.anonymous"))
      assert_text('.poll-mailer-common-responses', "Responses")
      assert_text('.poll-mailer-common-responses', "Anonymous")
    end

    test "#{poll_type} stance_created email" do
      build_poll_stance_created(poll_type: poll_type)
      assert_notification_headline("notifications.without_title.stance_created")
      assert_element('.poll-mailer__stance')
    end

    test "anonymous #{poll_type} stance_created email" do
      skip "while refacting"
      build_poll_stance_created(poll_type: poll_type, anonymous: true)
      assert_notification_headline("notifications.without_title.stance_created")
      assert_text(".base-mailer__event-headline", "Anonymous")
      assert_element('.poll-mailer__stance')
    end

    test "results_hidden #{poll_type} stance_created email" do
      skip "while refacting"
      build_poll_stance_created(poll_type: poll_type, hide_results: 'until_closed')
      assert_notification_headline("notifications.without_title.stance_created")
      assert_element('.poll-mailer__stance')
    end

    test "#{poll_type} poll_closing_soon email" do
      build_poll_closing_soon(poll_type: poll_type)
      assert_notification_headline("notifications.without_title.poll_closing_soon")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "anonymous #{poll_type} poll_closing_soon email" do
      skip "while refacting"
      build_poll_closing_soon(poll_type: poll_type, anonymous: true)
      assert_notification_headline("notifications.without_title.poll_closing_soon")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "hide_results #{poll_type} poll_closing_soon email" do
      build_poll_closing_soon(poll_type: poll_type, hide_results: 'until_closed')
      assert_notification_headline("notifications.without_title.poll_closing_soon")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "#{poll_type} poll_closing_soon_author email" do
      skip "while refacting"
      build_poll_closing_soon(poll_type: poll_type, notify_on_closing_soon: 'author')
      assert_notification_headline("notifications.without_title.poll_closing_soon_author")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "#{poll_type} poll_user_mentioned_email" do
      build_poll_user_mentioned(poll_type: poll_type)
      assert_notification_headline("notifications.without_title.user_mentioned")
    end

    test "anonymous #{poll_type} poll_user_mentioned_email" do
      skip "while refacting"
      build_poll_user_mentioned(poll_type: poll_type, anonymous: true)
      assert_no_email_sent
    end

    test "hidden #{poll_type} poll_user_mentioned_email" do
      build_poll_user_mentioned(poll_type: poll_type, hide_results: 'until_closed')
      assert_no_email_sent
    end

    test "#{poll_type} poll_expired_author_email" do
      build_poll_expired_author(poll_type: poll_type)
      assert_notification_headline("notifications.without_title.poll_expired_author")
      assert_element('.poll-mailer__create_outcome')
      assert_element('.poll-mailer-common-summary')
      assert_element('.poll-mailer-common-responses')
      assert_text('.poll-mailer__results-chart', "Results")
    end

    test "anonymous #{poll_type} poll_expired_author_email" do
      skip "while refacting"
      build_poll_expired_author(poll_type: poll_type, anonymous: true)
      assert_notification_headline("notifications.without_title.poll_expired_author")
      assert_element('.poll-mailer__create_outcome')
      assert_element('.poll-mailer-common-summary')
      assert_element('.poll-mailer-common-responses')
      assert_text('.poll-mailer__results-chart', "Results")
      assert_text('.poll-mailer-common-responses', "Anonymous")
    end

    test "#{poll_type} compare view" do
      skip "while refacting"
      @poll = build_poll(poll_type: poll_type)
      PollService.create(poll: @poll, actor: @actor, params: {notify_recipients: true})

      event = @poll.events.last
      recipient = @observer

      event_key = EventMailer.event_key_for(event, recipient)
      subject_params = {
        title: @poll.title,
        poll_type: I18n.t("decision_tools_card.#{@poll.poll_type}_title"),
        actor: event.user.name,
        site_name: AppConfig.theme[:site_name]
      }
      email_subject = I18n.t("notifications.email_subject.#{event_key}", **subject_params)

      component = Views::Dev::Polls::Compare.new(
        email_subject: email_subject,
        print: Views::Polls::Export.new(poll: @poll, exporter: PollExporter.new(@poll), recipient: recipient),
        email: EventMailer.build_component(event: event, recipient: recipient),
        matrix: Views::Chatbot::Matrix::Poll.new(event: event, poll: @poll, recipient: recipient),
        markdown: Views::Chatbot::Markdown::Poll.new(event: event, poll: @poll, recipient: recipient),
        slack: Views::Chatbot::Slack::Poll.new(event: event, poll: @poll, recipient: recipient)
      )

      html = ApplicationController.renderer.render(component, layout: false)
      assert_includes html, "Format Comparison"
      assert_includes html, "compare-grid"
    end
  end
end
