SearchVectorWeight = Struct.new(:field, :weight) do
  def to_s
    "setweight(to_tsvector(coalesce(#{field}, '')), '#{weight}')"
  end
end