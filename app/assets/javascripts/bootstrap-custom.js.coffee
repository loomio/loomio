$ ->
  $(".tabs").tabs()
$ ->
  $("a[rel=popover]").popover offset: 10
$ ->
  $(".topbar-wrapper").dropdown()
$ ->
  $(".alert-message").alert()
$ ->
  domModal = $(".modal").modal(
    backdrop: true
    closeOnEscape: true
  )
  $(".open-modal").click ->
    domModal.toggle()
$ ->
	$(".btn").button "complete"
