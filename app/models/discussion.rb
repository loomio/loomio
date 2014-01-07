class Discussion < ActiveRecord::Base
  PER_PAGE = 50
  paginates_per PER_PAGE

  scope :archived, -> { where('archived_at is not null') }
  scope :published, -> { where(archived_at: nil) }

  scope :active_since, lambda {|some_time| where('created_at >= ? or last_comment_at >= ?', some_time, some_time)}
  scope :order_by_latest_comment, order('last_comment_at DESC')
  scope :last_comment_after, lambda {|time| where('last_comment_at > ?', time)}

  validates_presence_of :title, :group, :author
  validates :title, :length => { :maximum => 150 }
  validates_inclusion_of :uses_markdown, :in => [true,false]

  has_paper_trail :only => [:title, :description]

  belongs_to :group, :counter_cache => true
  belongs_to :author, class_name: 'User'
  has_many :motions, :dependent => :destroy
  has_many :votes, through: :motions
  has_many :comments, :dependent => :destroy
  has_many :comment_likes, :through => :comments, :source => :comment_votes
  has_many :commenters, :through => :comments, :source => :user, :uniq => true
  has_many :events, :as => :eventable, :dependent => :destroy
  has_many :items, class_name: 'Event', include: :eventable, order: 'created_at ASC'
  has_many :discussion_readers

  include PgSearch
  pg_search_scope :search, against: [:title, :description],
    using: {tsearch: {dictionary: "english"}}

  delegate :users, :to => :group, :prefix => :group
  delegate :full_name, :to => :group, :prefix => :group
  delegate :email, :to => :author, :prefix => :author
  delegate :name_and_email, :to => :author, prefix: :author

  before_create :set_last_comment_at

  def as_read_by(user)
    if user.blank?
      new_discussion_reader_for(nil)
    elsif joined_to_discussion_reader?
      joined_or_new_discussion_reader_for(user)
    else
      find_or_new_discussion_reader_for(user)
    end
  end

  def add_comment(author, body, options = {})
    options[:body] = body
    comment = Comment.new(options)
    comment.author = author
    comment.discussion = self
    DiscussionService.add_comment(comment)
    comment
  end

  def archive!
    self.update_attribute(:archived_at, DateTime.now)
  end

  def archived?
    archived_at.present?
  end

  def voting_motions
    motions.voting
  end

  def closed_motions
    motions.closed
  end

  def group_users_without_discussion_author
    group.users.where(User.arel_table[:id].not_eq(author_id))
  end

  def current_motion_closing_at
    current_motion.closing_at
  end

  def current_motion
    voting_motions.last
  end

  def number_of_comments_since(time)
    comments.where('comments.created_at > ?', time).count
  end

  def viewed!
    Discussion.increment_counter(:total_views, id)
  end

  def participants
    participants = commenters.all
    participants << author
    participants += motion_authors
    participants.uniq
  end

  def motion_authors
    User.find(motions.pluck(:author_id))
  end

  def has_previous_versions?
    (previous_version && previous_version.id)
  end

  def last_versioned_at
    if has_previous_versions?
      previous_version.version.created_at
    else
      created_at
    end
  end

  def activity
    items
  end

  def set_description!(description, uses_markdown, user)
    self.description = description
    self.uses_markdown = uses_markdown
    save!
    fire_edit_description_event(user)
  end

  def set_title!(title, user)
    self.title = title
    save!
    fire_edit_title_event(user)
  end

  def delayed_destroy
    self.update_attribute(:is_deleted, true)
    self.delay.destroy
  end

  def most_recent_comment
    comments.order("created_at DESC").first
  end

  def refresh_last_comment_at!
    if comments.exists?
      last_comment_time = most_recent_comment.created_at
    else
      last_comment_time = created_at
    end
    update_attribute(:last_comment_at, last_comment_time)
  end

  private

    def set_last_comment_at
      self.last_comment_at ||= Time.now
    end

    def joined_or_new_discussion_reader_for(user)
      if self[:viewer_user_id].present?
        unless user.id == self[:viewer_user_id].to_i
          raise "joined for wrong user"
        end
        DiscussionReader.load_from_joined_discussion(self)
      else
        new_discussion_reader_for(user)
      end
    end


    def joined_to_discussion_reader?
      self['joined_to_discussion_reader'] == '1'
    end

    def find_or_new_discussion_reader_for(user)
      if self.discussion_readers.where(:user_id => user.id).exists?
        self.discussion_readers.where(user_id: user.id).first
      else
        discussion_reader = self.discussion_readers.build
        discussion_reader.discussion = self
        discussion_reader.user = user
        discussion_reader
      end
    end

    def new_discussion_reader_for(user)
      discussion_reader = DiscussionReader.new
      discussion_reader.discussion = self
      discussion_reader.user = user
      discussion_reader
    end

    def fire_edit_title_event(user)
      Events::DiscussionTitleEdited.publish!(self, user)
    end

    def fire_edit_description_event(user)
      Events::DiscussionDescriptionEdited.publish!(self, user)
    end
end
