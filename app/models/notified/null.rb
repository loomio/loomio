class Notified::Null < Notified::Base
  def initialize(query)
    @query = query
  end

  def id
  end

  def type
    'Null'
  end

  def title
    I18n.t(:"notified.no_matches_found", query: @query)
  end
end
