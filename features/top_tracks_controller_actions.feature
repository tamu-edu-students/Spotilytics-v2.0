Feature: Top tracks hide/unhide edge cases
  As a Spotify user
  I want clear responses when hiding/unhiding tracks
  So I understand what happened

  Background:
    Given OmniAuth is in test mode
    And top tracks controller auth is bypassed
    And top tracks client is stubbed

  Scenario: Hide with invalid time range
    When I post hide track "t1" for time range "bad_range"
    Then I should see "Invalid time range."

  Scenario: Hide without user id
    Given top tracks session has no user
    When I post hide track "t1" for time range "short_term"
    Then I should see "Please sign in with Spotify first."

  Scenario: Hide succeeds
    Given hiding tracks will succeed
    When I post hide track "t1" for time range "short_term"
    Then I should see "Track hidden from short term list."

  Scenario: Hide fails due to limit
    Given hiding tracks will fail
    When I post hide track "t1" for time range "short_term"
    Then I should see "Could not hide track — you can hide at most 5 tracks per list."

  Scenario: Unhide without user id
    Given top tracks session has no user
    When I post unhide track "t1" for time range "short_term"
    Then I should be redirected to home

  Scenario: Unhide succeeds
    When I post unhide track "t1" for time range "short_term"
    Then I should be on the top tracks page
