class DestroyUserWorker
  include Sidekiq::Worker

  def perform(user_id)
    ActiveRecord::Base.transaction do

      # invited_user_ids = []
      # invited_user_ids.concat DiscussionReader.where(inviter_id: user_id).pluck(:user_id)
      # invited_user_ids.concat Membership.where(inviter_id: user_id).pluck(:user_id)
      # invited_user_ids.concat Stance.where(inviter_id: user_id).pluck(:participant_id)
      # invited_user_ids = User.where(email_verified: false).where(id: invited_user_ids).pluck(:id)
      # Ahoy::Message.where(user_id: invited_user_ids).delete_all
      #
      # event_ids = Event.where(user_id: user_id).pluck(:id)
      # Notification.where(event_id: event_ids).delete_all
      # DiscussionReader.where(inviter_id: user_id).delete_all
      # Membership.where(inviter_id: user_id).delete_all
      # User.where(id: invited_user_ids).delete_all
      # Event.where(user_id: user_id).delete_all
      #
      #
      # User.find(user_id).destroy!
      # Ahoy::Message.where(user_id: user_id).delete_all
      # Ahoy::Visit.where(user_id: user_id).delete_all
      # Ahoy::Event.where(user_id: user_id).delete_all
      
      User.find(user_id).destroy!
      Ahoy::Message.where(user_id: user_id).delete_all
      Ahoy::Visit.where(user_id: user_id).delete_all
      Ahoy::Event.where(user_id: user_id).delete_all
    end
  end
end
