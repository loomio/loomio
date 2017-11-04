class Full::StanceSerializer < StanceSerializer

  # always serialize participant, even for anonymous polls
  def include_participant?
    true
  end
end
