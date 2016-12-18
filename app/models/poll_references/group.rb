class PollReferences::Group < PollReferences::Base
  def initialize(group)
    @group = group
  end

  def communities
    [@group.community]
  end

  def references
    [PollReference.new(reference: @group)]
  end
end
