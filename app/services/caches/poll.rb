class Caches::Poll < Caches::Base
  private

  def relation
    :discussion
  end

  def collection_from(parents)
    super.active
  end
end
