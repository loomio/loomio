ActiveAdmin.register FeedbackResponse do
  actions :index
  filter :user_id
  filter :user_agent
  filter :version

  scope :all
  scope :unprocessed, default: true
  scope :processed

  batch_action :process do
    collection.unprocessed.update_all(processed: true)
    redirect_to admin_feedback_responses_path
  end

  member_action :process_feedback do
    resource.update processed: true
    redirect_to admin_feedback_responses_path
  end

  index do
    selectable_column
    column :feedback
    column :user_name
    column :user_email
    column :version
    column :user_agent
    actions do |feedback_response|
      link_to('Process', process_feedback_admin_feedback_response_path(feedback_response)) unless feedback_response.processed
    end
  end

end
