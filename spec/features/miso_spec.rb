require "spec_helper"

describe "Wikipedia's Miso Page", :sauce => true do
  it "Should mention a favorite type of Miso" do
    visit "http://en.wikipedia.org/"
    fill_in 'searchInput', :with => "Miso"
    click_button "searchButton"
    page.should have_content "Akamiso"
  end
end
