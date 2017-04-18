class Caches::Base
  attr_reader :user

  def initialize(parents:, user: nil)
    raise ArgumentError.new("User must be logged in in order to initialize this cache") if require_user? && user.blank? 
    @user = user
    store_in_cache(collection_from(parents))
  end

  def get_for(parent)
    set = cache.fetch(parent.id) { store_in_cache(default_values_for(parent)) }
    if user.present? then set.first else set.to_a end
  end

  private

  def require_user?
    false
  end

  def relation
    raise NotImplementedError.new
  end

  def cache
    @cache ||= Hash.new { |hash, key| hash[key] = Set.new }
  end

  def resource_class
    self.class.name.demodulize.constantize
  end

  def store_in_cache(models)
    Array(models).each { |model| cache[model.send(:"#{relation}_id")].add(model) }
  end

  def default_values_for(parent)
    collection_from(parent)
  end

  def collection_from(parents)
    if parents.present?
      resource_class.where(relation => parents)
    else
      resource_class.none
    end
  end

end
