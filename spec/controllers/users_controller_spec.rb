require 'spec_helper'

describe UsersController do
  let(:previous_url) { root_url }
  let(:user) { User.make! }

  before do
    sign_in user
    request.env["HTTP_REFERER"] = previous_url
  end

  describe 'updating a user' do
    context 'there is a new_uploaded_avatar' do
      post :update, :user => {:name => 'the don', :avatar_kind => 'uploaded', :uploaded_avartar => 'www.great-picture.jpg'}
      #context 'save fails' do
        #it 'displays a unsupprted file type message if save is unsucessful'
      #end
      it 'routes back to user setting page' do
        response.should be_redirect(:root)
      end
    end
    #context 'there is not a new_uploaded_avatar' do
      #it 'displays a success message and routes to the root if it saved sucessfully'
        #flash[:success].should =~ /Your settings have been updated./
        #response.should be_redirect
      #it 'displays a failure message and routes back to user setting if save fails'
        #flash[:error].should  =~ /Unable to update user. Supported file types are jpeg, png, and gif./
        #response.should be_redirect
    #end
  end

  describe "#dismiss_system_notice" do
    it "sets flag on user model" do
      user.should_receive(:has_read_system_notice=).with(true)
      user.should_receive(:save!)
      post :dismiss_system_notice
    end

    it "redirects to previous page" do
      post :dismiss_system_notice
      response.should redirect_to(previous_url)
    end
  end
end
