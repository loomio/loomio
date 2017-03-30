class Caches::Vote < Caches::Base
  private

  def relation
    :motion
  end
end
