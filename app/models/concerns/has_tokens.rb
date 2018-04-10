module HasTokens
  def initialized_with_token(column, method = nil)
    after_initialize do
      send(:"#{column}=", method&.call || self.class.generate_unique_secure_token)
    end
  end
end
