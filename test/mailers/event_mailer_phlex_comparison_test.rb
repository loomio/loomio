# frozen_string_literal: true

require 'test_helper'

class EventMailerPhlexComparisonTest < ActionMailer::TestCase
  include Dev::FakeDataHelper
  include Dev::ScenariosHelper
  include Dev::NintiesMoviesHelper

  setup do
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"
  end

  teardown do
    EventMailer.use_phlex = true
  end

  # --- Poll scenarios (all poll types) ---

  %w[proposal poll dot_vote score count meeting ranked_choice].each do |poll_type|
    test "poll_created #{poll_type} comparison" do
      compare_poll_scenario(:poll_created, poll_type: poll_type)
    end

    test "poll_stance_created #{poll_type} comparison" do
      compare_poll_scenario(:poll_stance_created, poll_type: poll_type)
    end

    test "poll_closing_soon #{poll_type} comparison" do
      compare_poll_scenario(:poll_closing_soon, poll_type: poll_type)
    end

    test "poll_closing_soon_author #{poll_type} comparison" do
      compare_poll_scenario(:poll_closing_soon_author, poll_type: poll_type)
    end

    test "poll_expired_author #{poll_type} comparison" do
      compare_poll_scenario(:poll_expired_author, poll_type: poll_type)
    end

    test "poll_outcome_created #{poll_type} comparison" do
      compare_poll_scenario(:poll_outcome_created, poll_type: poll_type)
    end

    test "poll_outcome_review_due #{poll_type} comparison" do
      compare_poll_scenario(:poll_outcome_review_due, poll_type: poll_type)
    end
  end

  # --- Discussion scenarios ---

  test "discussion_created comparison" do
    compare_discussion_scenario(:discussion_created)
  end

  test "discussion_announced comparison" do
    compare_discussion_scenario(:discussion_announced)
  end

  test "new_comment comparison" do
    compare_discussion_scenario(:new_comment)
  end

  test "comment_replied_to comparison" do
    compare_discussion_scenario(:comment_replied_to)
  end

  private

  def cleanup_tables
    tables = %w[
      stance_receipts omniauth_identities users groups memberships polls outcomes
      events discussions stances stance_choices poll_options tasks
      discussion_readers discussion_templates poll_templates notifications comments
    ]
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{tables.join(', ')} CASCADE")
    CACHE_REDIS_POOL.with { |client| client.flushall }
    ActionMailer::Base.deliveries = []
  end

  def compare_poll_scenario(scenario_name, poll_type:)
    cleanup_tables

    # Run scenario (sends emails via current mode - Phlex by default)
    EventMailer.use_phlex = true
    scenario = send(:"#{scenario_name}_scenario", {
      poll_type: poll_type,
      anonymous: false,
      hide_results: :off,
      admin: false,
      guest: false,
      standalone: false,
      wip: false
    })

    observer = scenario[:observer]
    phlex_email = find_email_to(observer)

    unless phlex_email
      # Some scenarios don't send email to observer (e.g. poll_user_mentioned anonymous)
      skip "No Phlex email delivered to observer for #{scenario_name}/#{poll_type}"
    end

    # Find the event that generated this email
    event = find_event_for_observer(observer, scenario)

    unless event
      skip "Could not find event for observer in #{scenario_name}/#{poll_type}"
    end

    # Re-send with HAML
    ActionMailer::Base.deliveries = []
    EventMailer.use_phlex = false
    EventMailer.event(observer.id, event.id).deliver_now
    haml_email = ActionMailer::Base.deliveries.last

    unless haml_email
      skip "No HAML email delivered for #{scenario_name}/#{poll_type}"
    end

    compare_emails(haml_email, phlex_email, "#{scenario_name}/#{poll_type}")
  end

  def compare_discussion_scenario(scenario_name)
    cleanup_tables

    # Set up discussion scenarios using the ninties movies helper pattern
    case scenario_name
    when :discussion_created
      group = Group.create!(name: "Girdy Dancing Shoes", creator: patrick)
      group.add_admin! patrick
      group.add_member! jennifer
      discussion = Discussion.new(
        title: "Let's go to the moon!",
        description: "A description for this discussion. Should this be rich?",
        group: group,
        author: patrick
      )
      DiscussionService.create(discussion: discussion, actor: patrick, params: { recipient_user_ids: [jennifer.id] })
      observer = jennifer
      event_kind = 'new_discussion'

    when :discussion_announced
      group = Group.create!(name: "Girdy Dancing Shoes", creator: patrick)
      group.add_admin! patrick
      group.add_member! jennifer
      discussion = Discussion.new(
        title: "Let's go to the moon!",
        description: "A description for this discussion. Should this be rich?",
        group: group,
        author: patrick
      )
      DiscussionService.create(discussion: discussion, actor: patrick)
      DiscussionService.invite(discussion: discussion, actor: patrick, params: { recipient_user_ids: [jennifer.id] })
      observer = jennifer
      event_kind = 'discussion_announced'

    when :new_comment
      group = Group.create!(name: 'Dirty Dancing Shoes')
      group.add_admin!(patrick).set_volume!(:loud)
      group.add_member! jennifer
      discussion = Discussion.new(
        title: 'What star sign are you?',
        group: group,
        description: "Wow, what a __great__ day.",
        author: jennifer
      )
      DiscussionService.create(discussion: discussion, actor: discussion.author)
      comment = Comment.new(author: jennifer, body: "hello _patrick_.", discussion: discussion)
      CommentService.create(comment: comment, actor: jennifer)
      observer = patrick
      event_kind = 'new_comment'

    when :comment_replied_to
      group = Group.create!(name: 'Dirty Dancing Shoes')
      group.add_admin!(patrick)
      group.add_member! jennifer
      discussion = Discussion.new(
        title: 'What star sign are you?',
        group: group,
        description: "Wow, what a __great__ day.",
        author: jennifer
      )
      DiscussionService.create(discussion: discussion, actor: discussion.author)
      comment = Comment.new(body: "hello _patrick.", discussion: discussion)
      CommentService.create(comment: comment, actor: jennifer)
      reply_comment = Comment.new(body: "why, hello there @#{jennifer.username}", parent: comment, discussion: discussion)
      CommentService.create(comment: reply_comment, actor: patrick)
      observer = jennifer
      event_kind = 'user_mentioned'
    end

    # Phlex email was sent during scenario setup
    phlex_email = find_email_to(observer)
    unless phlex_email
      skip "No Phlex email delivered for discussion/#{scenario_name}"
    end

    event = find_event_for_observer(observer, nil, event_kind)
    unless event
      skip "Could not find event for discussion/#{scenario_name}"
    end

    # Re-send with HAML
    ActionMailer::Base.deliveries = []
    EventMailer.use_phlex = false
    EventMailer.event(observer.id, event.id).deliver_now
    haml_email = ActionMailer::Base.deliveries.last

    unless haml_email
      skip "No HAML email delivered for discussion/#{scenario_name}"
    end

    compare_emails(haml_email, phlex_email, "discussion/#{scenario_name}")
  end

  def find_email_to(user)
    ActionMailer::Base.deliveries.select { |e| Array(e.to).include?(user.email) }.last
  end

  def find_event_for_observer(observer, scenario = nil, event_kind = nil)
    # Try via notification first
    notification = Notification.where(user_id: observer.id).order(id: :desc).first
    return notification.event if notification

    # Fallback: find event by kind and eventable
    if event_kind
      Event.where(kind: event_kind).order(id: :desc).first
    elsif scenario
      eventable = scenario[:outcome] || scenario[:stance] || scenario[:poll]
      Event.where(eventable: eventable).order(id: :desc).first
    end
  end

  def email_body(email)
    if email.body.parts.any?
      email.body.parts.last.decoded
    else
      email.body.decoded
    end
  end

  def compare_emails(haml_email, phlex_email, label)
    haml_doc = Nokogiri::HTML.fragment(email_body(haml_email))
    phlex_doc = Nokogiri::HTML.fragment(email_body(phlex_email))

    # Compare key structural selectors
    compare_selectors(haml_doc, phlex_doc, label, [
      '.base-mailer__event-headline',
      '.poll-mailer-common-summary',
      '.poll-mailer__vote',
      '.poll-mailer__results-chart',
      '.poll-mailer-common-responses',
      '.poll-mailer__stance',
      '.poll-mailer__create_outcome',
      '.thread-mailer__body',
      '.thread-mailer__footer',
      '.thread-mailer__footer-links',
      '.reply-or-view-online',
      '.notification-reason',
      '.unsubscribe-link',
      '.thread-mailer__footer-logo',
      '.base-mailer__button',
    ])

    # Compare text content of key elements
    compare_text_content(haml_doc, phlex_doc, label, [
      '.base-mailer__event-headline',
      '.poll-mailer-common-summary',
      '.notification-reason',
    ])
  end

  def compare_selectors(haml_doc, phlex_doc, label, selectors)
    selectors.each do |selector|
      haml_present = haml_doc.css(selector).any?
      phlex_present = phlex_doc.css(selector).any?

      if haml_present != phlex_present
        flunk "[#{label}] Selector '#{selector}': HAML=#{haml_present}, Phlex=#{phlex_present}"
      end
    end
  end

  def compare_text_content(haml_doc, phlex_doc, label, selectors)
    selectors.each do |selector|
      haml_text = normalize_text(haml_doc.css(selector).text)
      phlex_text = normalize_text(phlex_doc.css(selector).text)

      next if haml_text.empty? && phlex_text.empty?

      assert_equal haml_text, phlex_text,
        "[#{label}] Text content mismatch for '#{selector}'"
    end
  end

  def normalize_text(text)
    text.gsub(/\s+/, ' ').strip
  end
end
