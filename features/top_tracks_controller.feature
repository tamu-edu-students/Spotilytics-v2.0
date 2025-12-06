Feature: Top tracks controller behaviors
  As a Spotify user
  I want resilient top tracks handling
  So I see helpful errors and correct lists

  Background:
    Given OmniAuth is in test mode
    And I am signed in with Spotify

  Scenario: Showing an error when Spotify fails
    Given Spotify top tracks API raises a generic error
    When I visit "/top_tracks"
    Then I should see "Couldn't load your top tracks from Spotify."

  Scenario: Redirect when Spotify returns unauthorized mid-request
    Given Spotify top tracks API raises unauthorized
    When I visit "/top_tracks"
    Then I should see "Session expired. Please sign in with Spotify again."

  Scenario: Filtering hidden tracks and logging missing hidden ids
    Given my hidden top tracks are:
      | time_range  | track_id |
      | short_term  | h1       |
      | medium_term | m1       |
    And Spotify top tracks API returns sample tracks for filtering
    When I visit "/top_tracks"
    Then I should not see "Hidden Short"
    And I should see "Visible Short"
