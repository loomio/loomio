class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def named_id
    { "#{ActiveModel::Naming.singular(self)}_id" => id }
  end
end
