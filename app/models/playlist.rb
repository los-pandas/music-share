# frozen_string_literal: true

require_relative 'song'

module MusicShare
  # playlist class
  class Playlist
    attr_reader :id, :title, :description, :songs

    def initialize(playlist_info)
      @id = playlist_info['attributes']['id']
      @title = playlist_info['attributes']['title']
      @description = playlist_info['attributes']['description']
      @songs = playlist_info['attributes']['songs'].map do |song_info|
        Song.new(song_info)
      end
    end
  end
end
