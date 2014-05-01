Feature: User added to group notification
  As a user
  So that I am aware when I have been added to a group (or subgroup)
  I want to see a notification

  @javascript
  Scenario: User sees added to group notification
    Given I am an existing Loomio user
    And a coordinator adds me to a group I don't already belong to
    Then I should get an added to group notificaiton

 ### note : because the group add_member method has not event bound to it (the event is triggered in controllers), this test only checks that event generates a notification
