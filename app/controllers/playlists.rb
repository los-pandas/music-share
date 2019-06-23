# frozen_string_literal: true

require 'roda'

module MusicShare
  # Web controller for MusicShare
  class App < Roda
    route('playlists') do |routing| # rubocop:disable BlockLength
      @playlists_route = '/playlists'
      # delete /playlists/delete/[playlist_id]
      routing.on 'delete' do
        routing.post String do |playlist_id|
          playlist = DeletePlaylist.new(App.config)
                                   .call(@current_account, playlist_id)
          flash[:notice] = "Playlist #{playlist['attributes']['title']} deleted"

        rescue StandardError => e
          puts "#{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Playlist not found'
        ensure
          routing.redirect @playlists_route
        end
      end
      # put /playlists/update/[playlist_id]
      routing.on 'update' do
        routing.post String do |playlist_id|
          playlist_data = Form::NewPlaylist.call(routing.params)
          if playlist_data.failure?
            flash[:error] = Form.validation_errors(playlist_data)
            routing.halt
          end
          playlist_data = playlist_data.to_h
          playlist_data['id'] = playlist_id
          UpdatePlaylist.new(App.config).call(
            current_account: @current_account,
            playlist_data: playlist_data
          )

          flash[:notice] = 'Playlist updated'

        rescue StandardError => e
          puts "#{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Playlist not found'
        ensure
          routing.redirect @playlists_route
        end
      end
      # export /playlists/export/[playlist_id]
      routing.on 'export' do
        routing.post String do |playlist_id|
          playlist = GetPlaylist.new(App.config)
                                .call(@current_account, playlist_id)

          playlist = Playlist.new(playlist)
          ExportPlaylist.new(App.config).call(
            current_account: @current_account,
            playlist: playlist
          )
          flash[:notice] = "Playlist #{playlist.title} exported"

        rescue StandardError => e
          puts "#{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Error while exporting playlist'
        end
      end
      routing.on do # rubocop:disable BlockLength
        routing.redirect '/auth/login' unless @current_account.logged_in?
        # GET /playlists/[playlist_id]
        routing.get String do |playlist_id|
          playlist = GetPlaylist.new(App.config)
                                .call(@current_account, playlist_id)

          playlist = Playlist.new(playlist)

          view :playlist,
               locals: { current_user: @current_account,
                         playlist: playlist }

        rescue StandardError => e
          puts "#{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Playlist not found'
          routing.redirect @playlists_route
        end
        # GET /playlists/
        routing.get do
          if @current_account.logged_in?
            playlist_list = GetAllPlaylists.new(App.config)
                                           .call(@current_account)

            playlists = Playlists.new(playlist_list)

            view :playlists_all,
                 locals: { current_user: @current_account,
                           playlists: playlists }
          else
            routing.redirect '/auth/login'
          end
        end
        # POST /playlists/
        routing.post do
          playlist_data = Form::NewPlaylist.call(routing.params)
          if playlist_data.failure?
            flash[:error] = Form.validation_errors(playlist_data)
            routing.halt
          end

          CreateNewPlaylist.new(App.config).call(
            current_account: @current_account,
            playlist_data: playlist_data.to_h
          )

          flash[:notice] = 'Playlist created'
        rescue StandardError => e
          puts "FAILURE Creating Playlist: #{e.inspect}"
          flash[:error] = 'Could not create playlist'
        ensure
          routing.redirect @playlists_route
        end
      end
    end
  end
end
