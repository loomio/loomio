module ForceSslHelper
  def self.included(base)
    base.force_ssl if ENV['FORCE_SSL']
  end
end
