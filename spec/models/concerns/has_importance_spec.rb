require 'rails_helper'

describe HasImportance do
  let(:discussion) { create(:discussion) }
  let(:reader) { create :discussion_reader, discussion: discussion }
  let(:poll) { create :poll, discussion: discussion }

  let(:levels) { Discussion.importances }

  subject {
    discussion.update_importance
    reader.update_importance
  }

  it 'can detect a pinned thread' do
    discussion.update(pinned: true)
    subject
    expect(discussion.importance).to eq levels[:pinned]
    expect(reader.importance).to eq levels[:pinned]
  end

  it 'can detect a thread with a star and an active decision' do
    reader.update(starred: true)
    poll
    subject
    expect(reader.importance).to eq levels[:starred_and_decision]
  end

  it 'can detect a thread with a star' do
    reader.update(starred: true)
    subject
    expect(reader.importance).to eq levels[:starred]
  end

  it 'can detect a thread with an active decision' do
    poll
    subject
    expect(discussion.importance).to eq levels[:has_decision]
    expect(reader.importance).to eq levels[:has_decision]
  end

  it 'gives back normal_importance if no importance is found' do
    subject
    expect(discussion.importance).to eq levels[:normal_importance]
    expect(reader.importance).to eq levels[:normal_importance]
  end

  it 'does not detect inactive decisions' do
    poll.update(closed_at: 2.days.ago)
    subject
    expect(discussion.importance).to eq levels[:normal_importance]
    expect(reader.importance).to eq levels[:normal_importance]
  end
end
