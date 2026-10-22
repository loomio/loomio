require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::PollOptionTest < ActiveSupport::TestCase
  test "options inherit poll visibility across topic roles and valid voting modes" do
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]

    %i[discussion_topic direct_topic public_discussion_topic].each do |topic_name|
      topic = topics(topic_name)
      topic.update!(allow_concurrent_polls: true)
      author = topic_name == :direct_topic ? users(:guest_admin_normal) : users(:admin)
      topic.group.add_admin!(author) if topic_name == :public_discussion_topic

      [false, true].each do |anonymous|
        poll = PollService.create(params: {
          topic_id: topic.id, title: "Option visibility", poll_type: "proposal",
          poll_option_names: %w[Agree Disagree], closing_at: 1.day.from_now, anonymous: anonymous,
          quorum_pct: 50
        }, actor: author)
        option = poll.poll_options.first!
        option.poll = poll
        modes = anonymous ? ["until_closed"] : Poll.hide_results.keys

        modes.each do |mode|
          [nil, Time.current].each do |closed_at|
            poll.update_columns(hide_results: mode, closed_at: closed_at)

            actors.each do |actor|
              assert_equal actor.can?(:show, poll), actor.can?(:show, option),
                "#{topic_name}, anonymous=#{anonymous}, results=#{mode}, closed=#{closed_at.present?}, actor=#{actor.id}"
            end
          end
        end
      end
    end
  end
end
