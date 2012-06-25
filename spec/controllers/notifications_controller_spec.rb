require 'spec_helper'

describe NotificationsController do
  describe "#index" do
    before { get :index }

    it { response.should be_success }
  end
end
