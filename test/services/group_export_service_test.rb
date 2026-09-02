require 'test_helper'

class GroupExportServiceTest < ActiveSupport::TestCase
  test "notification recipient audiences remap embedded group ids" do
    migrate_ids = { "users" => {}, "groups" => { 42 => 84 } }

    %w[group delegates].each do |kind|
      attrs = {
        "recipient_user_ids" => [],
        "recipient_audience" => "#{kind}-42",
        "recipient_context" => {}
      }

      GroupExportService.translate_notification_payload!(attrs, migrate_ids)

      assert_equal "#{kind}-84", attrs["recipient_audience"]
    end
  end

  def create_detached_export_group
    admin = User.create!(
      email: "anonymous-export-admin-#{SecureRandom.hex(4)}@example.com",
      name: "Anonymous export admin",
      password: "password",
      email_verified: true
    )
    voter = User.create!(
      email: "anonymous-export-voter-#{SecureRandom.hex(4)}@example.com",
      name: "Anonymous export voter",
      password: "password",
      email_verified: true
    )
    group = Group.create!(name: "anonymous-export-#{SecureRandom.hex(4)}", creator: admin)
    group.add_admin!(admin)
    group.add_member!(voter)

    [group, admin, voter]
  end

  def create_detached_export_poll(group:, admin:, voter:, title:, topic_id: nil, close: true)
    params = {
      title: title,
      poll_type: "proposal",
      anonymous: true,
      closing_at: 1.day.from_now,
      notify_on_open: false,
      specified_voters_only: topic_id.present?,
      poll_option_names: %w[Agree Disagree]
    }
    params[topic_id ? :topic_id : :group_id] = topic_id || group.id
    poll = PollService.create(params: params, actor: admin)
    if topic_id
      PollService.invite(
        poll: poll,
        actor: admin,
        params: {recipient_user_ids: [voter.id]}
      )
    end

    ballot = poll.anonymous_ballots.build(
      anonymous_ballot_choices_attributes: [
        {poll_option_id: poll.poll_options.find_by!(name: "Agree").id}
      ]
    )
    AnonymousBallotService.create(anonymous_ballot: ballot, actor: voter)
    if close
      PollService.close(poll: poll, actor: admin)
      LegacyAnonymousVoteReason.create!(anonymous_ballot: ballot, body: "A plain text legacy reason")
    end

    [poll, ballot]
  end

  def create_scenario
    admin = User.create!(email: "exportadmin#{SecureRandom.hex(4)}@example.com", name: 'admin', password: 'password', email_verified: true)
    member = User.create!(email: "exportmember#{SecureRandom.hex(4)}@example.com", name: 'member', password: 'password')
    alien = User.create!(email: "exportother#{SecureRandom.hex(4)}@example.com", name: 'alien', password: 'password')

    group = Group.create!(name: "exportgroup#{SecureRandom.hex(4)}", creator_id: admin.id)
    subgroup = Group.create!(name: "exportsubgroup#{SecureRandom.hex(4)}", creator_id: admin.id, parent_id: group.id)
    another_group = Group.create!(name: "exportanothergroup#{SecureRandom.hex(4)}", creator_id: alien.id)

    group.add_admin!(admin)
    group.add_member!(member)
    subgroup.add_admin!(admin)
    subgroup.add_member!(member)
    another_group.add_admin!(alien)

    discussion_template = DiscussionTemplate.create!(title: 'discussion_template', group: group, process_name: 'process_name', process_subtitle: 'process_subtitle', author: admin)
    poll_template = PollTemplate.create!(title: 'poll_template', group: group, process_name: 'process_name', process_subtitle: 'process_subtitle', poll_type: 'proposal', author: admin)

    tag = Tag.create!(name: "exptag#{SecureRandom.hex(4)}", group: group, color: '#abcdef')

    discussion = DiscussionService.create(params: { title: "export_discussion#{SecureRandom.hex(4)}", group_id: group.id, discussion_template_id: discussion_template.id, tags: [tag.name] }, actor: admin)
    sub_discussion = DiscussionService.create(params: { title: "export_sub_discussion#{SecureRandom.hex(4)}", group_id: subgroup.id }, actor: admin)

    comment = Comment.new(parent: discussion, body: 'export_comment')
    CommentService.create(comment: comment, actor: admin)
    sub_comment = Comment.new(parent: sub_discussion, body: 'export_sub_comment')
    CommentService.create(comment: sub_comment, actor: admin)

    poll = PollService.create(params: { title: "export_poll#{SecureRandom.hex(4)}", group_id: group.id, poll_type: 'proposal', closing_at: 1.day.from_now, poll_option_names: %w[Agree Disagree], poll_template_id: poll_template.id }, actor: admin)
    sub_poll = PollService.create(params: { title: "export_sub_poll#{SecureRandom.hex(4)}", group_id: subgroup.id, poll_type: 'proposal', closing_at: 1.day.from_now, poll_option_names: %w[Agree Disagree] }, actor: admin)
    topic_poll = PollService.create(params: { title: "topic_poll#{SecureRandom.hex(4)}", topic_id: discussion.topic_id, poll_type: 'proposal', closing_at: 1.day.from_now, poll_option_names: %w[Agree Disagree] }, actor: admin)

    # PollService.create already created poll options and stances for group members
    # Cast stances for the main poll
    admin_stance = poll.stances.find_by(participant_id: admin.id, latest: true)
    admin_stance.update!(choice: 'Agree', cast_at: Time.current)
    member_stance = poll.stances.find_by(participant_id: member.id, latest: true)
    member_stance.update!(choice: 'Disagree', cast_at: Time.current)
    admin_topic_stance = topic_poll.stances.find_by(participant_id: admin.id, latest: true)
    admin_topic_stance.update!(choice: 'Agree', cast_at: Time.current)

    topic_stance_comment = Comment.new(parent: admin_topic_stance, body: 'topic stance comment')
    CommentService.create(comment: topic_stance_comment, actor: admin)

    poll.update_counts!
    sub_poll.update_counts!

    PollService.close(poll: poll, actor: admin)
    PollService.close(poll: sub_poll, actor: admin)
    PollService.close(poll: topic_poll, actor: admin)

    # Services already created topic_items and topic readers
    discussion_event = discussion.created_topic_item

    Reaction.create!(reactable: discussion, user: member)
    Reaction.create!(reactable: poll, user: member)
    Reaction.create!(reactable: comment, user: member)

    {
      admin: admin, member: member, alien: alien,
      group: group, subgroup: subgroup, another_group: another_group,
      discussion: discussion, sub_discussion: sub_discussion,
      comment: comment, poll: poll, sub_poll: sub_poll, topic_poll: topic_poll, topic_stance_comment: topic_stance_comment,
      tag: tag, discussion_template: discussion_template, poll_template: poll_template
    }
  end

  test "group export excludes user credentials" do
    group, admin, member = create_detached_export_group

    filename = GroupExportService.export(group.all_groups, group.name)
    archive = File.readlines(filename, chomp: true).map { |line| JSON.parse(line) }
    exported_users = archive.select { |item| item['table'] == 'users' }.index_by { |item| item.dig('record', 'id') }

    [admin, member].each do |user|
      record = exported_users.fetch(user.id).fetch('record')

      assert_equal user.email, record['email']
      assert_equal user.name, record['name']
      %w[api_key email_api_key password_digest secret_token unsubscribe_token].each do |credential|
        assert_not record.key?(credential), "expected #{credential} to be excluded"
      end
    end
  end

  test "group export and import preserve detached anonymous polls with fresh ballot ids" do
    group, admin, voter = create_detached_export_group
    poll, ballot = create_detached_export_poll(
      group: group,
      admin: admin,
      voter: voter,
      title: "Detached anonymous group export"
    )

    filename = GroupExportService.export(group.all_groups, group.name)
    archive = File.readlines(filename, chomp: true).map { |line| JSON.parse(line) }
    archived_ballot = archive.find { |item| item["table"] == "anonymous_ballots" }.fetch("record")
    archived_choice = archive.find { |item| item["table"] == "anonymous_ballot_choices" }.fetch("record")
    archived_reason = archive.find { |item| item["table"] == "legacy_anonymous_vote_reasons" }.fetch("record")
    archived_voters = archive.select { |item| item["table"] == "anonymous_poll_voters" }.map { |item| item.fetch("record") }

    refute_equal ballot.id, archived_ballot.fetch("id")
    assert_equal archived_ballot.fetch("id"), archived_choice.fetch("anonymous_ballot_id")
    assert_equal archived_ballot.fetch("id"), archived_reason.fetch("anonymous_ballot_id")
    assert_equal 2, archived_voters.length
    assert archived_voters.none? { |record| record.key?("anonymous_ballot_id") }

    second_filename = GroupExportService.export(group.all_groups, group.name)
    second_archive = File.readlines(second_filename, chomp: true).map { |line| JSON.parse(line) }
    second_archived_ballot = second_archive.find { |item| item["table"] == "anonymous_ballots" }.fetch("record")
    refute_equal archived_ballot.fetch("id"), second_archived_ballot.fetch("id")

    subscriber = voter
    TopicReader.for(user: subscriber, topic: poll.topic).set_volume!(email: :loud, push: :quiet)
    notification = NotificationService.create!(
      kind: "poll_announced",
      subject: poll,
      actor: admin,
      recipient_user_ids: [ subscriber.id ]
    )
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal [ subscriber.id ], notification.notification_deliveries
                                                .where(channel: "email", recipient_type: "User")
                                                .pluck(:recipient_id)
    filename = GroupExportService.export(group.all_groups, group.name)
    delivery_archive = File.readlines(filename, chomp: true).map { |line| JSON.parse(line) }
    assert delivery_archive.any? { |item| item["table"] == "notification_deliveries" && item.dig("record", "notification_id") == notification.id }

    GroupExportService.import(filename, reset_keys: true)

    imported_poll = Poll.where(title: poll.title).where.not(id: poll.id).order(:id).last!
    imported_ballot = imported_poll.anonymous_ballots.sole
    refute_equal ballot.id, imported_ballot.id
    refute_equal archived_ballot.fetch("id"), imported_ballot.id
    assert_equal [["Agree", 1]], imported_ballot.anonymous_ballot_choices.includes(:poll_option).map { |choice| [choice.poll_option.name, choice.score] }
    assert_equal "A plain text legacy reason", imported_ballot.legacy_anonymous_vote_reason.body
    assert_equal(
      {admin.email => false, voter.email => true},
      imported_poll.anonymous_poll_voters.includes(:voter).to_h { |record| [record.voter.email, record.ballot_submitted?] }
    )
    assert_empty imported_poll.stances

    imported_notification = Notification.about(imported_poll).find_by!(kind: "poll_announced")
    imported_recipient_ids = imported_notification.notification_deliveries
                                                    .where(channel: "email", recipient_type: "User")
                                                    .pluck(:recipient_id)
    assert_equal [ User.find_by!(email: subscriber.email).id ], imported_recipient_ids
  end

  test "group export excludes active detached anonymous polls and their records" do
    group, admin, voter = create_detached_export_group
    poll, ballot = create_detached_export_poll(
      group: group,
      admin: admin,
      voter: voter,
      title: "Active detached anonymous export",
      close: false
    )

    filename = GroupExportService.export(group.all_groups, group.name)
    archive = File.readlines(filename, chomp: true).map { |line| JSON.parse(line) }

    refute_includes archive.select { |item| item["table"] == "polls" }.map { |item| item.dig("record", "id") }, poll.id
    refute_includes File.read(filename), ballot.id
    assert_empty archive.select { |item| %w[anonymous_ballots anonymous_ballot_choices anonymous_poll_voters legacy_anonymous_vote_reasons].include?(item["table"]) }
  end

  test "direct-topic export and import preserve detached anonymous records" do
    group, admin, voter = create_detached_export_group
    discussion = DiscussionService.create(
      params: {title: "Direct export discussion", group_id: group.id},
      actor: admin
    )
    discussion.topic.update!(group_id: nil)
    TopicReader.for(user: admin, topic: discussion.topic).update!(admin: true, guest: true)
    poll, ballot = create_detached_export_poll(
      group: group,
      admin: admin,
      voter: voter,
      topic_id: discussion.topic_id,
      title: "Detached anonymous direct export"
    )

    filename = GroupExportService.export_direct_topics(group.id)
    archive = File.readlines(filename, chomp: true).map { |line| JSON.parse(line) }
    tables = archive.pluck("table")
    assert_includes tables, "anonymous_ballots"
    assert_includes tables, "anonymous_ballot_choices"
    assert_includes tables, "anonymous_poll_voters"
    assert_includes tables, "legacy_anonymous_vote_reasons"

    GroupExportService.import(filename, reset_keys: true)

    imported_poll = Poll.where(title: poll.title).where.not(id: poll.id).order(:id).last!
    imported_ballot = imported_poll.anonymous_ballots.sole
    refute_equal ballot.id, imported_ballot.id
    assert_equal ["Agree"], imported_ballot.poll_options.pluck(:name)
    assert_equal "A plain text legacy reason", imported_ballot.legacy_anonymous_vote_reason.body
    assert imported_poll.anonymous_poll_voters.find_by!(voter: voter).ballot_submitted?
  end

  test "import reuses an existing redacted user with the same key" do
    user = User.create!(
      email: "redacted-export-#{SecureRandom.hex(4)}@example.com",
      name: 'Redacted export user'
    )
    group = Group.create!(name: "Redacted user import group #{SecureRandom.hex(4)}")
    user.update_columns(
      email: nil,
      name: nil,
      username: nil,
      deactivated_at: Time.current
    )
    membership = Membership.new(
      id: Membership.maximum(:id).to_i + 10_000,
      user: user,
      group: group,
      accepted_at: Time.current
    )

    Tempfile.create(['redacted-user-export', '.json']) do |file|
      file.puts({ table: 'users', record: GroupExportService.export_record(user, 'users') }.to_json)
      file.puts({ table: 'memberships', record: membership.attributes }.to_json)
      file.flush

      assert_no_difference('User.count') do
        assert_difference('Membership.count', 1) do
          GroupExportService.import(file.path)
        end
      end
    end

    assert_equal user.id, User.find_by!(key: user.key).id
    assert Membership.find_by!(user: user, group: group)
  end

  test "export, truncate specific records, and import recreates the scenario" do
    data = create_scenario
    group = data[:group]
    admin = data[:admin]
    member = data[:member]

    filename = GroupExportService.export(group.all_groups, group.name)

    # Delete just the records we created (not all tables, to preserve fixtures)
    group_ids = group.all_groups.pluck(:id)
    admin_id = admin.id
    member_id = member.id
    alien_id = data[:alien].id

    # Clean up in reverse dependency order
    # Polls and discussions are now found via topics.group_id
    group_poll_ids = Poll.joins(:topic).where(topics: { group_id: group_ids }).pluck(:id)
    group_discussion_ids = Discussion.joins(:topic).where(topics: { group_id: group_ids }).pluck(:id)

    group_topic_ids = Topic.where(group_id: group_ids).pluck(:id)
    comment_ids = TopicItem.where(topic_id: group_topic_ids, itemable_type: 'Comment').pluck(:itemable_id)

    StanceReceipt.where(poll_id: group_poll_ids).delete_all
    Reaction.where(user_id: [admin_id, member_id]).delete_all
    NotificationDelivery.where(
      recipient_type: "User",
      recipient_id: [ admin_id, member_id ]
    ).delete_all
    TopicItem.where(topic_id: group_topic_ids).delete_all
    TopicReader.where(topic_id: group_topic_ids).delete_all
    StanceChoice.where(stance: Stance.where(poll_id: group_poll_ids)).delete_all
    Stance.where(poll_id: group_poll_ids).delete_all
    PollOption.where(poll_id: group_poll_ids).delete_all
    Outcome.where(poll_id: group_poll_ids).delete_all
    Poll.where(id: group_poll_ids).delete_all
    Comment.where(id: comment_ids).delete_all
    Topic.where(id: group_topic_ids).delete_all
    Discussion.where(id: group_discussion_ids).delete_all
    DiscussionTemplate.where(group_id: group_ids).delete_all
    PollTemplate.where(group_id: group_ids).delete_all
    Tag.where(group_id: group_ids).delete_all
    Membership.where(group_id: group_ids).delete_all
    Membership.where(group_id: data[:another_group].id).delete_all
    Group.where(id: data[:another_group].id).delete_all
    Group.where(id: group_ids).delete_all
    Identity.where(user_id: [admin_id, member_id, alien_id]).delete_all
    Session.where(user_id: [admin_id, member_id, alien_id]).delete_all
    User.where(id: [admin_id, member_id, alien_id]).delete_all

    GroupExportService.import(filename)

    # Verify import recreated the data
    imported_admin = User.find_by!(email: admin.email)
    imported_member = User.find_by!(email: member.email)
    assert_nil User.find_by(email: data[:alien].email), "alien should not be imported"

    imported_group = Group.find_by!(name: group.name)
    imported_subgroup = Group.find_by!(name: data[:subgroup].name)
    assert_nil Group.find_by(name: data[:another_group].name), "another_group should not be imported"

    # Memberships
    assert Membership.find_by(user: imported_admin, group: imported_group, admin: true)
    assert Membership.find_by(user: imported_admin, group: imported_subgroup, admin: true)
    assert Membership.find_by(user: imported_member, group: imported_group, admin: false)
    assert Membership.find_by(user: imported_member, group: imported_subgroup, admin: false)

    # Discussions (group_id is on topics, not discussions)
    imported_discussion = imported_group.discussions.find_by!(title: data[:discussion].title, author: imported_admin)
    imported_sub_discussion = imported_subgroup.discussions.find_by!(title: data[:sub_discussion].title, author: imported_admin)

    # Topics — 1 discussion + 1 standalone poll per group
    assert_equal 2, Topic.where(group_id: imported_group.id).count
    assert_equal 2, Topic.where(group_id: imported_subgroup.id).count

    assert imported_discussion.topic.persisted?
    assert_equal imported_group.id, imported_discussion.topic.group_id
    assert_equal 'Discussion', imported_discussion.topic.topicable_type
    assert_equal imported_discussion.id, imported_discussion.topic.topicable_id

    assert imported_sub_discussion.topic.persisted?
    assert_equal imported_subgroup.id, imported_sub_discussion.topic.group_id
    assert_equal 'Discussion', imported_sub_discussion.topic.topicable_type
    assert_equal imported_sub_discussion.id, imported_sub_discussion.topic.topicable_id

    assert_equal 1, imported_discussion.topic.tags.count
    assert_equal data[:tag].name, imported_discussion.topic.tags.first

    Tag.find_by!(name: data[:tag].name, group: imported_group, color: '#abcdef')

    # Comments
    imported_comment = imported_discussion.comments.find_by!(user: imported_admin, body: 'export_comment')

    # Polls and stances (group_id is on topics, not polls)
    imported_poll = imported_group.polls.find_by!(title: data[:poll].title, author: imported_admin)
    imported_sub_poll = imported_subgroup.polls.find_by!(title: data[:sub_poll].title, author: imported_admin)
    imported_topic_poll = imported_group.polls.find_by!(title: data[:topic_poll].title, author: imported_admin)

    imported_topic_stance_comment = imported_group.comments.find_by!(body: "topic stance comment")
    assert_equal imported_topic_stance_comment.parent.poll.id, imported_topic_poll.id

    # Poll topics
    assert imported_poll.topic.persisted?
    assert_equal imported_group.id, imported_poll.topic.group_id
    assert_equal 'Poll', imported_poll.topic.topicable_type
    assert_equal imported_poll.id, imported_poll.topic.topicable_id

    assert imported_sub_poll.topic.persisted?
    assert_equal imported_subgroup.id, imported_sub_poll.topic.group_id

    imported_poll.update_counts!
    imported_sub_poll.update_counts!

    assert_equal [1, 1], imported_poll.stance_counts
    assert_equal [0, 0], imported_sub_poll.stance_counts

    # Templates
    DiscussionTemplate.find_by!(title: 'discussion_template', group: imported_group, author: imported_admin)
    PollTemplate.find_by!(title: 'poll_template', group: imported_group, author: imported_admin)

    # Reactions
    Reaction.find_by!(reactable: imported_discussion, user: imported_member)
    Reaction.find_by!(reactable: imported_poll, user: imported_member)
  end
end
