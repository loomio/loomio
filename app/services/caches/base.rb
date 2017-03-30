class Caches::Base

  def initialize(user:, parents:, only_owned_by_user: false)
    return unless parents.any?

    @user, @only_owned_by_user = user, only_owned_by_user
    store_in_cache(parents)
  end

  def get_for(model)
    set = cache.fetch(model.id) { store_in_cache(model) }
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

  def store_in_cache(parents)
    collection_from(parents).each { |model| cache[model.send(:"#{relation}_id")].add(model) }
  end

  def store(model)
    cache[model.send(:"#{relation}_id")].add(model)
  end

  def collection_from(parents)
    resource_class.where(relation => parents).tap do |relation|
      relation = relation.where(user_column => @user) if only_owned_by_user
    end
  end
end
