require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the GroupsHelper. For example:
#
# describe GroupsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe GroupsHelper do
  describe "viewable_by_label" do
    context "given :everyone" do
      it "shows label text" do
        helper.viewable_by_label(:everyone).should == "Everyone"
      end
    end
    context "given :members" do
      it "shows label text" do
        helper.viewable_by_label(:members).should == "Members"
      end
    end
  end
end
