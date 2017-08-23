class Memos::ReactionDestroyed < Memo
  def initialize(reaction:)
    @reaction = reaction
  end

  def kind
    'reaction_destroyed'
  end

  def data
    ReactionSerializer.new(@reaction, root: :reactions).as_json
  end

  def message_channel
    @reaction.message_channel
  end
end
