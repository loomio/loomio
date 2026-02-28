require 'test_helper'

class PollQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:admin)
    @group = groups(:group)
    @discussion = discussions(:discussion)

    def make_poll(**attrs)
      defaults = {
        poll_type: "poll",
        title: "Test poll #{SecureRandom.hex(4)}",
        poll_option_names: ["engage"],
        closing_at: 5.days.from_now,
        notify_on_closing_soon: "voters"
      }
      p = PollService.build(params: defaults.merge(attrs), actor: attrs[:author] || @user)
      p.save!
      p.create_missing_created_event!
      p
    end

    @closed_long_ago  = make_poll.tap { |p| p.update_columns(closed_at: 1.month.ago, closing_at: 1.month.ago) }
    @closed_soon      = make_poll.tap { |p| p.update_columns(closed_at: 1.day.ago, closing_at: 1.day.ago) }
    @closing_soon     = make_poll(closed_at: nil, closing_at: 1.day.from_now)
    @closing_far_away = make_poll(closed_at: nil, closing_at: 1.month.from_now)

    @authored = make_poll(closing_at: 5.days.from_now)

    hex = SecureRandom.hex(4)
    @guest_user = User.create!(name: "pollguest#{hex}", email: "pollguest#{hex}@example.com", username: "pollguest#{hex}")
    @participated = make_poll(closing_at: 5.days.from_now)
    @participated.stances.create!(participant_id: @user.id, inviter: @authored.author)
    @participated.add_guest!(@user, @authored.author)

    @in_a_discussion = make_poll(topic: @discussion.topic, closing_at: 5.days.from_now)
    @in_a_group = PollService.create(params: { title: "In group #{SecureRandom.hex(4)}", poll_type: 'poll', group_id: @group.id, closing_at: 5.days.from_now, poll_option_names: ['engage'] }, actor: @user)

    hex2 = SecureRandom.hex(4)
    rando_author = User.create!(name: "rando#{hex2}", email: "rando#{hex2}@example.com", username: "rando#{hex2}")
    @rando = make_poll(author: rando_author, closing_at: 5.days.from_now)
    other_group = Group.create!(name: "Other Group #{hex2}", handle: "othergroup#{hex2}")
    other_group.add_admin!(rando_author)
    @rando_in_group = PollService.create(params: { title: "Rando group #{SecureRandom.hex(4)}", poll_type: 'poll', group_id: other_group.id, closing_at: 5.days.from_now, poll_option_names: ['engage'] }, actor: rando_author)

    ActionMailer::Base.deliveries.clear
  end

  test "finds polls the user knows about" do
    results = PollQuery.visible_to(user: @user)
    assert_includes results, @participated
    assert_includes results, @in_a_discussion
    assert_includes results, @in_a_group
    refute_includes results, @rando_in_group
    refute_includes results, @rando
  end
end
