require 'spec_helper'

describe "Discussion" do
  subject { page }

  context "a logged in user" do
    before :each do
      @user = User.make!
      page.driver.post user_session_path, 'user[email]' => @user.email,
                       'user[password]' => 'password'
    end

    it "can create a new discussion" do
      group = Group.make
      group.save
      group.add_member!(@user)

      visit new_discussion_path(discussion: { group_id: group.id })

      fill_in 'discussion_title', with: 'This is a new discussion'
      fill_in 'discussion_comment', with: 'Blahhhhhh'
      click_on 'Create discussion'
      should have_css(".discussions.show")
      should have_content('Blahh')
    end
  end
end

