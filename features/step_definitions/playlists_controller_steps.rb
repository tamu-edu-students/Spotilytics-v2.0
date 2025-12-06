require "ostruct"
require "stringio"

Given("I am authenticated for playlists") do
  visit root_path
  sess = page.driver.request.session
  sess[:spotify_user] = { "id" => "user-1", id: "user-1" }
  sess[:spotify_token] = "token"
  allow_any_instance_of(PlaylistsController).to receive(:require_spotify_auth!).and_return(true)
  allow_any_instance_of(ApplicationController).to receive(:require_spotify_auth!).and_return(true)
  allow_any_instance_of(PagesController).to receive(:require_spotify_auth!).and_return(true)
  allow_any_instance_of(TopTracksController).to receive(:require_spotify_auth!).and_return(true)
  allow_any_instance_of(RecommendationsController).to receive(:require_spotify_auth!).and_return(true)
  allow_any_instance_of(PlaylistsController).to receive(:ensure_spotify_user_id).and_return("user-1")

  @default_client ||= instance_double(
    SpotifyClient,
    current_user_id: "user-1",
    top_tracks: [ OpenStruct.new(id: "t1") ],
    top_artists: [],
    create_playlist_for: "pl-1",
    add_tracks_to_playlist: true,
    update_playlist_name: true,
    update_playlist_description: true,
    update_playlist_collaborative: true,
    search_tracks: [],
    user_playlists_all: [],
    clear_user_cache: true
  )
  allow(SpotifyClient).to receive(:new).and_return(@default_client)
end

# -------- create playlist stubs --------
Given("Spotify top tracks returns empty") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:top_tracks).and_return([])
end

Given("Spotify top tracks raises unauthorized") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:top_tracks).and_raise(SpotifyClient::UnauthorizedError.new("expired"))
end

Given("Spotify top tracks raises generic error") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:top_tracks).and_raise(SpotifyClient::Error.new("oops"))
end

Given("Spotify create playlist raises unauthorized") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:create_playlist_for).and_raise(SpotifyClient::UnauthorizedError.new("expired"))
  allow(mock).to receive(:add_tracks_to_playlist)
  allow(mock).to receive(:top_tracks).and_return([ OpenStruct.new(id: "t1") ])
  allow(mock).to receive(:top_artists).and_return([])
  allow(mock).to receive(:search_tracks).and_return([])
end

Given("Spotify create playlist raises generic error") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:create_playlist_for).and_raise(SpotifyClient::Error.new("fail"))
  allow(mock).to receive(:add_tracks_to_playlist)
  allow(mock).to receive(:top_tracks).and_return([ OpenStruct.new(id: "t1") ])
  allow(mock).to receive(:top_artists).and_return([])
  allow(mock).to receive(:search_tracks).and_return([])
end

# -------- rename / description / collaborative stubs --------
Given("Spotify rename raises unauthorized") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:update_playlist_name).and_raise(SpotifyClient::UnauthorizedError.new("expired"))
  allow(mock).to receive(:clear_user_cache)
  allow(mock).to receive(:user_playlists_all).and_return([])
end

Given("Spotify rename raises generic error") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:update_playlist_name).and_raise(SpotifyClient::Error.new("boom"))
  allow(mock).to receive(:clear_user_cache)
  allow(mock).to receive(:user_playlists_all).and_return([])
end

Given("Spotify description raises unauthorized") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:update_playlist_description).and_raise(SpotifyClient::UnauthorizedError.new("expired"))
  allow(mock).to receive(:clear_user_cache)
  allow(mock).to receive(:user_playlists_all).and_return([])
end

Given("Spotify description raises generic error") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:update_playlist_description).and_raise(SpotifyClient::Error.new("fail"))
  allow(mock).to receive(:clear_user_cache)
  allow(mock).to receive(:user_playlists_all).and_return([])
end

Given("Spotify collaborative raises unauthorized") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:update_playlist_collaborative).and_raise(SpotifyClient::UnauthorizedError.new("expired"))
  allow(mock).to receive(:clear_user_cache)
  allow(mock).to receive(:user_playlists_all).and_return([])
end

