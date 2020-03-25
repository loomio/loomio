class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    data[:id] = UUIDTools::UUID.random_create
    super(data)
  end

  def track_event(data)
    data[:id] = UUIDTools::UUID.random_create
    super(data)
  end
end

Ahoy.api = true
Ahoy.server_side_visits = :when_needed
