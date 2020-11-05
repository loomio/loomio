require 'rails_helper'

describe OutcomeService do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion, author: user, closed_at: 1.day.ago }
  let(:outcome) { create :outcome, poll: poll, author: user }
  let(:new_outcome) { build :outcome, poll: poll }
  before { group.add_member! user }

  describe 'create' do
    it 'creates a new outcome' do
      expect { OutcomeService.create(outcome: new_outcome, actor: user) }.to change { Outcome.count }.by(1)
      expect(poll.reload.current_outcome.statement).to eq new_outcome.statement
      expect(poll.current_outcome.author).to eq new_outcome.author
    end

    it 'does not create an invalid outcome' do
      new_outcome.statement = ""
      expect { OutcomeService.create(outcome: new_outcome, actor: user) }.to_not change { Outcome.count }
    end

    it 'does not allow randos to create outcomes' do
      expect { OutcomeService.create(outcome: new_outcome, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end

    it 'does not allow creating outcomes on open proposals' do
      poll.update(closed_at: nil)
      expect { OutcomeService.create(outcome: new_outcome, actor: user) }.to raise_error { CanCan::AccessDenied }
    end
  end

  describe 'publish_review_due' do
    it 'publishes a due revuew, and only once' do
      outcome.update_attribute(:review_on, Date.today)
      expect {OutcomeService.publish_review_due}.to change {Events::OutcomeReviewDue.count}.by(1)
      expect {OutcomeService.publish_review_due}.to change {Events::OutcomeReviewDue.count}.by(0)
      last_email = ActionMailer::Base.deliveries.last
      expect(last_email.to).to include outcome.author.email
    end

    it 'does not publish null review_on' do
      outcome.update_attribute(:review_on, nil)
      expect {OutcomeService.publish_review_due}.to change {Events::OutcomeReviewDue.count}.by(0)
    end
  end
end
