require 'rails_helper'

describe InvitationParser do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:invitations) {[
    { type: 'email', email: 'email@me.com' },
    { type: 'contact', email: 'contact@me.com' },
    { type: 'user', id: user.id },
    { type: 'group', id: group.id }
  ]}
  let(:subject) { InvitationParser.new(invitations) }

  before do
    3.times { group.members << create(:user) }
  end

  it 'parses a user to its id' do
    group.members.each do |member|
      expect(subject.new_members).to include member
    end
  end

  it 'parses all group members to their user ids' do
    expect(subject.new_members).to include user
  end

  it 'parses a contact to its email' do
    expect(subject.new_emails).to include 'contact@me.com'
  end

  it 'parses an email to its email' do
    expect(subject.new_emails).to include 'email@me.com'
  end
end