SearchResult = Struct.new(:discussion_id, :query, :priority, :blurb, :motions, :comments) do

  alias :read_attribute_for_serialization :send

  def discussion
    SearchResultChild.new :discussion, discussion_id, blurb
  end

end
