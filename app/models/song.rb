# frozen_string_literal: true

module MusicShare
  # song class
  class Song
    attr_reader :id, :title, :duration, :artists

    def initialize(song_info)
      @id = song_info['attributes']['id']
      @title = song_info['attributes']['title']
      @duration = song_info['attributes']['duration']
      @artists = song_info['attributes']['artists']
    end
  end
end
