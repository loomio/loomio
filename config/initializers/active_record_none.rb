class ActiveRecord::Base
  def self.none
    where('1 = 2')
  end
end
