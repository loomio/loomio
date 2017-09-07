module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    delegate :poll, to: :item
    delegate :discussion, to: :item

    def mentionable
      self.item
    end
  end
end
