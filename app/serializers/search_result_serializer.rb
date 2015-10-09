class SearchResultSerializer < ActiveModel::Serializer
  embed :id, include: true
  attributes :id, :priority, :query, :discussion_blurb, :motion_blurb, :comment_blurb

  has_one :discussion
  has_one :motion, root: :proposals
  has_one :comment

  def id
    SecureRandom.hex(8)
  end

end
