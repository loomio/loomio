class PermittedParamsSerializer < ActiveModel::Serializer
  root false

  def object
    PermittedParams.new
  end

  %w[user vote motion proposal membership_request membership
   invitation group discussion discussion_reader comment
   attachment contact_message oauth_application].each do |kind|
    send :attribute, :"#{kind}_attributes", key: kind
  end

end
