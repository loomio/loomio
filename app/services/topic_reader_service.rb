class TopicReaderService
  def self.redeem(topic_reader:, actor:)
    return unless TopicReader.redeemable_by(actor).where(id: topic_reader.id).exists?
    topic_reader.update(user: actor, accepted_at: Time.zone.now)
  rescue ActiveRecord::RecordNotUnique
    TopicReader.find_by(topic_id: topic_reader.topic_id,
                            user_id: actor.id).
                    update(inviter_id: topic_reader.inviter_id,
                           accepted_at: Time.zone.now)
    topic_reader.destroy
  end
end
