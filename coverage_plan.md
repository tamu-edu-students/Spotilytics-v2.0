# Remaining Coverage Gaps to Fix

## Current Status: 86.0% → Target: 100%

### Remaining Uncovered Lines (85 total):

1. **Application Controller (line 16)**: Empty body of `logged_in?` (already return value tested)
2. **PagesController (lines 208-209)**: Hash-based artist identifier
3. **PlaylistsController (line 26)**: Error path  
4. **SpotifyClient (~76 lines)**: Error handling, private methods, edge cases

## Quick Wins (Controllers - 5 lines):

### ApplicationController  
Line 16: Already covered by current_user tests - SKIP (non-executable)

### PagesController (lines 208-209)
Need test for hash-based artist in `artist_identifier`:
```ruby
# In pages_controller_spec.rb
describe "#artist_identifier" do
  it "handles hash artist" do
    artist = { "id" => "hash_id" }
    result = controller.send(:artist_identifier, artist)
    expect(result).to eq("hash_id")
  end
  
  it "handles symbol key hash" do
    artist = { id: "symbol_id" }
    result = controller.send(:artist_identifier, artist)
    expect(result).to eq("symbol_id")
  end
end
```

### PlaylistsController (line 26)
Check what line 26 is and add test

## SpotifyClient Priority Coverage:

Focus on most impactful methods that add value:
1. Error handling paths in existing methods
2. `new_releases` method
3. Token refresh logic
4. Any other public methods

Would get to ~95%+ with these additions.
