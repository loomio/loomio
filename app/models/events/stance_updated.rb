class Events::StanceUpdated < Events::StanceCreated
  def self.publish!(stance)
    super stance,
          user: stance.participant.presence,
          discussion: stance.add_to_discussion? : stance.poll.discussion : nil
  end
end
