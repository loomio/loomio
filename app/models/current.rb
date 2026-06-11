class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user

  def session=(session)
    super
    self.user = session&.user
  end
end
