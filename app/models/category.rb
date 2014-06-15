class Category < ActiveRecord::Base
  has_many :groups
  validates_presence_of :name

  def translatable_name
    "group_categories." + name.parameterize.gsub('-', '_')
  end
end
