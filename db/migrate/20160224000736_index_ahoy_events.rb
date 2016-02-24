class IndexAhoyEvents < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute "CREATE INDEX ahoy_events_properties ON ahoy_events USING gin (properties);"
  end
end
