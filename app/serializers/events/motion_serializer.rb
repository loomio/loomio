class Events::MotionSerializer < Events::BaseSerializer
  has_one :discussion
  has_one :proposal, root: :proposals

  def include_eventable?
    false # because it will be serialized to 'motions' in the response, and we need 'proposals'
  end

  def proposal
    object.eventable
  end
end
