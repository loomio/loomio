require "test_helper"

class DemoGroupTemplateServiceTest < ActiveSupport::TestCase
  test "mobile template provisions a private walkthrough for the selected user" do
    user = users(:user)

    result = DemoGroupTemplateService.create!(template_key: "mobile", user: user)

    assert_equal "Oatmilk Cooperative", result.group.name
    assert_equal "closed", result.group.group_privacy
    assert_equal "invitation", result.group.membership_granted_upon
    assert_equal "demo", result.group.subscription.plan
    assert_equal user, result.group.subscription.owner
    assert result.group.admins.exists?(user.id)
    assert_equal 4, result.group.members.count
    assert result.group.logo.attached?
    assert result.group.cover_photo.attached?
    assert_equal 4, result.discussions.length
    assert_equal 9, result.polls.length
    assert_equal 2, result.discussions.fetch("board_meeting").files.count
    assert_equal %w[check dot_vote meeting poll proposal ranked_choice stv], result.polls.values.map(&:poll_type).uniq.sort

    active_polls = result.polls.values.select(&:active?)
    assert_equal 5, active_polls.length
    active_polls.each do |poll|
      user_stance = poll.stances.latest.find_by!(participant: user)
      assert_nil user_stance.cast_at
      assert user.ability.can?(:vote_in, poll)
    end
    assert_equal 4, result.polls.values.count(&:closed?)

    unread_deliveries = NotificationDelivery.where(
      notification: result.notifications,
      recipient: user,
      channel: "in_app",
      viewed_at: nil
    )
    assert_equal 3, unread_deliveries.count
    assert unread_deliveries.all?(&:delivered_at?)
  end

  test "each run creates a clean demo without changing the previous walkthrough" do
    user = users(:user)
    first = DemoGroupTemplateService.create!(template_key: "mobile", user: user)
    first_stance = first.polls.fetch("bottle_trial_consent").stances.latest.find_by!(participant: user)
    first_stance.choice = "Agree"
    StanceService.create(stance: first_stance, actor: user)

    second = DemoGroupTemplateService.create!(template_key: "mobile", user: user)

    refute_equal first.group.id, second.group.id
    assert first_stance.reload.cast_at
    assert_nil second.polls.fetch("bottle_trial_consent").stances.latest.find_by!(participant: user).cast_at
  end

  test "template keys cannot escape the configured template directory" do
    error = assert_raises(ArgumentError) do
      DemoGroupTemplateService.create!(template_key: "../database", user: users(:user))
    end

    assert_equal "invalid demo group template key", error.message
  end
end
