class InboxController < BaseController
  def index
    load_inbox
    render layout: false if request.xhr?
  end

  def size
    load_inbox
    size = @inbox.items_count

    if size > 0
      render text: size
    else
      render text: ''
    end
  end

  def preferences
    @inbox_preferences_form = InboxPreferencesForm.new(current_user)
  end

  def update_preferences
    @inbox_preferences_form = InboxPreferencesForm.new(current_user)
    @inbox_preferences_form.submit(params)
    redirect_to inbox_path
  end

  def mark_as_read
    if params.has_key?(:discussion_ids)
      ids = params[:discussion_ids].split('x').map(&:to_i)
      current_user.discussions.where(id: ids).each do |discussion|
        discussion.as_read_by(current_user).viewed!
      end
    end

    if params.has_key?(:motion_ids)
      ids = params[:motion_ids].split('x').map(&:to_i)
      current_user.motions.where(id: ids).each do |motion|
        motion.as_read_by(current_user).viewed!
      end
    end

    redirect_back_or_head_ok
  end
  
  def mark_all_as_read
    @inbox = Inbox.new(current_user)
    group = current_user.groups.find(params[:id])
    @inbox.clear_all_in_group(group)
    redirect_back_or_head_ok
  end

  def unfollow
    item = load_resource_from_params
    @inbox.unfollow!(item)
    redirect_back_or_head_ok
  end

  private
  def redirect_back_or_head_ok
    if request.xhr?
      load_inbox
      size = @inbox.items_count
      size = '' if size == 0
      render js: "$('#inbox-count').text('#{size}')"
    else
      redirect_to inbox_path
    end
  end

  def load_inbox
    unless @inbox
      @inbox = Inbox.new(current_user)
      @inbox.load
    end
  end

  def load_resource_from_params
    class_name = params[:class]
    id = params[:id]

    if class_name == 'Discussion'
      current_user.discussions.find_by_id(id)
    elsif class_name == 'Motion'
      current_user.motions.find_by_id(id)
    end
  end

end
