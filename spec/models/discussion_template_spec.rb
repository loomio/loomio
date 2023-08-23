require 'rails_helper'

describe Poll do
  let!(:group) { create :group }
  let!(:poll_template) { create :poll_template, group: group}
  let!(:other_poll_template) { create :poll_template }

  it 'filters disallowed ids' do
    dt = DiscussionTemplate.new(group: group)
    dt.poll_template_keys_or_ids = [poll_template.id, other_poll_template.id]
    dt.filter_poll_template_keys_or_ids
    expect(dt.poll_template_keys_or_ids).to eq [poll_template.id]
  end

  it 'filters unrecognised keys' do
    dt = DiscussionTemplate.new(group: group)
    dt.poll_template_keys_or_ids = ['question', 'fake']
    dt.filter_poll_template_keys_or_ids
    expect(dt.poll_template_keys_or_ids).to eq ['question']
  end
end
