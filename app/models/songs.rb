# frozen_string_literal: true

require_relative 'song'

module MusicShare
  # playlists model
  class Songs
    attr_reader :all

    def initialize(song_list)
      @all = song_list.map do |song|
        Song.new(song)
      end
    end
  end
end
