describe 'Notifications', ->
  it 'has all the notifications', ->
    browser.get('development/setup_all_notifications')

    unreadCount = ->
      element(By.css('.notifications__activity')).getText()

    openNotificationDropdown = ->
      element(By.css('.notifications__button')).click()

    notificationsDropdownText = ->
      element(By.css('.notifications__dropdown')).getText()


    expect(unreadCount()).toBe '8'
    openNotificationDropdown()

    expect(notificationsDropdownText()).toContain('added you to the group')
    expect(notificationsDropdownText()).toContain('approved your request')
    expect(notificationsDropdownText()).toContain('requested membership to')
    expect(notificationsDropdownText()).toContain('mentioned you in')
    expect(notificationsDropdownText()).toContain('replied to your comment')
    expect(notificationsDropdownText()).toContain('published an outcome')
    expect(notificationsDropdownText()).toContain('Proposal is closing')
    expect(notificationsDropdownText()).toContain('liked your comment')
