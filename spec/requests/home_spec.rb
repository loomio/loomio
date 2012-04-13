require 'spec_helper'

describe "Home" do
  subject { page }

  context "logged out user views homepage" do
    it "sees dashboard" do
      visit root_path

      should have_css('#public-homepage')
    end
  end
end
