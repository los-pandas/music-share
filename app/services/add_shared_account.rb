# frozen_string_literal: true

# Service to add a shared account to playlist
class AddSharedAccount
  class SharedAccountNotAdded < StandardError; end

  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, shared_account:, playlist_id:)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .put("#{api_url}/playlist/shared/#{playlist_id}",
                        json: { email: shared_account[:email] })

    raise SharedAccountNotAdded unless response.code == 200
  end
end
