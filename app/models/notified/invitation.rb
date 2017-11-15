def Notified::Invitation < Notified::Base
  def id
    model
  end

  def type
    "Invitation".freeze
  end

  def title
    model
  end
end
