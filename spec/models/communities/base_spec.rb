require 'rails_helper'

 describe Communities::Base do

   let(:community) { create :community, community_type: :loomio }

   describe 'find' do
     it 'finds the correct classes for communities' do
       expect(Communities::Base.find(community.id)).to be_a Community::Loomio
     end
   end

   describe 'where' do
     it 'finds the correct classes for communities' do
       expect(Communities::Base.where(id: community.id).first).to be_a Community::Loomio
     end
   end

 end
