module PublicIndexHelper

  def first_page?
    params[:page] == nil || params[:page] == "1"
  end
  
  def public_index_path(model)
    eval "public_#{model.pluralize}_path"
  end
  
  def subtitle_for(model)
    case model.class.to_s.downcase.to_sym
      when :discussion then link_to model.group.name, model.group
      when :group then      nil
    end
  end

end



