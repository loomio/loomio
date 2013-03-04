$ ->
  preventPageScrollingFromDropdownLists($('#notification-dropdown-items'))
  preventPageScrollingFromDropdownLists($('#group-dropdown-items'))

preventPageScrollingFromDropdownLists = (listType) ->
  # Prevent scrolling on notifications box from scrolling down the rest of the page
  dropdownList = listType
  height = dropdownList.height()
  dropdownList.bind('mousewheel', (e, d) ->
    scrollHeight = dropdownList.get(0).scrollHeight
    if ((this.scrollTop == (scrollHeight - height) && d < 0) || (this.scrollTop == 0 && d > 0))
      e.preventDefault()
  )