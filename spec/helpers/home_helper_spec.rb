require 'spec_helper'

describe HomeHelper do
  describe "choosing motion panel class" do
    it "will be last if it's the fourth element" do
      motion_panel_class(4).should == 'last'
    end

    it "will be blank if it's the first element" do
      motion_panel_class(0).should be_blank
    end

    it "will be blank if it's any other element" do
      motion_panel_class(3).should be_blank
    end
  end
end
