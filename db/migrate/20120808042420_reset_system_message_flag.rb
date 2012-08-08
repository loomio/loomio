class ResetSystemMessageFlag < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    User.update_all(:has_read_system_notice => false)
  end

  def down
  end
end
