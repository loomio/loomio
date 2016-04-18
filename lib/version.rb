module Loomio
  module Version
    def self.current
      [major, minor, patch].join('.')
    end

    def self.major
      File.read("lib/version/major").strip
    end

    def self.minor
      File.read("lib/version/minor").strip
    end

    def self.patch
      File.read("lib/version/patch").strip
    end
  end
end
