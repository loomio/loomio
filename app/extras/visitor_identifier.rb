VisitorIdentifier = Struct.new(:params) do
  def identify_for(poll)
    existing_visitor.tap do |v|
      v.assign_attributes(params.slice(:name, :email))
      v.assign_attributes(community: poll&.community_of_type(:public)) unless v.community
    end
  end

  private

  def existing_visitor
    Visitor.find_by(participation_token: params[:participation_token]) || Visitor.new
  end
end
