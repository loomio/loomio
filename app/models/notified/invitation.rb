class Notified::Invitation < Notified::Base
  def id
    model
  end

  def type
    "Invitation"
  end

  def title
    model
  end
end
