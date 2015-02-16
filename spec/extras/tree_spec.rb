require 'rails_helper'

describe Tree do
  describe "#new(args)" do
    it "assigns parent, value and children" do
      parent, value, children = double(:parent), double(:value), double(:children)
      root = Tree.new(parent: parent, value: value,
                                children: children)
      expect(root.parent).to eq parent
      expect(root.value).to eq value
      expect(root.children).to eq children
    end
  end

  describe "#each" do
    it "yields self, then children (depth first)" do
      value, child_value = double(:value), double(:child_value)
      root = Tree.new
      children = [Tree.new(parent: root), Tree.new(parent: root)]
      grandchild = Tree.new(parent: children[0])
      children[0].children = [grandchild]
      root.children = children
      enumerator = root.each
      expect(enumerator.next).to eq root
      expect(enumerator.next).to eq children[0]
      expect(enumerator.next).to eq grandchild
      expect(enumerator.next).to eq children[1]
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
