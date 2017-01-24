module Development::PollsHelper

  private

  def test_poll(stance_data: {})
    @poll ||= FactoryGirl.create :poll,
      poll_type: 'poll',
      discussion: test_discussion,
      stance_data: stance_data,
      author: patrick
  end

  def test_agree
    @agree ||= begin
      stance = FactoryGirl.build(:stance, poll: test_poll, stance_choices_attributes: [{ poll_option_id: test_poll.poll_option_ids.first }])
      StanceService.create(stance: stance, actor: patrick)
    end
  end

  def poll_email_info(poll: test_poll, recipient: patrick, utm: {})
    @info ||= PollEmailInfo.new(poll: poll, recipient: recipient, utm: utm)
  end
end
