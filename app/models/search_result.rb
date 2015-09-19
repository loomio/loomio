SearchResult = Struct.new(:discussion, :motion, :comment, :discussion_blurb, :motion_blurb, :comment_blurb, :query, :priority) do
  alias :read_attribute_for_serialization :send
end
