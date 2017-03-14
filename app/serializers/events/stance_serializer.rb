class Events::StanceSerializer < Events::BaseSerializer
  # don't look at eventable because stances use the polymorphic
  # 'participant' association, which will be serialized with the stance
  def actor
    object.user
  end
end
