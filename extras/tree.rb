class Tree
  include Enumerable
  attr_accessor :parent, :value, :children

  def initialize(params={})
    @parent = params[:parent]
    @value = params[:value]
    @children = params[:children]
    @children ||= []
  end

  def each(&block)
    return to_enum unless block_given?
    yield self
    children.each { |child| child.each(&block) } if children
  end

  def root?
    parent.nil?
  end
end
