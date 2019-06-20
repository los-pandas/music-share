# frozen_string_literal: true

require 'roda'

module MusicShare
  # Web controller for MusicShare
  class App < Roda
    route('search') do |routing|
      routing.on do
        @playlists_route = '/songs'
        routing.redirect '/auth/login' unless @current_account.logged_in?
        # GET /playlists/[playlist_id]
        routing.get do
          view :song_search
        end
      end
    end
  end
end
