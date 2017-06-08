module NoForbiddenEmails
  extend ActiveSupport::Concern
  FORBIDDEN_EMAIL_ADDRESSES = [ENV.fetch('DECIDE_EMAIL', "decide@#{ENV['CANONICAL_HOST']}")]

  included do
     validates_exclusion_of :email, in: FORBIDDEN_EMAIL_ADDRESSES
  end
end
