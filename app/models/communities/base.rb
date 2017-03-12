class Communities::Base < ActiveRecord::Base
  extend HasCustomFields
  self.table_name = :communities
  validates :community_type, presence: true

  has_many :poll_communities, foreign_key: :community_id
  has_many :polls, through: :poll_communities
  has_many :visitors, foreign_key: :community_id

  discriminate Communities, on: :community_type

  def self.set_community_type(type)
    after_initialize { self.community_type = type }
  end

  def includes?(member)
    raise NotImplementedError.new
  end

  def members
    raise NotImplementedError.new
  end

  def notify!(event)
    raise NotImplementedError.new
  end

end
