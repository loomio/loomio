class SearchResultSerializer < ActiveModel::Serializer
  embed :id, include: true
  attributes :id, :key, :description, :group_id, :title, :last_activity_at, :rank, :query, :blurb

  def id
    SecureRandom.hex(8)
  end

end
