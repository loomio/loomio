require 'spec_helper'

describe AngularSupportController do

  describe "GET 'reset_database'" do
    it "returns http success" do
      get 'reset_database'
      response.should be_success
    end
  end

  describe "GET 'existing_discussion'" do
    it "returns http success" do
      get 'existing_discussion'
      response.should be_success
    end
  end

end
