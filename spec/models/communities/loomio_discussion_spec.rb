require 'rails_helper'

 describe Communities::LoomioDiscussion do

   let(:group) { create :group }
   let(:another_group) { create :group }
   let(:discussion) { create :discussion, group: group }
   let(:community) { discussion.community }
   let(:another_discussion) { create :discussion, group: another_group }
   let(:user) { create :user }
   let(:non_member) { create :user }
   let(:visitor) { create :visitor }

   before do
     group.add_member! user
   end

   describe 'group' do
     it 'returns the discussions group' do
       expect(community.group).to eq discussion.group
     end

     it 'returns nil if the discussion is not defined' do
       community.discussion_key = nil
       expect(community.group).to be_nil
     end
   end

   describe 'discussion' do
     it 'allows setting discussion by key' do
       community.update(discussion_key: another_discussion.key)
       expect(community.reload.discussion_key).to eq another_discussion.key
       expect(community.discussion).to eq another_discussion
     end

     it 'allows setting discussion by reference' do
       community.update(discussion: another_discussion)
       expect(community.reload.discussion_key).to eq another_discussion.key
       expect(community.discussion).to eq another_discussion
     end
   end

   describe 'includes?' do
     it 'returns true for group members' do
       expect(community.includes?(user)).to eq true
     end

     it 'returns false for non group members' do
       expect(community.includes?(non_member)).to eq false
     end

     it 'returns false for visitors' do
       expect(community.includes?(visitor)).to eq false
     end

     it 'only includes admins for discussions where members cannot vote' do
       group.update(members_can_vote: false)
       expect(community.reload.includes?(user)).to eq false
       Membership.find_by(user: user, group: group).update(admin: true)
       expect(community.reload.includes?(user)).to eq true
     end
   end

   describe 'participants' do
     it 'returns the members of the discussions group' do
       participants = community.participants
       expect(participants).to include user
       expect(participants).to_not include non_member
       expect(participants).to_not include visitor
     end
   end

 end
