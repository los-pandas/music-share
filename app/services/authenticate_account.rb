# frozen_string_literal: true

require 'http'

module MusicShare
  # Returns an authenticated user, or nil
  class AuthenticateAccount
    class UnauthorizedError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(username:, password:)
      response = HTTP.post("#{@config.API_URL}/auth/authenticate",
                           json: { username: username, password: password })
      raise(UnauthorizedError) if response.code == 403
      raise if response.code != 200

      account_info = response.parse['attributes']

      {
        account: account_info['account']['attributes'],
        auth_token: account_info['auth_token']
      }
    end
  end
end
