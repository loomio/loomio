class Full::GroupSerializer < GroupSerializer
  attribute :complete

  def complete
    true
  end
end
