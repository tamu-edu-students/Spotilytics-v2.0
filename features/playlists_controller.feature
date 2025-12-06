Feature: Playlists controller edge cases
  As a Spotify user
  I want clear feedback when managing playlists
  So I can recover from errors

  Background:
    Given OmniAuth is in test mode
    And I am authenticated for playlists

  Scenario: Invalid time range when creating playlist
    When I post create playlist with time range "bad"
    Then I should see "Invalid time range."

  Scenario: No tracks returned when creating playlist
    Given Spotify top tracks returns empty
    When I post create playlist with time range "short_term"
    Then I should see "No tracks available for Last 4 Weeks."

  Scenario: Unauthorized while creating playlist
    Given Spotify top tracks raises unauthorized
    When I post create playlist with time range "short_term"
    Then I should see "Session expired. Please sign in with Spotify again."

  Scenario: Error while creating playlist
    Given Spotify top tracks raises generic error
    When I post create playlist with time range "short_term"
    Then I should see "Couldn't create playlist on Spotify."

  Scenario: No URIs when creating from recommendations
    When I post create playlist from recommendations with uris ""
    Then I should see "No tracks to add to playlist."

  Scenario: Unauthorized when creating from recommendations
    Given Spotify create playlist raises unauthorized
    When I post create playlist from recommendations with uris "spotify:track:1"
    Then I should see "Session expired. Please sign in with Spotify again."

  Scenario: Error when creating from recommendations
    Given Spotify create playlist raises generic error
    When I post create playlist from recommendations with uris "spotify:track:2"
    Then I should see "Couldn't create playlist on Spotify"

  Scenario: Rename not allowed when owner mismatch
    When I patch rename playlist "pl1" name "New" owner "other"
    Then I should see "You can only rename playlists you own."

  Scenario: Rename unauthorized
    Given Spotify rename raises unauthorized
    When I patch rename playlist "pl1" name "New Name" owner "user-1"
    Then I should see "Session expired. Please sign in with Spotify again."

  Scenario: Rename error
    Given Spotify rename raises generic error
    When I patch rename playlist "pl1" name "New Name" owner "user-1"
    Then I should see "Couldn't rename playlist"

  Scenario: Description blank
    When I patch description playlist "pl1" description "  " owner "user-1"
    Then I should see "Playlist description cannot be blank."

  Scenario: Description not owner
    When I patch description playlist "pl1" description "Desc" owner "other"
    Then I should see "You can only update playlists you own."

  Scenario: Description unauthorized
    Given Spotify description raises unauthorized
    When I patch description playlist "pl1" description "Desc" owner "user-1"
    Then I should see "Session expired. Please sign in with Spotify again."

  Scenario: Description error
    Given Spotify description raises generic error
    When I patch description playlist "pl1" description "Desc" owner "user-1"
    Then I should see "Couldn't update playlist description"

  Scenario: Collaborative not owner
    When I patch collaborative playlist "pl1" flag "true" owner "other"
    Then I should see "You can only change collaboration for playlists you own."

  Scenario: Collaborative unauthorized
    Given Spotify collaborative raises unauthorized
    When I patch collaborative playlist "pl1" flag "true" owner "user-1"
    Then I should see "Session expired. Please sign in with Spotify again."

  Scenario: Collaborative error
    Given Spotify collaborative raises generic error
    When I patch collaborative playlist "pl1" flag "false" owner "user-1"
    Then I should see "Couldn't update playlist collaboration"

  Scenario: Remove track not found
    When I post add_song with remove track "missing"
    Then I should see "Song not found in list."

  Scenario: File upload missing
    When I post add_song file upload missing
    Then I should see "Choose a CSV file with columns like title, artist."

  Scenario: Malformed CSV upload
    Given CSV parsing raises malformed
    When I post add_song with bad csv
    Then I should see "Could not read that CSV file."

  Scenario: Bulk add with empty titles
    When I post add_song bulk with titles ""
    Then I should see "Enter at least one song title."

  Scenario: Single add with blank query
    When I post add_song single with query ""
    Then I should see "Enter a song name to search and add."

  Scenario: Single add no match
    Given Spotify search returns nothing
    When I post add_song single with query "Nope"
    Then I should see "No songs found for \"Nope\"."

  Scenario: Single add duplicate
    Given playlist builder has track "t1"
    Given Spotify search returns track "t1" named "Dup"
    When I post add_song single with query "Dup"
    Then I should see "is already in your list."

  Scenario: Single add unauthorized
    Given Spotify search raises unauthorized
    When I post add_song single with query "Song"
    Then I should see "Session expired. Please sign in with Spotify again."

  Scenario: Single add generic error
    Given Spotify search raises generic error
    When I post add_song single with query "Song"
    Then I should see "Couldn't search Spotify"

  Scenario: Create custom with no tracks
    When I post create_custom playlist with no tracks
    Then I should see "Add at least one song before creating your playlist."

  Scenario: Create custom unauthorized
    Given playlist builder has track "t2"
    Given Spotify create playlist raises unauthorized for custom
    When I post create_custom playlist with one track
    Then I should see "Session expired. Please sign in with Spotify again."

  Scenario: Create custom generic error
    Given playlist builder has track "t3"
    Given Spotify create playlist raises generic error for custom
    When I post create_custom playlist with one track
    Then I should see "Couldn't create playlist on Spotify"
