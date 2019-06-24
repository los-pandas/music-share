# frozen_string_literal: true

require 'http'

# Returns all playlists belonging to an account
class GetSharedPlaylists
  def initialize(config)
    @config = config
  end

  def call(current_account)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/playlist/shared")

    response.code == 200 ? response.parse['data'] : nil
  end
end
