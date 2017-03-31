class Caches::Stance < Caches::Base
  private

  def relation
    :poll
  end

  def collection_from(parents)
    super.latest.where(participant: user)
  end
end
