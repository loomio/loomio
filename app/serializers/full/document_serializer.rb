class Full::DocumentSerializer < DocumentSerializer
  has_one :model, polymorphic: true, key: :attached_to

  def include_model?
    !object.model.is_a? Group
  end
end
