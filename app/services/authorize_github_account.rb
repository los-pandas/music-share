# frozen_string_literal: true

require 'http'

module MusicShare
  # Returns an authenticated user, or nil
  class AuthorizeGithubAccount
    # Errors emanating from Github
    class UnauthorizedError < StandardError
      def message
        'Could not login with Github'
      end
    end

    def initialize(config)
      @config = config
    end

    def call(code)
      access_token = get_access_token_from_github(code)
      get_sso_account_from_api(access_token)
    end

    private

    def get_access_token_from_github(code)
      challenge_response =
        HTTP.headers(accept: 'application/json')
            .post(@config.GH_TOKEN_URL,
                  form: { client_id: @config.GH_CLIENT_ID,
                          client_secret: @config.GH_CLIENT_SECRET,
                          code: code })
      raise UnauthorizedError unless challenge_response.status < 400

      challenge_response.parse['access_token']
    end

    def get_sso_account_from_api(access_token)
      signed_sso_info = { access_token: access_token }
                        .then { |sso_info| SignedMessage.sign(sso_info) }

      response = HTTP.post(
        "#{@config.API_URL}/auth/sso/github",
        json: signed_sso_info
      )
      raise if response.code >= 400

      get_sso_hash(response)
    end

    def get_sso_hash(response)
      account_info = response.parse['data']['attributes']

      {
        account: account_info['account'],
        auth_token: account_info['auth_token']
      }
    end
  end
end
