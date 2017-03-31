class Caches::Base

  def initialize(user:, parents:, only_owned_by_user: false)
    return unless parents.any?

    @user, @only_owned_by_user = user, only_owned_by_user
    store_in_cache(collection_from(parents))
  end

  def get_for(parent)
    set = cache.fetch(parent.id) { store_in_cache(default_values_for(parent)) }
    if only_owned_by_user then set.first else set.to_a end
  end

  private

  def relation
    raise NotImplementedError.new
  end

  def user_column
    :user
  end

  # override this to force (or de-enforce) a particular cache to only look
  # at models owned by the user
  def only_owned_by_user
    @only_owned_by_user
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
    resource_class.where(relation => parents).tap do |relation|
      relation = relation.where(user_column => @user) if only_owned_by_user
    end
  end

end
