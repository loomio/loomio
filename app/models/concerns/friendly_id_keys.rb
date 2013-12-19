module FriendlyIdKeys
  def self.included(base)
    base.extend FriendlyId
    base.friendly_id :key
  end

  private

  def set_key
    unless self.key
      new_key = generate_key
      while self.class.find_by_key(new_key) != nil
        new_key = generate_key
      end
      self.key = new_key
    end
  end

  def generate_key
    ( ('a'..'z').to_a +
      ('A'..'Z').to_a +
          (0..9).to_a ).sample(self.class::KEY_LENGTH).join
  end

end