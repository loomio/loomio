class MotionDecorator < ApplicationDecorator
  decorates :motion

  def display_facilitator_options
      if model.phase == 'discussion'
        phase_style = "color:blue"
        link_route = h.open_motion_voting_path
        link_confirm = false
        link_title = "open voting"
        link_style = "color: blue"
      elsif model.phase == 'closed'
        phase_style = "color:red"
        link_route = h.open_motion_voting_path
        link_confirm false
        link_title "open voting"
        link_style "color: red"
      elsif model.phase == 'voting'
        phase_style = "color:green"
        link_route = h.close_motion_voting_path
        link_confirm = "Are you sure you want to close this motion?"
        link_title = "close voting"
        link_style = "color: green"
      end
    if (model.author == h.current_user || model.facilitator == h.current_user)
      content = h.link_to ("[" + model.phase + "]"), link_route,
                  confirm: link_confirm,
                  title: link_title,
                  style: link_style,
                  method: :post
    else
      h.content_tag :span, "[" + model.phase + "]", class: "none"
    end
  end
end
