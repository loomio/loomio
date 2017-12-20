class API::AnnouncementsController < API::RestfulController
  def notified
    self.collection = Queries::Notified::Search.new(params.require(:q), current_user).results
    respond_with_collection serializer: NotifiedSerializer, root: false
  end

  def notified_default
    self.collection = Queries::Notified::Default.new(params.require(:kind), model_to_notify, current_user).results
    respond_with_collection serializer: NotifiedSerializer, root: false
  end

  private

  def model_to_notify
    case params[:kind]
    when 'discussion_edited', 'new_discussion'              then load_and_authorize(:discussion)
    when 'poll_created', 'poll_edited', 'poll_option_added' then load_and_authorize(:poll)
    when 'outcome_created'                                  then load_and_authorize(:outcome)
    else raise ActiveRecord::RecordNotFound.new
    end
  end
end
