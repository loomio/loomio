class Full::DocumentSerializer < DocumentSerializer
  has_one :model, polymorphic: true, key: :attached_to
end
