# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'rack/session/redis'
require_relative '../require_app'

require_app('lib')

module MusicShare
  # Configuration for the API
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    ONE_MONTH = 30 * 24 * 60 * 60

    configure do
      SecureSession.setup(config)
      SecureMessage.setup(config)
      SignedMessage.setup(config)
    end

    configure :production do
      use Rack::Session::Redis,
          expire_after: ONE_MONTH, redis_server: config.REDIS_URL
    end

    configure :development, :test do
      # use Rack::Session::Cookie,
      #     expire_after: ONE_MONTH, secret: config.SESSION_SECRET

      # use Rack::Session::Pool,
      #     expire_after: ONE_MONTH

      use Rack::Session::Redis,
          expire_after: ONE_MONTH, redis_server: config.REDIS_URL
    end

    configure :development, :test do
      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end
  end
end
