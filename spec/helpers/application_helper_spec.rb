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
  describe "set_title" do
  	context "for a group" do
 	  it "has the group name in title" do
      	@atoz = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' 	  	
 	  	helper.should_receive(:content_for).with(:title, "the title - #{@atoz}")
 	  	helper.set_title(@atoz, 'the title')
 	  end

 	  it "strips out quotes" do
 	  	@string = 'onetwoth"ree'
 	  	helper.should_receive(:content_for).with(:title, "the title - onetwothree")
 	  	helper.set_title(@string, 'the title')
 	  end

 	  it "strips out brackets" do
 	   	@string = 'onetwo<three>'
 	  	helper.should_receive(:content_for).with(:title, "the title - onetwothree")
 	  	helper.set_title(@string, 'the title')	
 	  end

 	  it "includes a parent" do
 	  	@parent = stub_model(Group, :name => 'Parent Group')
 	  	@group_name = 'This Group'
 	  	helper.should_receive(:content_for).with(:title, "the title - Parent Group - This Group")
 	  	helper.set_title(@group_name, 'the title', @parent)	
 	  end

  	end
  end
end

