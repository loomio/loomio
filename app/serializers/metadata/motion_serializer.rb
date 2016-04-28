class Metadata::MotionSerializer < ActiveModel::Serializer
  attributes :title, :description
  root false

  def title
    object.name
  end

end
