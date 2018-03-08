module LastNotified
  extend ActiveSupport::Concern

  included { attribute :last_announcement }

  def last_announcement
    {
      announced_at:      object.last_notified_at,
      announceable_id:   notified_model.id,
      announceable_type: notified_model.class.to_s
    }
  end

  private

  def include_last_notified?
    notified_model.present?
  end

  def notified_model
    Hash(scope)[:notified_model]
  end
end
