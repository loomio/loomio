class Caches::Reaction < Caches::Base
  private

  def relation
    :reactable
  end

  def collection_from(parents)
    if parents.present?
      resource_class.includes(:user).where(relation => parents)
    else
      resource_class.none
    end
  end
end
