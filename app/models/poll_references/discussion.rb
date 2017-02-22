class PollReferences::Discussion < PollReferences::Base
  def initialize(discussion)
    @discussion = discussion
  end

  def communities
    [@discussion.group.community]
  end

  def references
    [
      PollReference.new(reference: @discussion),
      PollReference.new(reference: @discussion.group)
    ]
  end
end
