require 'test_helper'
require 'timeout'

class RecordCountRepairServiceTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'repair restores every retained count including empty owners without changing content or timestamps' do
    group = groups(:group)
    user = users(:user)
    topic = topics(:discussion_topic)
    item = topic_items(:discussion_created_topic_item)
    discussion = topic.topicable
    comment = comments(:public_discussion_comment)
    outcome = Outcome.create!(poll: polls(:trial_cleanup_poll), author: users(:admin), statement: 'Repair outcome')
    empty = Group.create!(name: 'Empty count repair group', group_privacy: 'secret')
    [discussion, comment, outcome].each { |record| record.versions.create!(event: 'update') }
    owners = { 'groups' => group, 'users' => user, 'topics' => topic, 'topic_items' => item,
               'discussions' => discussion, 'comments' => comment, 'outcomes' => outcome }
    owners.each do |table, record|
      record.update_columns(RecordCountRepairService::COLUMNS.fetch(table).index_with { 999 })
    end
    empty.update_columns(memberships_count: 999, polls_count: 999, org_members_count: 999)
    group_timestamp = group.reload.updated_at
    comment_body = comment.body
    progress_transactions = []

    stats = RecordCountRepairService.run(batch_size: 2, pause_seconds: 0) do
      progress_transactions << ActiveRecord::Base.connection.transaction_open?
    end

    assert stats.values.all? { |result| result[:finished] && result[:deferred].zero? && result[:updated].positive? }
    assert_equal [false], progress_transactions.uniq
    group.reload
    assert_equal group.memberships.count, group.memberships_count
    assert_equal group.memberships.pending.count, group.pending_memberships_count
    assert_equal group.admin_memberships.count, group.admin_memberships_count
    assert_equal group.polls.count, group.polls_count
    assert_equal group.discussions.kept.count, group.discussions_count
    assert_equal group.poll_templates.kept.count, group.poll_templates_count
    assert_equal Membership.active.where(group_id: group.id_and_subgroup_ids).distinct.count(:user_id), group.org_members_count
    assert_equal user.memberships.count, user.reload.memberships_count
    assert_equal topic.polls.active.count, topic.reload.active_polls_count
    assert_equal topic.topic_readers.where.not(last_read_at: nil).count, topic.seen_by_count
    assert_equal item.children.count, item.reload.child_count
    [discussion, comment, outcome].each { |record| assert_equal record.versions.count, record.reload.versions_count }
    assert_equal [0, 0, 0], empty.reload.attributes.values_at('memberships_count', 'polls_count', 'org_members_count')
    assert_equal group_timestamp, group.updated_at
    assert_equal comment_body, comment.body
  end

  test 'audit reports drift without updating rows and a repeated repair does not rewrite correct rows' do
    user = users(:user)
    user.update_column(:memberships_count, 999)
    row_before = row_location(user)

    audit = RecordCountRepairService.run(tables: ['users'], batch_size: 2, pause_seconds: 0, dry_run: true).fetch('users')

    assert_equal 1, audit[:drifted]
    assert_equal 0, audit[:updated]
    assert_equal 999, user.reload.memberships_count
    assert_equal row_before, row_location(user)
    repair = RecordCountRepairService.run(tables: ['users'], pause_seconds: 0).fetch('users')
    assert_equal 1, repair[:updated]
    row_repaired = row_location(user)

    repeated = RecordCountRepairService.run(tables: ['users'], pause_seconds: 0).fetch('users')

    assert_equal 0, repeated[:updated]
    assert_equal row_repaired, row_location(user)
    assert_equal user.memberships.count, user.reload.memberships_count
  end

  test 'a limited pass resumes after its last owner without repairing earlier owners again' do
    users = User.order(:id).limit(3).to_a
    users.each { |user| user.update_column(:memberships_count, 999) }
    first = RecordCountRepairService.run(tables: ['users'], batch_size: 1, pause_seconds: 0, limit: 1).fetch('users')
    assert_equal 1, first[:checked]
    assert_equal users.first.id, first[:after_id]
    assert_not first[:finished]
    first_location = row_location(users.first)

    remaining = RecordCountRepairService.run(tables: ['users'], batch_size: 1, pause_seconds: 0,
                                            after_id: first[:after_id], limit: 2).fetch('users')

    assert_equal 2, remaining[:updated]
    assert_equal users.last.id, remaining[:after_id]
    assert_equal first_location, row_location(users.first)
    users.each { |user| assert_equal user.memberships.count, user.reload.memberships_count }
  end

  test 'an audit sees external changes even with the Rails query cache enabled' do
    user = users(:user)
    writer = independent_connection
    ActiveRecord::Base.cache do
      first = RecordCountRepairService.run(tables: ['users'], pause_seconds: 0, dry_run: true).fetch('users')
      assert_equal 0, first[:drifted]
      writer.exec("UPDATE users SET memberships_count = 999 WHERE id = #{user.id}")

      second = RecordCountRepairService.run(tables: ['users'], pause_seconds: 0, dry_run: true).fetch('users')

      assert_equal 1, second[:drifted]
      assert_equal 0, second[:updated]
    end
  ensure
    writer&.close
  end

  test 'busy owners are deferred while other owners can be repaired and the pass can be rerun' do
    user = users(:user)
    other = users(:alien)
    [user, other].each { |record| record.update_column(:memberships_count, 999) }
    writer = independent_connection
    writer.exec('BEGIN')
    writer.exec("SELECT id FROM users WHERE id = #{user.id} FOR NO KEY UPDATE")

    stats = Timeout.timeout(5) do
      RecordCountRepairService.run(tables: ['users'], pause_seconds: 0).fetch('users')
    end

    assert_equal 1, stats[:deferred]
    assert_equal 1, stats[:updated]
    assert_equal 999, user.reload.memberships_count
    assert_equal other.memberships.count, other.reload.memberships_count
    writer.exec('ROLLBACK')
    writer.close
    writer = nil
    repeated = RecordCountRepairService.run(tables: ['users'], pause_seconds: 0).fetch('users')
    assert_equal 0, repeated[:deferred]
    assert_equal 1, repeated[:updated]
    assert_equal user.memberships.count, user.reload.memberships_count
  ensure
    writer&.exec('ROLLBACK') unless writer&.finished?
    writer&.close
  end

  test 'a timed out batch rolls back its changes and does not leave the connection in a failed transaction' do
    user = users(:user)
    user.update_column(:memberships_count, 999)
    connection = ActiveRecord::Base.connection
    update = connection.method(:exec_update)
    connection.stub(:exec_update, ->(*args) { update.call(*args); raise ActiveRecord::QueryCanceled, 'repair timed out' }) do
      stats = RecordCountRepairService.run(tables: ['users'], pause_seconds: 0).fetch('users')
      assert_equal stats[:checked], stats[:deferred]
      assert_equal 0, stats[:updated]
    end
    assert_equal 999, user.reload.memberships_count
    assert_not connection.transaction_open?

    assert_equal 1, RecordCountRepairService.run(tables: ['users'], pause_seconds: 0).fetch('users')[:updated]
  end

  test 'an uncommitted membership followed by its count delta cannot be lost by a recount' do
    user = users(:alien)
    group = Group.create!(name: 'Concurrent count repair', group_privacy: 'secret')
    user.update_column(:memberships_count, 999)
    ready = Queue.new
    writer = nil
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
      next unless payload[:sql].include?("SELECT id FROM users WHERE id IN (#{user.id})")
      next unless payload[:sql].include?('FOR NO KEY UPDATE SKIP LOCKED')

      writer = Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          membership = Membership.new(group_id: group.id, user_id: user.id, accepted_at: Time.current)
          update_counts = membership.method(:update_membership_counts)
          membership.stub(:update_membership_counts, -> { ready << true; update_counts.call }) { membership.save! }
        end
      end
      Timeout.timeout(5) { ready.pop }
    end

    RecordCountRepairService.run(tables: ['users'], batch_size: 1, pause_seconds: 0)
    assert writer, 'Expected the membership write to start after its owner was locked'
    Timeout.timeout(5) { writer.value }

    assert_equal user.memberships.count, user.reload.memberships_count
    assert_equal 1, group.reload.memberships_count
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
    writer&.join(5)
  end

  test 'repair preserves group and direct access boundaries and anonymous read-receipt privacy' do
    polls_created = []
    actors = users(:member_normal, :guest_normal, :guest_admin_normal, :alien_loud,
                   :non_guest_loud, :former_guest_loud, :inactive_guest_loud, :admin) + [LoggedOutUser.new]
    [:discussion_topic, :direct_topic].each do |fixture|
      topic = topics(fixture)
      poll = PollService.create(
        params: { topic_id: topic.id, title: 'Count repair privacy', poll_type: 'proposal',
                  anonymous: true, closing_at: 3.days.from_now, poll_option_names: %w[Agree Disagree] },
        actor: topic.topicable.author
      )
      polls_created << poll
      reader = topic.topic_readers.find_by!(user_id: users(:guest_normal).id)
      reader.viewed!(1)
      reader_attributes = reader.reload.attributes
      access = actors.map { |actor| [actor.can?(:show, poll), actor.can?(:vote_in, poll)] }
      assert access.any? { |show, _| show }, fixture
      assert access.any? { |show, _| !show }, fixture
      assert_nil TopicReaderSerializer.new(reader).last_read_at
      topic.update_columns(active_polls_count: 999, seen_by_count: 999)

      RecordCountRepairService.run(pause_seconds: 0)

      assert_equal access, actors.map { |actor| [actor.can?(:show, poll.reload), actor.can?(:vote_in, poll)] }, fixture
      assert_equal reader_attributes, reader.reload.attributes, fixture
      assert_nil TopicReaderSerializer.new(reader).last_read_at
      assert_empty TopicReaderSerializer.new(reader).read_ranges
      assert topic.reload.has_anonymous_polls?
    end
  ensure
    # These polls commit; fixture reloads do not clear their anonymous voter records.
    polls_created.each(&:destroy!)
  end

  private

  def row_location(record)
    record.class.connection.select_value("SELECT ctid::text FROM #{record.class.table_name} WHERE id = #{record.id}")
  end

  def independent_connection
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    PG.connect(**config.slice(:host, :port, :password).merge(dbname: config[:database], user: config[:username]).compact)
  end
end
