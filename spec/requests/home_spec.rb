require 'spec_helper'

describe "Home" do
  subject { page }

  context "logged out user visits home" do
    it "sees landing page" do
      pending "should be converted to cucs, broken as specs"
      visit root_path

      should have_css('.pages')
    end
  end

  context "a logged in user" do
    before :each do
      @user = create(:user)
      @group = create(:group, name: 'Test Group', viewable_by: :members)
      @group.add_member!(@user)
      @discussion = create(:discussion, group: @group)
      @motion = create(:motion, name: 'Test Motion', discussion: @discussion,
                              author: @user)
      login @user
    end

    context "visits home" do
      it "sees dashboard" do
        pending "should be converted to cucs, broken as specs"
        visit root_path

        should have_css('.dashboard')
      end
    end
  end
end
