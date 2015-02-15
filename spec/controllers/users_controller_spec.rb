require 'rails_helper'

describe UsersController do
  let(:user) { create(:user) }

  before do
    sign_in user
    controller.stub(:set_locale)
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
      expect(flash[:notice]).to match(/Your settings have been updated./)
    end
    it "displays an error message" do
      user.stub(:save).and_return(false)
      post :update, :id => 999, :user => {:name => "Peter Chilltooth"}
      expect(flash[:error]).to match(/Your settings did not get updated./)
    end
    it "redirects to dashboard on success" do
      user.stub(:save).and_return(true)
      post :update, :id => 999, :user => {:name => "Peter Chilltooth"}
      response.should redirect_to(dashboard_path)
    end
    it "redirects to profile on failure" do
      user.stub(:save).and_return(false)
      post :update, :id => 999, :user => {:name => "Peter Chilltooth"}
      response.should render_template('profile')
    end
  end

  describe "#upload_new_avatar" do
    before do
      @user = create(:user)
      controller.stub(:current_user).and_return(@user)
      controller.stub(:get_notifications)
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
      expect(flash[:error]).to match(/Unable to upload picture. Make sure the picture is under 1 MB and is a .jpeg, .png, or .gif file./)
    end
    it "redirects to profile" do
      @user.stub(:save).and_return(true)
      post :upload_new_avatar, :id => 999, :uploaded_avatar => "www.peter_chilltooth.jpg"
      response.should redirect_to profile_url
    end
  end

  describe "#set_avatar_kind" do
    before do
      user.stub(:save!)
    end
    after do
      xhr :put, :set_avatar_kind, id: 1, avatar_kind: "Uploaded"
    end
    it "updates the avatar_kind attribute in the model" do
      user.should_receive(:avatar_kind=).with "Uploaded"
    end
    it "saves the model" do
      user.should_receive(:save!)
    end
  end
end
