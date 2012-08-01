require 'spec_helper'

describe UsersController do
  let(:previous_url) { root_url }
  let(:user) { User.make! }

  before do
    sign_in user
    request.env["HTTP_REFERER"] = previous_url
  end

  describe "#update"
    #it "updates user.name" do
      #user.should_receive(:name=).with("Peter Chilltooth")
      #user.should_receive(:save).and_return(true)

      #post :update, :id => 998, :name => "Peter Chilltooth"
    #end
  #end

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
