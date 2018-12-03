module Loomio
  module Version
    def self.current
      [`git show -s --format=%ci`.split(' ').first,
      `git rev-parse HEAD`.strip.first(7)].join("-")
    end
  end
end
