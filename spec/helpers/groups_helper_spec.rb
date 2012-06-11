require 'spec_helper'

describe GroupsHelper do
  describe "group_permissions_label" do
    context "given :everyone" do
      it "shows label text" do
        helper.group_permissions_label(:everyone).should == "Everyone"
      end
    end
    context "given :members" do
      it "shows label text" do
        helper.group_permissions_label(:members).should == "Members"
      end
    end
    context "given :admins" do
      it "shows label text" do
        helper.group_permissions_label(:admins).should == "Admins"
      end
    end
  end

end
