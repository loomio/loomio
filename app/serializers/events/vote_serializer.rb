class Events::VoteSerializer < Events::BaseSerializer
  has_one :discussion
end
