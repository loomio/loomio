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
    assert_equal 3, result.discussions.length
    assert_equal 6, result.polls.length
    assert_equal result.discussions.fetch("bottle_trial"), result.group.discussions.order_by_latest_activity.first
    assert result.discussions.values.all? { |discussion| discussion.topic.max_depth == 3 }
    assert_equal 4, result.discussions.fetch("bottle_trial").comments.count
    bottle_question = Comment.find_by!(body: "Could we make this a six-week trial with a spending limit and a short update each week? How would the cafes return the empty bottles?")
    assert_equal 1, Comment.where(parent: bottle_question).count
    assert_equal "alex@oatmilk.example", Comment.find_by!(parent: bottle_question).user.email
    agenda_question = Comment.find_by!(body: "Could we add ten minutes for the bottle trial to the agenda? I have a food-safety question to raise.")
    assert_equal "jamie@oatmilk.example", Comment.find_by!(parent: agenda_question).user.email
    meeting_room_question = Comment.find_by!(body: "Could one of the options include a quiet room where we can meet delivery partners privately?")
    assert_equal "jamie@oatmilk.example", Comment.find_by!(parent: meeting_room_question).user.email
    assert_equal 5, result.group.comment_reactions.count
    assert Reaction.exists?(reactable: Comment.find_by!(parent: meeting_room_question), reaction: "💡")
    assert_equal ["Board meetings", "Office planning", "Start here"], result.group.tags.pluck(:name).sort
    assert_equal ["Start here"], result.discussions.fetch("bottle_trial").topic.tags
    assert_equal ["Board meetings"], result.discussions.fetch("board_meeting").topic.tags
    assert_equal ["Office planning"], result.discussions.fetch("office_move").topic.tags
    assert_equal "html", result.discussions.fetch("board_meeting").description_format
    assert_includes result.discussions.fetch("board_meeting").description, "<table>"
    assert_includes result.discussions.fetch("board_meeting").description, "<mark"
    assert_equal 0, result.discussions.fetch("board_meeting").files.count
    assert_equal %w[check meeting poll proposal], result.polls.values.map(&:poll_type).uniq.sort

    active_polls = result.polls.values.select(&:active?)
    assert_equal 4, active_polls.length
    active_polls.each do |poll|
      user_stance = poll.stances.latest.find_by!(participant: user)
      assert_nil user_stance.cast_at
      assert user.ability.can?(:vote_in, poll)
    end
    assert_equal 2, result.polls.values.count(&:closed?)
    assert result.polls.fetch("office_sense_check").outcomes.exists?
    assert result.polls.fetch("office_budget").outcomes.exists?
    assert_equal 3, result.polls.fetch("office_budget").reload.total_score
    assert_operator result.polls.fetch("office_sense_check").created_at, :<, result.polls.fetch("office_budget").created_at
    assert_operator result.polls.fetch("office_budget").created_at, :<, result.polls.fetch("office_consent").created_at
    refute result.polls.fetch("office_consent").outcomes.exists?
    assert result.polls.fetch("bottle_trial_sense_check").active?
    assert result.polls.fetch("meeting_time").active?
    assert result.polls.fetch("approve_minutes").active?

    delivery_poll = result.polls.fetch("office_consent")
    samira = User.find_by!(email: "samira@oatmilk.example")
    positions = delivery_poll.stances.where(participant: samira).order(:id).to_a
    assert_equal 2, positions.length
    assert_equal "disagree", positions.first.stance_choices.first.poll_option.icon
    assert_equal "agree", positions.last.stance_choices.first.poll_option.icon
    refute positions.first.latest?
    assert positions.last.latest?
    clarification = Comment.find_by!(parent: positions.first, user: User.find_by!(email: "jamie@oatmilk.example"))
    assert Comment.exists?(parent: clarification, user: samira)
    assert Comment.exists?(parent: positions.first, user: User.find_by!(email: "alex@oatmilk.example"))
    assert_equal "Move to The Orchard, Chalk Farm", delivery_poll.reload.title

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
    first_stance = first.polls.fetch("bottle_trial_sense_check").stances.latest.find_by!(participant: user)
    first_stance.choice = first.polls.fetch("bottle_trial_sense_check").poll_options.first.name
    StanceService.create(stance: first_stance, actor: user)

    second = DemoGroupTemplateService.create!(template_key: "mobile", user: user)

    refute_equal first.group.id, second.group.id
    assert first_stance.reload.cast_at
    assert_nil second.polls.fetch("bottle_trial_sense_check").stances.latest.find_by!(participant: user).cast_at
  end

  test "template keys cannot escape the configured template directory" do
    error = assert_raises(ArgumentError) do
      DemoGroupTemplateService.create!(template_key: "../database", user: users(:user))
    end

    assert_equal "invalid demo group template key", error.message
  end
end
