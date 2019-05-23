# frozen_string_literal: true

require 'http'

module MusicShare
  # Returns an authenticated user, or nil
  class CreateAccount
    # Error for accounts that cannot be created
    class InvalidAccount < StandardError
      def message
        'This account can no longer be created: please start again'
      end
    end

    def initialize(config)
      @config = config
    end

    def call(email:, username:, password:)
      message = { email: email,
                  username: username,
                  password: password }

      response = HTTP.post(
        "#{@config.API_URL}/account",
        json: message
      )

      raise InvalidAccount unless response.code == 201
    end
  end
end
