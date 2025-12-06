Feature: Pages controller error handling
  As a Spotify user
  I want friendly fallbacks on errors
  So the app stays stable

  Background:
    Given OmniAuth is in test mode
    And pages controller client defaults are stubbed

  Scenario: Clearing cache unauthorized
    Given spotify clear cache raises unauthorized
    When I visit "/clear"
    Then I should see "You must log in with spotify to refresh your data."

  Scenario: Dashboard unauthorized mid fetch
    Given spotify top artists raises unauthorized for dashboard
    When I visit "/dashboard"
    Then I should see "You must log in with spotify to access the dashboard."

  Scenario: Dashboard generic error shows empty data
    Given spotify top artists raises generic error for dashboard
    When I visit "/dashboard"
    Then I should see "We were unable to load your Spotify data right now. Please try again later."

  Scenario: Top artists insufficient scope
    Given spotify top artists raises insufficient scope
    When I visit "/top-artists"
    Then I should be redirected to login

  Scenario: Top artists generic error
    Given spotify top artists raises generic error
    When I visit "/top-artists"
    Then I should see "We were unable to load your top artists from Spotify. Please try again later."

  Scenario: Library error fallback
    Given spotify playlists raises error
    When I visit "/library"
    Then I should see "We were unable to load your playlists from Spotify. Please try again later."

  Scenario: View profile unauthorized
    Given spotify profile raises unauthorized
    When I visit "/view-profile"
    Then I should see "You must log in with spotify to view your profile."
