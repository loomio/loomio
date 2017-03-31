class Caches::Base
  attr_reader :user, :single_entry

  def initialize(user:, parents:, single_entry: false)
    @user         = user
    @single_entry = single_entry
    store_in_cache(collection_from(parents))
  end

  def get_for(parent)
    set = cache.fetch(parent.id) { store_in_cache(default_values_for(parent)) }
    if single_entry then set.first else set.to_a end
  end

  private

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
