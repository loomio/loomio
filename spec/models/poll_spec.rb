require 'rails_helper'

describe Poll do
  let(:template) { create :poll_template, poll_options: [poll_option], allow_custom_options: false }
  let(:poll_option) { create :poll_option }
  let(:poll) { build :poll, poll_options: [poll_option], poll_template: template, allow_custom_options: false }

  it 'validates correctly if no poll option changes have been made' do
    expect(poll.valid?).to eq true
  end

  it 'does not allow changing poll options if the template does not allow' do
    poll.poll_options.build
    expect(poll.valid?).to eq false
  end

  it 'does not allow changing poll options if the poll does not allow' do
    template.allow_custom_options = true
    poll.allow_custom_options = false
    poll.poll_options.build
    expect(poll.valid?).to eq false
  end

  it 'does not allow updating allow_custom_options if template does not allow' do
    poll.allow_custom_options = true
    expect(poll.valid?).to eq false
  end
end
