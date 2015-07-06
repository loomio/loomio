class Popolo::VoteSerializer < ActiveModel::Serializer
  attributes :voter_id, :option

  def voter_id
    object.author.name.parameterize
  end

  def option
    object.position
  end
end
