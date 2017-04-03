class Caches::Vote < Caches::Base
  private

  def relation
    :motion
  end

  def collection_from(parents)
    super.latest.where(user: user)
  end
end
