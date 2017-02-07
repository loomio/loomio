module MakesAnnouncements
  extend ActiveSupport::Concern

  attr_writer :make_announcement

  def make_announcement
    !!@make_announcement
  end
  
end
