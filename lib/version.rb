module Loomio
  module Version
    def self.current
      [MAJOR, MINOR, PATCH, PRE].reject(&:nil?).join('.')
    end
  end
end
