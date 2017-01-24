module Development::PollsHelper

  private

  def test_poll(stance_data:)
    @poll ||= FactoryGirl.create :poll,
      poll_type: 'poll',
      discussion: test_discussion,
      stance_data: stance_data,
      author: patrick
  end
end
