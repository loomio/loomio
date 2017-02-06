module Dev::PollsHelper

  private

  def test_poll(stance_data: { red: 3, green: 1, blue: 2 })
    @test_poll ||= FactoryGirl.create :poll,
      poll_type: 'poll',
      closing_at: 3.days.from_now,
      poll_option_names: ['grape', 'apple', 'banana'],
      discussion: create_discussion,
      stance_data: stance_data,
      author: patrick
  end

  def test_poll_with_stances
    test_poll.tap do |poll|
      grape = poll.poll_options.find_by(name: 'grape')
      banana = poll.poll_options.find_by(name: 'banana')
      poll.stances.create(participant: patrick,  reason: "I am patrick", stance_choices_attributes: [{ poll_option_id: grape.id }])
      poll.stances.create(participant: jennifer, stance_choices_attributes: [{ poll_option_id: banana.id }])
      poll.stances.create(participant: emilio,   reason: "I am Emilio!", stance_choices_attributes: [{ poll_option_id: grape.id }, { poll_option_id: banana.id }])
      poll.update_stance_data
    end
  end

  def test_proposal(stance_data: { agree: 5, abstain: 3, disagree: 2, block: 1 })
    @test_proposal ||= FactoryGirl.create :poll,
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      poll_option_names: ['agree', 'abstain', 'disagree', 'block'],
      discussion: create_discussion,
      stance_data: stance_data,
      author: patrick
  end

  def test_agree
    @test_agree ||= FactoryGirl.create :stance,
      poll: test_proposal,
      reason: "I am agreeing!",
      participant: patrick,
      stance_choices_attributes: [{
        poll_option_id: test_proposal.poll_options.find_by(name: 'agree').id
      }]
  end

  def test_abstain
    @test_abstain ||= FactoryGirl.create :stance,
      poll: test_proposal,
      reason: "I am abstaining!",
      participant: emilio,
      stance_choices_attributes: [{
        poll_option_id: test_proposal.poll_options.find_by(name: 'abstain').id
      }]
  end

  def test_disagree
    @test_disagree ||= FactoryGirl.create :stance,
      poll: test_proposal,
      reason: "I am disagreeing!",
      participant: jennifer,
      stance_choices_attributes: [{
        poll_option_id: test_proposal.poll_options.find_by(name: 'disagree').id
      }]
  end

  def poll_email_info(poll:, recipient: patrick, actor:, action_name:,  utm: {})
    @info ||= PollEmailInfo.new(poll: poll, recipient: recipient, actor: actor, action_name: action_name, utm: utm)
  end
end
