SearchResultChild = Struct.new(:type, :id, :blurb) do

  alias :read_attribute_for_serialization :send

  # sorry, mom.
  def method_missing(method, *args)
    return result.send(method, *args) if result.respond_to? method
    super
  end

  def result
    @result ||= type.to_s.classify.constantize.find(id)
  end
end
