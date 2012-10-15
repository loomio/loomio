# Show revision history
$('#descrition-revision-history').modal
$('#descrition-revision-history').modal('show')
$("#descrition-revision-history").html("<%= escape_javascript(render 'description_history', model: @discussion, model_name: 'discussion')%>")
