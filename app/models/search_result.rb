SearchResult = Struct.new(:result, :query, :priority) do
  alias :read_attribute_for_serialization :send
end
