require 'rails_helper'

 describe Communities::Base do

   let(:discussion_community) { create :email_community }
   let(:group_community) { create :loomio_group_community }

   describe 'find' do
     it 'finds the correct classes for communities' do
       expect(Communities::Base.find(group_community.id)).to be_a Communities::LoomioGroup
       expect(Communities::Base.find(discussion_community.id)).to be_a Communities::Email
     end
   end

   describe 'where' do
     it 'finds the correct classes for communities' do
       expect(Communities::Base.where(id: group_community.id).first).to be_a Communities::LoomioGroup
       expect(Communities::Base.where(id: discussion_community.id).first).to be_a Communities::Email
     end
   end

   describe 'includes?' do
     it 'raises a not implemented error' do
       expect { Communities::Base.new.includes?(User.last) }.to raise_error { NotImplementedError }
     end
   end

   describe 'participants' do
     it 'raises a not implemented error' do
       expect { Communities::Base.new.participants }.to raise_error { NotImplementedError }
     end
   end

 end
