class Bookmark < ApplicationRecord
  include Discard::Model
  include PrettyUrlHelper

  belongs_to :bookmarkable, polymorphic: true
  belongs_to :user

  validates_presence_of :user, :bookmarkable
  validates_uniqueness_of :user_id, scope: [:bookmarkable_type, :bookmarkable_id]

  delegate :group, to: :bookmarkable
  delegate :group_id, to: :bookmarkable
  delegate :title_model, to: :bookmarkable

  alias :author :user

  def author_id
    user_id
  end

  # The poll the bookmarked item belongs to, when it is poll-related
  # (the poll itself, a vote on it, or its outcome). Nil for threads/comments.
  def poll
    case bookmarkable
    when Poll            then bookmarkable
    when Stance, Outcome then bookmarkable.poll
    end
  end

  # For poll-related items always use the poll's own title; otherwise the title
  # of the thread (or poll) the item belongs to.
  def title
    (poll || title_model).title
  end

  # The name of the person who authored the bookmarked item.
  def author_name
    bookmarkable.author.name
  end

  # The poll type (eg. 'proposal') when the bookmarked item is poll-related, so
  # the client can label it "Proposal by …" rather than a generic "Poll by …".
  def poll_type
    poll&.poll_type
  end

  # A relative path back to the bookmarked subject.
  def url
    polymorphic_path(bookmarkable)
  end
end
