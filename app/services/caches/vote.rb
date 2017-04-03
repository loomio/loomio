class Caches::Vote < Caches::Base
  private

  def relation
    :motion
  end

  def collection_from(parents)
    super.most_recent.where(user: user)
  end
end
