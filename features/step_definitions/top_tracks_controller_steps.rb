require "ostruct"

Given("Spotify top tracks API raises a generic error") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:top_tracks).and_raise(SpotifyClient::Error.new("rate limited"))
end

Given("Spotify top tracks API raises unauthorized") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)
  allow(mock).to receive(:top_tracks).and_raise(SpotifyClient::UnauthorizedError.new("expired"))
end

Given("my hidden top tracks are:") do |table|
  session = page.driver.request.session
  session[:spotify_user] ||= { "id" => "spotify-uid-123", id: "spotify-uid-123" }
  session[:spotify_token] ||= "token"
  session[:hidden_top_tracks] ||= {}
  session[:hidden_top_tracks][session[:spotify_user]["id"]] ||= {
    "short_term" => [],
    "medium_term" => [],
    "long_term" => []
  }
  table.hashes.each do |row|
    range = row.fetch("time_range")
    tid   = row.fetch("track_id")
    session[:hidden_top_tracks][session[:spotify_user]["id"]][range] << tid
  end

  allow_any_instance_of(TopTracksController).to receive(:hidden_top_tracks_for_user).and_return(
    session[:hidden_top_tracks][session[:spotify_user]["id"]]
  )
end

Given("Spotify top tracks API returns sample tracks for filtering") do
  mock = instance_double(SpotifyClient)
  allow(SpotifyClient).to receive(:new).and_return(mock)

  short_tracks = [
    OpenStruct.new(id: "h1", rank: 1, name: "Hidden Short", artists: "A", album_name: "Al", album_image_url: nil, popularity: 50, preview_url: nil, spotify_url: nil),
    OpenStruct.new(id: "s2", rank: 2, name: "Visible Short", artists: "B", album_name: "Al2", album_image_url: nil, popularity: 60, preview_url: nil, spotify_url: nil)
  ]
  medium_tracks = [
    OpenStruct.new(id: "m1", rank: 1, name: "Hidden Medium", artists: "C", album_name: "Am", album_image_url: nil, popularity: 55, preview_url: nil, spotify_url: nil)
  ]
  long_tracks = []

  allow(mock).to receive(:top_tracks) do |args|
    case args[:time_range]
    when "short_term"
      limit = args[:limit].to_i
      # Candidate fetch for hidden ids uses larger limit (>=50); return empty to trigger missing log branch
      if limit >= 20
        []
      else
        short_tracks.first([ limit, short_tracks.size ].min)
      end
    when "medium_term"
      medium_tracks.first([ args[:limit].to_i, medium_tracks.size ].min)
    when "long_term"
      long_tracks
    else
      []
    end
  end
end
