# frozen_string_literal: true

require 'http'

# Returns a specific playlist with all data
class GetPlaylist
  def initialize(config)
    @config = config
  end

  def call(current_account, playlist_id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/playlist/#{playlist_id}")

    response.code == 200 ? response.parse['data'] : nil
  end
end