Given("Spotify collaborative raises generic error") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:update_playlist_collaborative).and_raise(SpotifyClient::Error.new("fail"))
  allow(mock).to receive(:clear_user_cache)
  allow(mock).to receive(:user_playlists_all).and_return([])
end

# -------- add_song stubs --------
Given("CSV parsing raises malformed") do
  allow(CSV).to receive(:new).and_raise(CSV::MalformedCSVError.new("bad", 1))
end

Given("Spotify search returns nothing") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:search_tracks).and_return([])
end

Given("Spotify search returns track {string} named {string}") do |id, name|
  mock = instance_double(SpotifyClient)
  track = OpenStruct.new(id: id, name: name, artists: "A")
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:search_tracks).and_return([ track ])
end

Given("Spotify search raises unauthorized") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:search_tracks).and_raise(SpotifyClient::UnauthorizedError.new("expired"))
end

Given("Spotify search raises generic error") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:current_user_id).and_return("user-1")
  allow(mock).to receive(:search_tracks).and_raise(SpotifyClient::Error.new("fail"))
end

Given("playlist builder has track {string}") do |id|
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  @existing_tracks = { "1" => { id: id, name: "Existing", artists: "A" } }
  allow_any_instance_of(PlaylistsController).to receive(:add_track_to_builder) do |_, track|
    track.id.to_s == id.to_s ? false : true
  end
end

Given("Spotify create playlist raises unauthorized for custom") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:create_playlist_for).and_raise(SpotifyClient::UnauthorizedError.new("expired"))
  allow(mock).to receive(:add_tracks_to_playlist)
end

Given("Spotify create playlist raises generic error for custom") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:create_playlist_for).and_raise(SpotifyClient::Error.new("fail"))
  allow(mock).to receive(:add_tracks_to_playlist)
end

# -------- actions --------
When("I post create playlist with time range {string}") do |range|
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  page.driver.submit :post, create_playlist_path, { time_range: range }
end

When("I post create playlist from recommendations with uris {string}") do |uris|
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  list = uris.split(",").map(&:strip).reject(&:blank?)
  page.driver.submit :post, create_playlist_from_recommendations_path, { uris: list }
end

When("I patch rename playlist {string} name {string} owner {string}") do |pl, name, owner|
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  page.driver.submit :patch, rename_playlist_path(pl), { name: name, owner_id: owner }
end

When("I patch description playlist {string} description {string} owner {string}") do |pl, desc, owner|
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  page.driver.submit :patch, playlist_description_path(pl), { description: desc, owner_id: owner }
end

When("I patch collaborative playlist {string} flag {string} owner {string}") do |pl, flag, owner|
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  page.driver.submit :patch, playlist_collaborative_path(pl), { collaborative: flag, owner_id: owner }
end

When("I post add_song with remove track {string}") do |tid|
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  page.driver.submit :post, add_playlist_song_path, { remove_track_id: tid }
end

When("I post add_song file upload missing") do
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  page.driver.submit :post, add_playlist_song_path, { file_add: "1" }
end

When("I post add_song with bad csv") do
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  upload = Rack::Test::UploadedFile.new(StringIO.new("bad"), "text/csv", original_filename: "bad.csv")
  page.driver.submit :post, add_playlist_song_path, { file_add: "1", tracks_csv: upload }
end

When("I post add_song bulk with titles {string}") do |titles|
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  page.driver.submit :post, add_playlist_song_path, { bulk_add: "1", bulk_songs: titles }
end

When("I post add_song single with query {string}") do |query|
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  params = { single_add: "1", song_query: query }
  params[:tracks] = @existing_tracks if defined?(@existing_tracks) && @existing_tracks.present?
  page.driver.submit :post, add_playlist_song_path, params
end

When("I post create_custom playlist with no tracks") do
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  page.driver.submit :post, create_custom_playlist_path, {}
end

When("I post create_custom playlist with one track") do
  sess = page.driver.request.session
  sess[:spotify_user] ||= { "id" => "user-1" }
  sess[:spotify_token] ||= "token"
  tracks = { "1" => { id: "t-track", name: "Song", artists: "A" } }
  page.driver.submit :post, create_custom_playlist_path, { tracks: tracks, playlist_name: "Mix" }
end
