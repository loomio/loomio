require 'spec_helper'

describe Tree do
  describe "#new(args)" do
    it "assigns parent, value and children" do
      parent, value, children = stub(:parent), stub(:value), stub(:children)
      root = Tree.new(parent: parent, value: value,
                                children: children)
      root.parent.should == parent
      root.value.should == value
      root.children.should == children
    end
  end

  describe "#each" do
    it "yields self, then children (depth first)" do
      value, child_value = stub(:value), stub(:child_value)
      root = Tree.new
      children = [Tree.new(parent: root), Tree.new(parent: root)]
      grandchild = Tree.new(parent: children[0])
      children[0].children = [grandchild]
      root.children = children
      enumerator = root.each
      enumerator.next.should == root
      enumerator.next.should == children[0]
      enumerator.next.should == grandchild
      enumerator.next.should == children[1]
    end
  end

  describe "#root?" do
    it "returns true if no parent exists" do
      node = Tree.new
      node.should be_root
    end
    it "returns false if parent exists" do
      node = Tree.new(parent: Tree.new)
      node.should_not be_root
    end
  end
end
