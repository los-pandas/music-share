# frozen_string_literal: true

require 'http'
require 'base64'

module MusicShare
  # Returns an authenticated user, or nil
  class AuthorizeSpotifyAccount
    # Errors emanating from Github
    class UnauthorizedError < StandardError
      def message
        'Could not login with Spotify'
      end
    end

    def initialize(config)
      @config = config
    end

    def call(response)
      access_token_response = get_access_token_from_spotify(response)
      get_sso_account_from_api(access_token_response)
    end

    private

    def get_access_token_from_spotify(response)
      code = response['code']
      challenge_response =
        HTTP.headers(accept: 'application/json')
            .auth(auth_header)
            .post(@config.SP_TOKEN_URL,
                  form: { redirect_uri: @config.SP_REDIRECT_URL,
                          code: code,
                          grant_type: 'authorization_code' })
      raise UnauthorizedError unless challenge_response.status < 400

      challenge_response.parse
    end

    def get_sso_account_from_api(access_token_response)
      signed_sso_info = {
        token: access_token_response['access_token'],
        refresh_token: access_token_response['refresh_token']
      }.then { |sso_info| SignedMessage.sign(sso_info) }

      api_response = HTTP.post(
        "#{@config.API_URL}/auth/sso/spotify",
        json: signed_sso_info
      )
      raise if api_response.code >= 400

      get_sso_hash(api_response)
    end

    def get_sso_hash(api_response)
      account_info = api_response.parse['data']['attributes']

      {
        account: account_info['account'],
        auth_token: account_info['auth_token']
      }
    end

    def auth_header
      "Basic #{Base64.urlsafe_encode64(@config.SP_CLIENT_ID + ':' +
                               @config.SP_CLIENT_SECRET)}"
    end
  end
end
