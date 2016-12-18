class PollReferences::Base
  def communities
    raise NotImplementedError.new
  end

  def references
    raise NotImplementedError.new
  end
end
