class DiscussionSerializer < ActiveModel::Serializer

  def self.attributes_from_reader(*attrs)
    attrs.each do |attr|
      case attr
      when :discussion_reader_id then define_method attr, -> { reader.id }
      else                            define_method attr, -> { reader.send(attr) }
      end
      define_method :"include_#{attr}?", -> { reader.present? }
    end
    attributes *attrs
  end

  embed :ids, include: true
  attributes :id,
             :key,
             :title,
             :description,
             :last_item_at,
             :last_comment_at,
             :last_activity_at,
             :created_at,
             :updated_at,
             :items_count,
             :salient_items_count,
             :comments_count,
             :private,
             :archived_at,
             :created_at,
             :updated_at,
             :first_sequence_id,
             :last_sequence_id

  attributes_from_reader :discussion_reader_id,
                         :discussion_reader_volume,
                         :last_read_at,
                         :read_comments_count,
                         :read_items_count,
                         :read_salient_items_count,
                         :last_read_sequence_id,
                         :participating,
                         :starred

  has_one :author, serializer: UserSerializer, root: 'users'
  has_one :group, serializer: GroupSerializer, root: 'groups'
  has_one :active_proposal, serializer: MotionSerializer, root: 'proposals'
  has_one :active_proposal_vote, serializer: VoteSerializer, root: 'votes'

  def include_active_proposal_vote?
    reader.present? && active_proposal.present?
  end

  def active_proposal_vote
    active_proposal.votes.find_by(user_id: reader.user_id)
  end

  def active_proposal
    @active_proposal ||= object.current_motion
  end

  def reader
    @reader ||= scope[:reader_cache].get_for(object) if scope[:reader_cache]
  end

  def scope
    super || {}
  end

end
