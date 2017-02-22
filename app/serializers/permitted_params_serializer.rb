class PermittedParamsSerializer < ActiveModel::Serializer
  root false

  def object
    PermittedParams.new
  end

  PermittedParams::MODELS.each do |kind|
    send :attribute, :"#{kind}_attributes", key: kind
  end

end
