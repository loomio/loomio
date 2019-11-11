require 'rails_helper'

describe ExampleContent do
  let(:group) { FormalGroup.new(name: "test") }
  subject { ExampleContent.new(group) }

  describe 'add_to_group!' do
    it 'creates one example thread' do
      expect { subject.add_to_group! }.to change { group.discussions.count }.by(1)
    end

    it 'creates an example proposal' do
      expect { subject.add_to_group! }.to change { group.polls.count }.by(1)
    end

    it 'does not send emails' do
      expect { subject.add_to_group! }.to_not change { ActionMailer::Base.deliveries.count }
    end

  end
end
