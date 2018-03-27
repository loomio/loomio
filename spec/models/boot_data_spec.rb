require 'rails_helper'

 describe BootData do
    let(:user) { create :user }
    let(:group) { create :formal_group }
    let(:discussion) { create :discussion, group: group }
    let!(:membership) { group.add_member! user }
    let(:subject) { BootData.new(user) }
    let(:notification) { create(:notification, user: user) }
    let(:comment) { create(:comment, parent: create(:comment, discussion: discussion, author: user), discussion: discussion) }
    let(:notification) { create :notification, user: user }
    let(:identity) { create :slack_identity, user: user }

    describe 'payload' do
      it 'returns the current users memberships' do
        expect(subject.payload[:memberships].map { |m| m[:id] }).to include membership.id
      end

      it 'returns the current users notifications' do
        notification
        expect(subject.payload[:notifications].map { |n| n[:id] }).to include notification.id
      end

      it 'returns the current users identities' do
        identity
        expect(subject.payload[:identities].map { |i| i[:id] }).to include identity.id
      end
    end
 end
