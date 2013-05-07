Feature:
  Wellington Council Thing

  Scenario: User loads WOC index
    Given there is a WocOptions record
    When I load woc index
    Then I should see the woc index
