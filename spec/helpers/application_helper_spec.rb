require 'spec_helper'

describe ApplicationHelper do
  describe "display_title" do
    it "shows Loomio name" do
      helper.display_title(double(:size => 0)).should == "Loomio"
    end
    it "shows notifications in paranthensis (if any)" do
      helper.display_title(double(:size => 2)).should == "(2) Loomio"
    end
  end
end

