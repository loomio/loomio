VisitorIdentifier = Struct.new(:cookies, :params) do
  def identify_for(poll)
    existing_visitor.tap do |visitor|
      visitor.assign_attributes(Hash(params).slice(:name, :email))
      visitor.community ||= poll.community_of_type(:public)
    end
  end

  private

  def existing_visitor
    Visitor.find_by(participation_token: cookies[:participation_token]) || Visitor.new
  end
end
