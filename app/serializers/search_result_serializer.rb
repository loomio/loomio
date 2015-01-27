class SearchResultSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :priority, :query, :result_id, :result_type

  has_one :result, polymorphic: true
  has_one :proposal, serializer: MotionSerializer, root: 'proposals'

  def result_id
    result.id
  end

  #                     I am a crusty crustacean!
  #  /==>           _ /
  # //      >>>/---{_
  # \==::[[[[|:     _
  #         >>>\---{_
  #
  # (Maybe we should consider moving the motion/proposal line a little.)

  def result_type
    case result
    when Motion then 'Proposal'
    else result.class.to_s
    end
  end

  def proposal
    result
  end

  def include_proposal?
    result_type == 'Proposal'
  end

  def include_result?
    !include_proposal?
  end

end
