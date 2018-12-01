module ReadableUnguessableUrls
  extend ActiveSupport::Concern

  KEY_LENGTH = 8

  included do |base|
    base.extend FriendlyId
    base.send :friendly_id, :key, use: [:finders]
    base.send :before_validation, :set_key
    base.send :validates, :key, presence: true
  end

  private
  def set_key
    if self.key.blank?
      self.key = generate_unique_key
    end
  end

  def generate_unique_key
    begin
      key = generate_key
    end while self.class.where(key: key).exists? or key.match(/^\d+$/)
    key
  end

  def generate_key
    (('a'..'z').to_a +
     ('A'..'Z').to_a +
     (0..9).to_a ).sample(KEY_LENGTH).join
  end
end
