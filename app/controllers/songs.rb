# frozen_string_literal: true

require 'roda'

module MusicShare
  # Web controller for MusicShare
  class App < Roda
    route('songs') do |routing| # rubocop:disable BlockLength
      routing.on do # rubocop:disable BlockLength
        @playlists_route = '/playlists'
        routing.redirect '/auth/login' unless @current_account.logged_in?

        routing.get do
          query = routing.params['query']
          # call api to get local songs
          song_list = GetSongs.new(App.config)
                              .call(@current_account, query)
          songs = Songs.new(song_list)
          playlist_list = GetAllPlaylists.new(App.config)
                                         .call(@current_account)

          playlists = Playlists.new(playlist_list)
          # get songs from spotify
          view :songs, locals: { songs: songs, playlists: playlists }
        end

        routing.is 'add' do
          routing.post do
            playlist_id = routing.params['playlist_id']
            song_data = routing.params['song_data']
            AddSongToPlaylist.new(App.config).call(
              current_account: @current_account,
              playlist_id: playlist_id,
              song_data: song_data
            )

            flash[:notice] = 'Song added'
          rescue StandardError => e
            puts "FAILURE Creating Playlist: #{e.inspect}"
            flash[:error] = 'Could not add song'
          ensure
            routing.redirect @playlists_route
          end
        end
      end
    end
  end
end
