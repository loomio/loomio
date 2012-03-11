module ArrayExtensions
  def flatten_once
    inject([]) { |v, e| v.concat(e)}
  end

  def to_hash
    Hash[*self.flatten_once]
  end
end

Array.send(:include, ArrayExtensions)