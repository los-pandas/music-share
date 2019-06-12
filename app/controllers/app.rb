# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module MusicShare
  # Base class for MusicShare Web Application
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, path: 'app/presentation/assets', css: 'style.css',
                    js: 'script.js'
    plugin :public, root: 'app/presentation/public'
    plugin :multi_route
    plugin :flash

    route do |routing|
      @current_account = CurrentSession.new(session).current_account

      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        view 'home', locals: { current_account: @current_account }
      end
    end
  end
end
