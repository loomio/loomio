require 'rails_helper'

describe EnablePollsJob do
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let!(:motion) { create :motion, discussion: discussion }
  let(:another_motion) { create :motion, discussion: discussion }
  subject { EnablePollsJob.perform_now(group.id) }

  it 'enables polls for a group' do
    expect { subject }.to change { group.polls.count }.by(1)
  end

  it 'sets uses_polls to true' do
    subject
    expect(group.reload.features['uses_polls']).to eq true
  end
end
