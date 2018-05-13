class Queries::UnionQuery
  def self.for(table_name, queries)
    from = Array(queries).map(&:to_sql).map(&:presence).compact.join(" UNION ")
    table_name.to_s.singularize.camelize.constantize.distinct.from("(#{from}) as #{table_name}")
  end
end
