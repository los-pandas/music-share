# frozen_string_literal: true

require 'http'
require 'json'

# Create a new configuration file for a project
class AddSongToPlaylist
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, playlist_id:, song_data:)
    config_url = "#{api_url}/song-playlist"
    song_hash = JSON.parse(song_data)
    puts song_data
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .post(config_url, json: { playlist_id: playlist_id,
                                             song_data: song_hash })

    response.code == 201 ? response.parse : raise
  end
end
