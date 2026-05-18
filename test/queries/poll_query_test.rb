require 'test_helper'

class PollQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_admin!(@user)
    @discussion = create_discussion(group: @group, author: @user)

    def make_poll(**attrs)
      defaults = {
        poll_type: "poll",
        title: "Test poll #{SecureRandom.hex(4)}",
        author: @user,
        poll_option_names: ["engage"],
        opened_at: Time.now,
        notify_on_closing_soon: "voters"
      }
      p = Poll.new(defaults.merge(attrs))
      p.save!
      p.create_missing_created_event!
      p
    end

    @closed_long_ago  = make_poll(closed_at: 1.month.ago, closing_at: 1.month.ago)
    @closed_soon      = make_poll(closed_at: 1.day.ago, closing_at: 1.day.ago)
    @closing_soon     = make_poll(closed_at: nil, closing_at: 1.day.from_now)
    @closing_far_away = make_poll(closed_at: nil, closing_at: 1.month.from_now)

    @authored = make_poll(closing_at: 5.days.from_now)

    hex = SecureRandom.hex(4)
    @guest_user = User.create!(name: "pollguest#{hex}", email: "pollguest#{hex}@example.com", username: "pollguest#{hex}")
    @participated = make_poll(closing_at: 5.days.from_now)
    @participated.add_guest!(@user, @authored.author)

    @in_a_discussion = make_poll(discussion: @discussion, group: @group, closing_at: 5.days.from_now)
    @in_a_group = make_poll(group: @group, closing_at: 5.days.from_now)

    hex2 = SecureRandom.hex(4)
    rando_author = User.create!(name: "rando#{hex2}", email: "rando#{hex2}@example.com", username: "rando#{hex2}")
    @rando = make_poll(author: rando_author, closing_at: 5.days.from_now)
    other_group = Group.create!(name: "Other Group #{hex2}", handle: "othergroup#{hex2}")
    @rando_in_group = make_poll(author: rando_author, group: other_group, closing_at: 5.days.from_now)

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
