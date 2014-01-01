class EmailIntegration < ActiveRecord::Base
  TOKEN_LENGTH = 22

  belongs_to :user
  belongs_to :email_integrable, polymorphic: true

  validates_presence_of :user, :email_integrable, :token
  validates_uniqueness_of :token

  before_validation :set_token

  private

  def set_token
    if self.token.blank?
      self.token = generate_unique_token
    end
  end

  def generate_unique_token
    begin
      token = generate_token
    end while self.class.where(token: token).exists?
      token
  end

 def generate_token
   (('a'..'z').to_a +
    ('A'..'Z').to_a +
    (0..9).to_a ).sample(TOKEN_LENGTH).join
 end

end
