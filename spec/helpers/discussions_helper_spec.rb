 require 'spec_helper'

describe DiscussionsHelper do

  describe "#destination_groups(group, user)" do
    #User can move discussion between two groups if:
    # groups are in the same family
    # and user is admin in both groups
    before do
      @user = create :user
      @parent = create :group, creator: @user
      @subgroup = create :group, parent: @parent, creator: @user
      @subgroup1 = create :group, parent: @parent
    end

    context "the discussion is in a parent group" do
      it "returns all the subgroups I am an admin of for this group" do
        @subgroup1 = create :group, parent: @parent
        destination_groups(@parent, @user).should include([@subgroup.name, @subgroup.id])
        destination_groups(@parent, @user).should_not include([@subgroup1.name, @subgroup1.id])
      end
      it "does not return the discussion's group" do
        destination_groups(@parent, @user).should_not include([@parent.name, @parent.id])
      end
    end
    context "the discussion is in a subgroup" do
      it "the parent is in the returned list" do
        destination_groups(@subgroup, @user).should include([@parent.name, @parent.id])
      end
      it "returns all the subgroups of the parent I am an admin of" do
        @subgroup2 = create :group, parent: @parent, creator: @user
        destination_groups(@subgroup, @user).should include([@subgroup2.name, @subgroup2.id])
        destination_groups(@subgroup, @user).should_not include([@subgroup1.name, @subgroup1.id])
      end
      it "does not return the discussion's group" do
        destination_groups(@subgroup, @user).should_not include([@subgroup.name, @subgroup.id])
      end
    end
  end

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

