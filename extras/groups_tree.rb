class GroupsTree
  include Enumerable

  def initialize(user)
    @user = user
  end

  def self.for_user(user)
    new(user)
  end

  def depth_first_traversal(&block)
    return to_enum unless block_given?
    each(&block)
  end

  def each(&block)
    return to_enum unless block_given?
    tree.each do |group_node|
      yield group_node.value unless group_node.root?
    end
  end

  private

  def tree
    root = Tree.new
    @user.groups.order('parent_id DESC, LOWER(name)').each do |group|
      if group.is_a_parent?
        root.children << Tree.new(parent: root, value: group)
      else
        parent = root.children.find { |child| child.value.id == group.parent_id }
        parent.children << Tree.new(parent: parent, value: group)
      end
    end
    root
  end
end
