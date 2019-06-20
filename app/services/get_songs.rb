# frozen_string_literal: true

require 'http'

# Returns all playlists belonging to an account
class GetSongs
  def initialize(config)
    @config = config
  end

  def call(current_account, query)
    response = HTTP.auth("Bearer #{current_account.spotify_token}")
                   .get(@config.SP_SEARCH_URL,
                        params: { q: query,
                                  type: 'track',
                                  limit: 3 })
    return nil unless response.code == 200

    response.parse['tracks']['items'].map do |song_info|
      if song_info['artists'].length == 1
        artists = song_info['artists'][0]['name']
      else
        artists = song_info['artists'].reduce { |artist1, artist2| artist1['name'] + ',' + artist2['name'] }
      end
      { 'attributes' => { 'title' => song_info['name'],
                          'duration_seconds' => song_info['duration_ms'] / 1000, 'external_url' => song_info['external_urls']['spotify'],
                          'artists' => artists } }
    end
  end
end
