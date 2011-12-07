require 'spec_helper'

describe EmailGroupsController do
  context 'logged in user, member of group' do
    before :each do
      sign_in @user = User.make!
      @group = Group.make!
      @group.add_member!(@user)
    end

    it 'loads email_group new' do
      get :new
      response.should be_success
    end

    it 'sends email to members of the group' do
      post :create, {:group_id => @group.id, :message => 'spam'}
      response.should be_redirect
      flash[:notice] =~ /spammed/
      last_email =  ActionMailer::Base.deliveries.last
      last_email.to.should include *@group.users.collect{|m| m.email }
      last_email.body.should =~ /spam/
    end
  end

end
