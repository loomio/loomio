class Webhook < ActiveRecord::Base
  belongs_to :discussion

  validates_presence_of :uri
  validates_presence_of :discussion
  validates_inclusion_of :kind, in: %w[slack]

  def headers
    {}
  end

end
