module HasNotifications
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :subject, dependent: :destroy
  end
end
