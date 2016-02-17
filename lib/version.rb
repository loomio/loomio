module Loomio
  module Version
    def self.reload
      [:major, :minor, :patch, :pre].each do |type|
        remove_const type.upcase
        load [:lib, :version, "#{type}.rb"].join('/')
      end
    end

    def self.current
      [MAJOR, MINOR, PATCH, PRE].reject(&:nil?).join('.')
    end
  end
end
