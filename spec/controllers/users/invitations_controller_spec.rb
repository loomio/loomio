require 'spec_helper'

describe Users::InvitationsController do

  let(:user)  { stub_model(User) }
  let(:invited_user)  { stub_model(User) }
  let(:group)  { stub_model(Group) }

  context "logged-in user" do
    before :each do
      sign_in user
      Group.stub(:find).with(group.id.to_s).and_return(group)
      Group.stub(:find).with(group.id, nil).and_return(group)

      # The following line must be called for devise controller tests
      # See: http://stackoverflow.com/a/4321055/307438
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it "can invite member (with no existing loomio account)" do
      User.should_receive(:invite!).and_return(invited_user)
      User.should_receive(:where).and_return([])
      group.should_receive(:add_member!).with(invited_user)
      invited_user.should_receive(:errors).twice.and_return([])
      invited_user.should_receive(:groups).and_return([group])

      post :create, user: {email: "test@example.com", group_id: group.id}
      response.should be_redirect
      flash[:notice].should match(/An invite has been sent/)
    end

    it "can invite member (with an existing loomio account)" do
      # TODO: this should probably be better about testing the .where()
      #       logic in the controller method
      User.should_receive(:where).and_return([invited_user])
      invited_user.should_receive(:groups).and_return([], [group])
      #invited_user.should_receive(:email).and_return("example@test.com")
      group.should_receive(:add_member!).with(invited_user)
      UserMailer.should_receive(:added_to_group).and_return(stub(deliver: true))

      post :create, user: {email: "test@example.com", group_id: group.id}
      response.should be_redirect
      flash[:notice].should match(/has been added to the group/)
    end

    it "can attempt to invite existing member"

    it "must provide email when inviting member"
  end

end
