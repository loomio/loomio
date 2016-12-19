class PollReferences::Base
  def self.for(model)
    "PollReferences::#{model.class}".constantize.new(model)
  rescue NameError
    PollReferences::Null.new
  end

  def communities
    raise NotImplementedError.new
  end

  def references
    raise NotImplementedError.new
  end
end
