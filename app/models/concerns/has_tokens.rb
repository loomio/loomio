module HasTokens
  def initialized_with_token(column, method = nil)
    after_initialize do
      send(:"#{column}=", send(column) || method&.call || self.class.generate_unique_secure_token) if self.class.column_names.include? column
    end
  end
end
