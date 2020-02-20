require 'rails_helper'

describe ExamplePollService do
  let!(:group) { create :group }
  let!(:poll) { FactoryBot.create(:poll) }
  let!(:example_poll) { FactoryBot.create(:poll, example: true, created_at: 2.day.ago) }
  let!(:user) { FactoryBot.create(:user) }
  let!(:example_user) { FactoryBot.create(:user, email: "something@example.com", created_at: 2.day.ago) }

  before do
    group.add_member! example_user
  end

  it('deletes example poll but does not delete poll') do
    ExamplePollService.cleanup
    expect { example_poll.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(poll.reload.persisted?).to eq true
  end

  it('deletes example user but does not delete user') do
    ExamplePollService.cleanup
    expect { example_user.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(user.reload.persisted?).to eq true
  end
end
