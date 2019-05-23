# frozen_string_literal: true

require_relative 'playlist'

module MusicShare
  # playlists model
  class Playlists
    attr_reader :all

    def initialize(playlist_list)
      @all = playlist_list.map do |playlist|
        Playlist.new(playlist)
      end
    end
  end
end
