module EmailAddressBlacklist
  extend ActiveSupport::Concern

  included do
     validates_exclusion_of :email, :in => ["decide@#{ENV['CANONICAL_HOST']}"]
  end
end
