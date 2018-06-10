module HasDefaults
  def initialized_with_default(column, method = nil)
    after_initialize do
      send(:"#{column}=", method&.call) if send(column) == nil
    end
  end
end
