class Caches::Stance < Caches::Base
  private

  def relation
    :poll
  end

  def user_column
    :participant
  end
end
