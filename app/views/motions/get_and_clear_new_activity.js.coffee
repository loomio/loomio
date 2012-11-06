graph = $(<%= "'#graph_#{@motion.id}'" %>).parent()
graph.removeData('popover')
graph.popover ({
  placement: "right",
  trigger: "manual",
  title: "<%= escape_javascript render 'discussions/graph_preview_pop_over_title', :motion => @motion %>",
  content: "<%= escape_javascript render 'discussions/graph_preview_pop_over', :motion => @motion, :user => @user, :motion_activity =>  @motion_activity%>"
})
graph.popover('toggle')
graph.find('.activity-count').hide() if (<%= user_signed_in? %>)
