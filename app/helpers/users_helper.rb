module UsersHelper
  def get_hidden_class_for(avatar_preview, avatar_kind)
    hidden_class = ""
    hidden_class = "hidden" unless avatar_preview == avatar_kind
    return hidden_class
  end
end
