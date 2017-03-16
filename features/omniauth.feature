Feature: Persona Authentication

Scenario: New user authenticates with omniauth before signing up
  Given I have authenticated with omniauth
  When I signup
  Then my omniauth_identity should be linked to my account

Scenario: Existing user authenticates with omniauth then links loomio account
  Given I signed up to loomio manually
  And I have authenticated with omniauth
  When I log in with my existing loomio account details
  Then my omniauth_identity should be linked to my account
