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
          @discussion = create_discussion group: group, created_at: DateTime.now
        end
        it 'returns the discussion' do
          recent_activity[group.full_name][:discussions].should include @discussion
        end
      end

      context 'with an old discussion' do
        before do
          @discussion = create_discussion group: group, created_at: 2.days.ago, last_comment_at: 2.days.ago
        end
        it 'does not return the discussion' do
          recent_activity[group.full_name].should be_nil
        end
      end

      context 'with a recently commented, old discussion' do
        before do
          @discussion = create_discussion group: group, created_at: 2.days.ago, last_comment_at: 2.days.ago

          @comment = Comment.new(body: 'hi')
          @comment.author = @discussion.author
          @comment.discussion = @discussion
          DiscussionService.add_comment(@comment)
        end
        it 'returns the discussion' do
          recent_activity[group.full_name][:discussions].should include @discussion
        end
      end


      context 'with an active proposal' do
        before do
          @discussion = create_discussion group: group, created_at: 2.days.ago

          @motion = FactoryGirl.create :motion, discussion: @discussion
        end

        it 'returns the proposal' do
          recent_activity[group.full_name][:motions].should include @motion
        end
      end

      context 'with an inactive proposal' do
        before do
          @discussion = create_discussion group: group, created_at: 2.days.ago, last_comment_at: 2.days.ago

          @motion = FactoryGirl.create :motion, discussion: @discussion
          @motion.close!
        end
        it 'does not return the proposal' do
          recent_activity[group.full_name].should be_nil
        end
      end
    end
  end
end
