# frozen_string_literal: true

require 'http'

# Create a new configuration file for a project
class ExportPlaylist
  def initialize(config)
    @config = config
  end

  def user_url
    @config.SP_USER_URL
  end

  def playlists_url
    @config.SP_PLAYLIST_URL
  end

  def call(current_account:, playlist:)
    response = export_playlist(current_account, playlist)
    export_songs(current_account, response.parse['id'], playlist)\
    unless playlist.songs.empty?
  end

  def export_playlist(current_account, playlist)
    playlist_data = { name: playlist.title, public: !playlist.is_private,
                      description: playlist.description }
    config_url = "#{user_url}/#{current_account.username}/playlists"
    response = HTTP.auth("Bearer #{current_account.spotify_token}")
                   .post(config_url, json: playlist_data)
    raise unless response.code == 201 || response.code == 200

    response
  end

  def export_songs(current_account, playlist_id, playlist)
    songs = playlist.songs.map do |song|
      "spotify:track:#{song.external_id}"
    end
    songs_data = { uris: songs }
    url = "#{playlists_url}/#{playlist_id}/tracks"

    response = HTTP.headers('Content-Type': 'application/json')
                   .auth("Bearer #{current_account.spotify_token}")
                   .post(url, json: songs_data)
    response.code == 201 ? response.parse : raise
  end
end
