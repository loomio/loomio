class Communities::Base < ActiveRecord::Base
  extend HasCustomFields
  self.table_name = :communities
  validates :community_type, presence: true

  belongs_to :identity, foreign_key: :identity_id, class_name: "Identities::Base"
  has_many :poll_communities, foreign_key: :community_id
  has_many :polls, through: :poll_communities
  has_many :visitors, foreign_key: :community_id

  delegate :user_id, to: :identity, allow_nil: true
  delegate :user, to: :identity, allow_nil: true
  delegate :identity_type, to: :identity, allow_nil: true

  PROVIDERS = YAML.load_file(Rails.root.join("config", "providers.yml"))['community']
  discriminate Communities, on: :community_type

  scope :with_identity, -> { where("identity_id IS NOT NULL") }

  def community
    self
  end

  def poll_id=(id)
    Array(id).each { |id| poll_communities.build(poll_id: id) }
  end

  def self.set_community_type(type)
    after_initialize { self.community_type = type }
  end

  def includes?(participant)
    participant.identities.any? { |i| i.is_member_of?(self) }
  end

  # Do nothing, on notify, unless we've specifically included
  # a concern from concerns/communities to define some behaviour
  def notify!(event)
  end
end
