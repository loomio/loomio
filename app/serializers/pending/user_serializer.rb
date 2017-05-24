class Pending::UserSerializer < Pending::BaseSerializer
  private

  def user
    object
  end
end
