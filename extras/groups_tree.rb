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
    user_groups = @user.groups
    parent_groups = user_groups.where('parent_id IS NULL')
    subgroups = user_groups.where('parent_id IS NOT NULL').order('parent_id DESC, LOWER(name)')
    parent_groups = (parent_groups + subgroups.map(&:parent)).
                      uniq.
                      sort_by{|g| g.name}
    parent_groups.each do |group|
      root.children << Tree.new(parent: root, value: group)
    end
    subgroups.each do |group|
      parent = root.children.find { |child| child.value.id == group.parent_id }
      parent.children << Tree.new(parent: parent, value: group)
    end
    root
  end
end
