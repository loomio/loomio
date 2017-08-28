class Notified::Invitation < Notified::Base
  def id
    nil
  end

  def type
    "Invitation"
  end

  def title
    model
  end
end
