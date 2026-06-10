module Bookmarkable
  def self.included(base)
    base.has_many :bookmarks, -> { joins(:user).where("users.deactivated_at": nil) }, dependent: :destroy, as: :bookmarkable
  end
end
