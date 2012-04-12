require 'spec_helper'

describe ApplicationHelper do
  describe "format linebreaks to br" do
    it "safely converts \n characters to br" do
      helper.format_linebreaks("text\n\nmore text")
        .should == "text<br/><br/>more text"
    end
  end
end

