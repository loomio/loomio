class Caches::Stance < Caches::Base
  private

  def relation
    :poll
  end

  def collection_from(parents)
    super.where(participant: user)
  end
end
