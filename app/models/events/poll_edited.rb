class Events::PollEdited < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions

  def self.publish!(poll, actor)
    super(poll, user: actor)
  end
end
