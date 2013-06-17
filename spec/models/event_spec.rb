require 'spec_helper'

describe Event do
  describe "#is_repetition_of?" do
    def check_for_repetition(activity)
      latest_event = activity[0]
      previous_event = activity[1]
      latest_event.is_repetition_of?(previous_event)
    end

    before do
      @user = create :user
      @group = create :group
      @group.add_member! @user
      @discussion = FactoryGirl.create :discussion, group: @group
      @discussion.set_description!("first version of the discussion description", false, @user)
    end

    context "kind is discussion_description_edited" do
      before do
        @discussion.set_description!("second version of the discussion description", false, @user)
        @activity = @discussion.activity
      end

      subject { check_for_repetition(@activity) }

      context "time and user are the same" do
        it { should be_true }
      end

      context "time difference is less than 10 minutes" do
        before do
          @activity[1].created_at = 5.minutes.ago
        end
        it { should be_true }
      end

      context "time difference is more than 10 minutes" do
        before do
          @activity[1].created_at = 15.minutes.ago
        end
        it { should be_false }
      end

      context "user is different" do
        before do
          @user2 = create :user
          @group.add_member! @user2
          @discussion.set_description!("second version of the discussion description", false, @user2)
        end
        it {should be_false}
      end
    end

    context "kind is different" do
      it "should return false" do
        @discussion.add_comment(@user, "comment", false)
        check_for_repetition(@discussion.activity).should be_false
      end
    end
  end
end
