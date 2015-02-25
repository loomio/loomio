class API::FayeController < API::BaseController
  def subscribe
    if discussion_channel? and current_user.can?(:show, discussion)
      render json: PrivatePub.subscription(channel: params[:channel], server: ENV['FAYE_URL'])
    else
      puts "unrecognised channel: #{params[:channel]}"
    end
  end

  def channel_parts
    params[:channel].split('/').reject {|i| i.blank?}
  end

  def discussion_channel?
    channel_parts.first.split('-').first == 'discussion'
  end

  def discussion_key
    channel_parts.first.split('-').last
  end

  def discussion
    Discussion.find_by(key: discussion_key)
  end

  def who_am_i
    render json: current_user, serializer: UserSerializer
  end
end
