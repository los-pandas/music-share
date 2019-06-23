# frozen_string_literal: true

require 'http'

# Create a new configuration file for a project
class UpdatePlaylist
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, playlist_data:)
    playlist_data[:is_private] = playlist_data[:is_private] == 'on'
    config_url = "#{api_url}/playlist/#{playlist_data['id']}"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .put(config_url, json: playlist_data)

    response.code == 200 ? response.parse['data'] : raise
  end
end
