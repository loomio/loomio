require 'spec_helper'

describe Groups::PublicGroupsController do

  describe "GET 'index'" do
    context 'no query param is passed in' do
      it "returns http success" do
        get 'index'
        response.should be_success
      end
    end

    context 'a search query param is passed in' do
      before do
        @group1 = create :group, name: 'black frog legs'
        @group2 = create :group, name: 'dry duck wings'
      end

      it "assigns a matched result set" do
        get :index, :query => "frog"
        assigns(:groups).should == [@group1]
      end

      it "assigns an empty result set" do
        get :index, :query => "log"
        assigns(:groups).should_not include(@group1)
        assigns(:groups).should_not include(@group2)
      end
    end
  end
end
