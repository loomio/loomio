require 'rails_helper'

 describe CurrentUserData do
    let(:user) { create :user }
    let(:group) { create :group }
    let!(:membership) { group.add_member! user }
    let(:subject) { CurrentUserData.new(user) }
    let(:restricted_subject) { CurrentUserData.new(user, true) }
    let(:notification) { create(:notification, user: user) }
    let(:unread) { create(:discussion, group: group) }

    describe 'data' do
      it 'returns the current user' do
        expect(subject.data.dig(:current_user, :username)).to eq user.username
      end

      it 'returns the current users memberships' do
        expect(subject.data[:memberships].map { |m| m[:id] }).to include membership.id
      end

      it 'returns the current users notifications' do
        event = CommentService.create(comment: build(:comment, discussion: unread), actor: user)
        notification = event.notify!(user)
        expect(subject.data[:notifications].map { |n| n[:id] }).to include notification.id
      end

      it 'returns the current users unread threads' do
        unread
        expect(subject.data[:discussions].map { |d| d[:id] }).to include unread.id
      end

      it 'does not return old unread threads' do
        unread.update(last_activity_at: 10.weeks.ago)
        expect(subject.data[:discussions]).to_not be_present
      end
    end

    describe 'restricted' do
      it 'returns the current user' do
        expect(restricted_subject.data.dig(:current_user, :username)).to eq user.username
      end

      it 'returns the current users memberships' do
        expect(restricted_subject.data[:memberships].map { |m| m[:id] }).to include membership.id
      end

      it 'does not return the current users notifications' do
        event = CommentService.create(comment: build(:comment, discussion: unread), actor: user)
        notification = event.notify!(user)
        expect(restricted_subject.data[:notifications]).to_not be_present
      end

      it 'does not return the current users unread threads' do
        unread
        expect(restricted_subject.data[:discussions]).to_not be_present
      end
    end

 end
