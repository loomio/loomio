module.exports = new class GroupsHelper
  load: ->
    browser.get('http://localhost:8000/angular_support/setup_group')

  membersList: ->
    element(By.css('.group-member-list'))