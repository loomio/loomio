require "test_helper"

class DemoServiceTest < ActiveSupport::TestCase
  setup do
    @canonical_host = ENV["CANONICAL_HOST"]
    @loomio_disable_demo_groups = ENV["LOOMIO_DISABLE_DEMO_GROUPS"]
    @features_demo_groups_size = ENV["FEATURES_DEMO_GROUPS_SIZE"]
    ENV["CANONICAL_HOST"] = "loomio.eu"
    ENV.delete("LOOMIO_DISABLE_DEMO_GROUPS")
    ENV["FEATURES_DEMO_GROUPS_SIZE"] = "1"
    DemoService.reset_queue!
  end

  teardown do
    ENV["CANONICAL_HOST"] = @canonical_host
    ENV["LOOMIO_DISABLE_DEMO_GROUPS"] = @loomio_disable_demo_groups
    ENV["FEATURES_DEMO_GROUPS_SIZE"] = @features_demo_groups_size
    DemoService.reset_queue!
  end

  test "one source supplies multiple complete demo clones" do
    DemoService.refill_queue
    source = demo_source
    first = Group.find(DemoService.demo_group_ids.fetch(0))

    assert_equal "demo", source.subscription.plan
    assert_equal "demo", first.subscription.plan
    assert_equal source.id, first.info.dig("source_record_ids", "Group-#{first.id}")
    assert_equal 3, first.discussions.count
    assert_equal 6, first.polls.count
    assert_equal 5, first.comment_reactions.count
    assert_equal source.comments.count, first.comments.count
    assert_equal source.tags.order(:name).pluck(:name), first.tags.order(:name).pluck(:name)
    assert first.discussions.all? { |discussion| discussion.topic.max_depth == 3 }
    source.discussions.each do |discussion|
      copied = first.discussions.find_by!(title: discussion.title)
      assert_equal discussion.tags, copied.tags
      assert_equal discussion.topic.tags, copied.topic.tags
    end
    source.polls.each do |poll|
      copied = first.polls.find_by!(title: poll.title)
      assert_equal poll.tags, copied.tags
    end
    office = first.discussions.find_by!(title: "Is it time to move offices?")
    assert_equal [
      "Shall I come back with some options for a new office?",
      "Maximum budget for a new office?",
      "Move to The Orchard, Chalk Farm"
    ], office.topic.polls.order(:created_at).pluck(:title)

    DemoService.take_demo(users(:user))
    DemoService.refill_queue
    second = Group.find(DemoService.demo_group_ids.fetch(0))
    assert_equal source.id, second.info.dig("source_record_ids", "Group-#{second.id}")
    refute_equal first.id, second.id
    assert_equal source.id, demo_source.id
  end

  test "queued demo is claimed and recipient notifications are routed" do
    actor = users(:user)
    DemoService.refill_queue
    prepared_id = DemoService.demo_group_ids.fetch(0)
    unread_before = NotificationDelivery.where(recipient: actor, channel: "in_app", viewed_at: nil).count

    group = DemoService.take_demo(actor)

    assert_equal prepared_id, group.id
    assert_equal actor, group.creator
    assert_equal actor, group.subscription.owner
    assert group.admins.exists?(actor.id)
    refute group.info.fetch("demo_group_queued")
    assert_empty DemoService.demo_group_ids
    assert_equal unread_before + 3, NotificationDelivery.where(recipient: actor, channel: "in_app", viewed_at: nil).count
  end

  test "an empty queue creates a clone and routes its notifications" do
    actor = users(:user)
    unread_before = NotificationDelivery.where(recipient: actor, channel: "in_app", viewed_at: nil).count

    group = DemoService.take_demo(actor)

    assert_equal "demo", group.subscription.plan
    assert_equal demo_source.id, group.info.dig("source_record_ids", "Group-#{group.id}")
    assert_equal unread_before + 3, NotificationDelivery.where(recipient: actor, channel: "in_app", viewed_at: nil).count
  end

  test "expired demo cleanup keeps the source and removes old clones" do
    DemoService.refill_queue
    source = demo_source
    clone = Group.find(DemoService.demo_group_ids.fetch(0))
    source.update_columns(created_at: 8.days.ago)
    clone.update_columns(created_at: 8.days.ago)

    DemoService.destroy_expired_demo_groups

    assert Group.exists?(source.id)
    refute Group.exists?(clone.id)
  end

  test "hourly refills pretranslate each source locale once" do
    calls = []
    locales = AppConfig.locales.merge("supported" => %w[en de])

    AppConfig.stub(:locales, locales) do
      TranslationService.stub(:available?, true) do
        TranslationService.stub(:translate_group_content!, ->(group, locale, cache_only) { calls << [group.id, locale, cache_only] }) do
          2.times { DemoService.refill_queue }
        end
      end
    end

    assert_equal [[demo_source.id, "de", true]], calls
    assert_equal ["de"], demo_source.info.fetch("demo_group_locales")
  end

  test "refill discards queued demos from an older template" do
    DemoService.refill_queue
    old_clone = Group.find(DemoService.demo_group_ids.fetch(0))
    old_clone.update!(info: old_clone.info.except("demo_group_digest"))

    DemoService.refill_queue

    refute Group.exists?(old_clone.id)
    assert_equal 1, DemoService.demo_group_ids.length
    assert_equal demo_source.info.fetch("demo_group_digest"), Group.find(DemoService.demo_group_ids.fetch(0)).info.fetch("demo_group_digest")
  end

  test "a changed template replaces its source and queue" do
    DemoService.refill_queue
    old_source = demo_source
    old_clone_id = DemoService.demo_group_ids.fetch(0)
    old_source.update!(info: old_source.info.merge("demo_group_digest" => "obsolete"))
    old_clone = Group.find(old_clone_id)
    old_clone.update!(info: old_clone.info.merge("demo_group_digest" => "obsolete"))

    DemoService.refill_queue

    refute Group.exists?(old_source.id)
    refute Group.exists?(old_clone_id)
    assert_equal DemoGroupTemplateService.template_digest("mobile"), demo_source.info.fetch("demo_group_digest")
  end

  test "cached source translations are reused without translating clones" do
    actor = users(:user)
    actor.selected_locale = "de"
    DemoService.refill_queue
    source = demo_source
    source.update!(info: source.info.merge("demo_group_locales" => ["de"]))
    assert_equal "de", actor.locale
    assert DemoService.send(:source_locale_ready?, Group.find(DemoService.demo_group_ids.fetch(0)), "de")
    calls = 0
    fake_translation = ->(model:, to:) do
      calls += 1
      Translation.new(translatable: model, language: to, fields: model.class.translatable_fields.to_h { |field| [field.to_s, "Translated #{field} #{model.id}"] })
    end

    TranslationService.stub(:available?, true) do
      TranslationService.stub(:cached, fake_translation) do
        TranslationService.stub(:create, ->(**) { flunk("clone requested a new translation") }) do
          group = DemoService.take_demo(actor)
          assert_equal "Translated name #{source.id}", group.reload.name
          assert_operator calls, :>, 1
          start_tag = group.tags.find_by!(name: "Translated name #{source.tags.find_by!(name: 'Start here').id}")
          thread = group.discussions.find_by!(title: "Translated title #{source.discussions.find_by!(title: 'Should we try returnable bottles?').id}")
          assert_equal [start_tag.name], thread.topic.reload.tags
        end
      end
    end
  end

  test "missing translations leave the claimed demo in English" do
    actor = users(:user)
    actor.selected_locale = "de"
    DemoService.refill_queue
    source = demo_source
    source.update!(info: source.info.merge("demo_group_locales" => ["de"]))

    TranslationService.stub(:available?, true) do
      TranslationService.stub(:cached, nil) do
        group = DemoService.take_demo(actor)
        assert_equal "Oatmilk Cooperative", group.reload.name
      end
    end
  end

  private

  def demo_source
    Group.where("info @> ?", { demo_group_source: true }.to_json).last
  end
end
