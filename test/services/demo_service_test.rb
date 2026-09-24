require "test_helper"

class DemoServiceTest < ActiveSupport::TestCase
  setup do
    @canonical_host = ENV["CANONICAL_HOST"]
    @loomio_disable_demo_groups = ENV["LOOMIO_DISABLE_DEMO_GROUPS"]
    @features_demo_groups_size = ENV["FEATURES_DEMO_GROUPS_SIZE"]
    ENV["CANONICAL_HOST"] = "loomio.eu"
    ENV.delete("LOOMIO_DISABLE_DEMO_GROUPS")
    DemoService.reset_queue!
  end

  teardown do
    ENV["CANONICAL_HOST"] = @canonical_host
    ENV["LOOMIO_DISABLE_DEMO_GROUPS"] = @loomio_disable_demo_groups
    ENV["FEATURES_DEMO_GROUPS_SIZE"] = @features_demo_groups_size
    DemoService.reset_queue!
  end

  test "taking a demo provisions the code-backed mobile template" do
    actor = users(:user)
    group = groups(:group)
    captured = nil
    provision = lambda do |**args|
      captured = args
      DemoGroupTemplateService::Result.new(group: group, discussions: {}, polls: {}, notifications: [])
    end

    DemoGroupTemplateService.stub(:create!, provision) do
      assert_equal group, DemoService.take_demo(actor)
    end

    assert_equal({ template_key: "mobile", user: actor }, captured)
  end

  test "taking a demo succeeds in English when translation capacity is exhausted" do
    actor = users(:user)
    actor.selected_locale = "es"
    group = groups(:group)
    provision = lambda do |**|
      DemoGroupTemplateService::Result.new(group: group, discussions: {}, polls: {}, notifications: [])
    end

    english_name = group.name
    DemoGroupTemplateService.stub(:create!, provision) do
      TranslationService.stub(:available?, true) do
        TranslationService.stub(:translate_group_content!, ->(*) { group.update_columns(name: "Nombre traducido"); raise TranslationService::LimitReached, "limit reached" }) do
          assert_equal group, DemoService.take_demo(actor)
        end
      end
    end

    assert_equal english_name, group.reload.name
  end

  test "taking a demo translates for the requesting user when translation is available" do
    actor = users(:user)
    actor.selected_locale = "de"
    group = groups(:group)
    provision = lambda do |**|
      DemoGroupTemplateService::Result.new(group: group, discussions: {}, polls: {}, notifications: [])
    end
    translated_locale = nil

    DemoGroupTemplateService.stub(:create!, provision) do
      TranslationService.stub(:available?, true) do
        TranslationService.stub(:translate_group_content!, ->(_group, locale) { translated_locale = locale }) do
          DemoService.take_demo(actor)
        end
      end
    end

    assert_equal "de", translated_locale
  end

  test "taking a demo leaves all content in English when translation is unavailable" do
    actor = users(:user)
    actor.selected_locale = "de"
    group = groups(:group)
    provision = lambda do |**|
      DemoGroupTemplateService::Result.new(group: group, discussions: {}, polls: {}, notifications: [])
    end

    DemoGroupTemplateService.stub(:create!, provision) do
      TranslationService.stub(:available?, false) do
        TranslationService.stub(:translate_group_content!, ->(*) { flunk("translation must not start") }) do
          assert_equal group, DemoService.take_demo(actor)
        end
      end
    end
  end

  test "taking a queued demo claims its prepared content for the user" do
    actor = users(:user)
    ENV["FEATURES_DEMO_GROUPS_SIZE"] = "1"
    DemoService.refill_queue
    prepared_group_id = DemoService.demo_group_ids.fetch(0)
    unread_count_before = NotificationDelivery.where(recipient: actor, channel: "in_app", viewed_at: nil).count

    group = DemoService.take_demo(actor)

    assert_equal prepared_group_id, group.id
    assert_equal actor, group.creator
    assert_equal "demo", group.subscription.plan
    assert_equal actor, group.subscription.owner
    assert group.admins.exists?(actor.id)
    refute group.info.fetch("demo_group_queued")
    assert_equal actor.id, group.info.fetch("demo_group_recipient_id")
    assert_empty DemoService.demo_group_ids

    active_polls = group.polls.active
    assert active_polls.any?
    active_polls.each do |poll|
      assert poll.stances.latest.undecided.exists?(participant: actor)
    end

    unread_count_after = NotificationDelivery.where(recipient: actor, channel: "in_app", viewed_at: nil).count
    assert_equal unread_count_before + 3, unread_count_after
  end

  test "taking a demo rejects an unmarked group id from the cache" do
    actor = users(:user)
    unrelated_group = groups(:alien_group)
    fallback_group = groups(:group)
    DemoService.write_demo_group_ids([ unrelated_group.id ])
    fallback = DemoGroupTemplateService::Result.new(
      group: fallback_group,
      discussions: {},
      polls: {},
      notifications: []
    )

    DemoGroupTemplateService.stub(:create!, fallback) do
      assert_equal fallback_group, DemoService.take_demo(actor)
    end

    assert_nil unrelated_group.reload.creator_id
    assert_empty DemoService.demo_group_ids
  end
end
