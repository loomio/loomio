module Bookmarkable
  def self.included(base)
    base.has_many :bookmarks, as: :bookmarkable, dependent: :destroy
  end
end
