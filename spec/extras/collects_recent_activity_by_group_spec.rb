require 'spec_helper'

describe CollectsRecentActivityByGroup do
  context 'for a user' do
    let(:user) { FactoryGirl.create :user }
    let(:recent_activity) { CollectsRecentActivityByGroup.new(user, since: 1.day.ago).results }

    context 'in a group' do
      let(:group) { FactoryGirl.create :group }
      before do
        group.add_member! user
      end

      context 'with a new discussion' do
        before do
          @discussion = FactoryGirl.create :discussion,
                                           {group: group, created_at: DateTime.now}
        end
        it 'returns the discussion' do
          recent_activity[group.name][:discussions].should include @discussion
        end
      end

      context 'with an old discussion' do
        before do
          @discussion = FactoryGirl.create :discussion,
                                          {group: group, created_at: 2.days.ago} 
        end
        it 'does not return the discussion' do
          recent_activity[group.name].should be_nil
        end
      end

      context 'with a recently commented, old discussion' do
        before do
          @discussion = FactoryGirl.create :discussion,
                                          {group: group, created_at: 2.days.ago} 

          @comment = FactoryGirl.create :comment,
                                        {:commentable => @discussion}
        end
        it 'returns the discussion' do
          recent_activity[group.name][:discussions].should include @discussion
        end
      end


      context 'with an active proposal' do
        before do
          @discussion = FactoryGirl.create :discussion,
                                           {group: group, created_at: 2.days.ago} 

          @motion = FactoryGirl.create :motion, discussion: @discussion
        end

        it 'returns the proposal' do
          recent_activity[group.name][:motions].should include @motion
        end
      end

      context 'with an inactive proposal' do
        before do
          @discussion = FactoryGirl.create :discussion,
                                           {group: group, created_at: 2.days.ago} 

          @motion = FactoryGirl.create :motion, discussion: @discussion
          @motion.close_voting!
        end
        it 'does not return the proposal' do
          recent_activity[group.name].should be_nil
        end
      end
    end
  end
end
