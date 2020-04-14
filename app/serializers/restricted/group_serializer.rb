class Restricted::GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :type, :name, :logo_url_medium

  def logo_url_medium
    object.logo.url(:medium)
  end

  def include_logo_url_medium?
    object.type == "Group" && object.logo.present?
  end
end
