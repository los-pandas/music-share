# frozen_string_literal: true

require 'http'

# Returns all playlists belonging to an account
class GetAllPlaylists
  def initialize(config)
    @config = config
  end

  def call(current_account)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/playlist")

    response.code == 200 ? response.parse['data'] : nil
  end
end
