class EnqueMigrateGuest < ActiveRecord::Migration[7.0]
  def change
    GenericWorker.perform_async('MigrateGuestsService', 'migrate!')
  end
end
