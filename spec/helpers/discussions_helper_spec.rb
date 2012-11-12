 require 'spec_helper'

describe DiscussionsHelper do
  describe "discussion_activity_count_for(discussion, user)" do
    before do
      @discussion = create :discussion
    end
    it "returns total number of comments if no user is logged in" do
      @discussion.stub(:number_of_comments_since_last_looked).and_return(4)
      discussion_activity_count_for(@discussion, @user).should == 4
    end
    it "returns the number of comments since user last looked at the discussion if user is logged in" do
      @user = create :user
      @discussion.stub(:number_of_comments_since_last_looked).with(@user).and_return(5)
      discussion_activity_count_for(@discussion, @user).should == 5
    end
  end
end

