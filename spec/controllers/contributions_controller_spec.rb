require 'spec_helper'

describe ContributionsController do
  let(:current_user) { build_stubbed(User) }
  before do
    controller.stub :authenticate_user!
    controller.stub :current_user => current_user
  end

  describe 'callback' do
    let(:params){
      {
        :email => "bill@james.com",
        :identifier_id => "15CD8F0D0E88E3",
        :item_quantity => "1",
        :item => "burrito",
        :response_message => "OK",
        :response_code => "200",
        :result => "accepted",
        :subscription => "created",
        :controller => "contributions",
        :action => "callback"
      }
    }

    before do
      get :callback, params
    end

    it 'redirects to thanks' do
      response.should redirect_to thanks_contributions_path
    end

    it 'records a contribution with user id' do
      assigns(:contribution).should be_persisted
      assigns(:contribution).params.should == params.to_json
      assigns(:contribution).user.should == current_user
    end
  end

  describe 'thanks' do
    render_views
    it "renders a thank you page" do
      get :thanks
      response.body.should have_css(".contributions.thanks")
    end
  end
end
