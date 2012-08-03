require 'spec_helper'

describe UsersController do
  let(:previous_url) { root_url }
  let(:user) { User.make! }

  before do
    sign_in user
    request.env["HTTP_REFERER"] = previous_url
  end

  describe "#update" do
    it "updates user.name" do
      user.should_receive(:name=).with("Peter Chilltooth")
      user.should_receive(:save).and_return(true)
      post :update, :id => 999, :user => {:name => "Peter Chilltooth"}
    end
    it "displays a success message" do
      user.stub(:save).and_return(true)
      post :update, :id => 999, :user => {:name => "Peter Chilltooth"}
      flash[:notice].should =~ /Your settings have been updated./
    end
    it "redirects to root on success" do
      user.stub(:save).and_return(true)
      post :update, :id => 999, :user => {:name => "Peter Chilltooth"}
      response.should redirect_to(previous_url)
    end
    it "redirects to back on failure" do
      user.stub(:save).and_return(false)
      post :update, :id => 999, :user => {:name => "Peter Chilltooth"}
      response.should redirect_to(:back)
    end
  end

  describe "#upload_new_avatar" do
    before do
      @user = mock_model User
      controller.stub(:current_user).and_return(@user)
      @user.stub(:avatar_kind=).with("uploaded")
      @user.stub(:uploaded_avatar=).with("www.peter_chilltooth.jpg")
    end
    it "updates user.uploaded_avatar" do
      @user.should_receive(:save).and_return(true)
      post :upload_new_avatar, :id => 999, :uploaded_avatar => "www.peter_chilltooth.jpg"
    end
    it "displays an unsupported file-type message on failure" do
      @user.stub(:save).and_return(false)
      post :upload_new_avatar, :id => 999, :uploaded_avatar => "www.peter_chilltooth.jpg"
      flash[:error].should =~ /Unable to update user. Supported file types are./
    end
    it "redirects to back" do
      @user.stub(:save).and_return(true)
      post :upload_new_avatar, :id => 999, :uploaded_avatar => "www.peter_chilltooth.jpg"
      post :upload_new_avatar, :id => 999, :uploaded_avatar => "www.peter_chilltooth.jpg"
      response.should redirect_to(:back)
    end
  end

  describe "#set_avatar_kind" do
    it "updates user.avatar_kind" do
      user.should_receive(:avatar_kind=).with("uploaded")
      user.should_receive(:save).and_return(true)

      xhr :post, :set_avatar_kind, :format => :json, :id => 999,
        :avatar_kind => "uploaded"
    end
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
