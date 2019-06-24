# frozen_string_literal: true

require 'http'

module MusicShare
  # Returns an authenticated user, or nil
  class CreateSSOURL
    def initialize(config)
      @config = config
    end

    def gh_oauth_url
      url = @config.GH_OAUTH_URL
      client_id = @config.GH_CLIENT_ID
      scope = @config.GH_SCOPE

      "#{url}?client_id=#{client_id}&scope=#{scope}"
    end

    def sp_oauth_url
      url = @config.SP_OAUTH_URL
      client_id = @config.SP_CLIENT_ID
      scope = @config.SP_SCOPE
      redirect_uri = @config.SP_REDIRECT_URL

      "#{url}response_type=code&client_id=#{client_id}&scope=#{scope}\
      &redirect_uri=#{redirect_uri}&state=spotify_auth_state"
    end
  end
end
