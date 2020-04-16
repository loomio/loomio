class Restricted::GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :name, :logo_url_medium

  def logo_url_medium
    object.logo.url(:medium)
  end

  def include_logo_url_medium?
    object.logo.present?
  end
end
