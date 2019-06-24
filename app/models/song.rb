# frozen_string_literal: true

require 'json'

module MusicShare
  # song class
  class Song
    attr_reader :id, :title, :duration_seconds, :artists, :policies,
                :external_url, :external_id

    def initialize_from_spotify(song_info)
      @title = song_info['title']
      @duration_seconds = song_info['duration_seconds']
      @artists = song_info['artists']
      @external_url = song_info['external_url']
      @external_id = attributes_info['external_id']
    end

    def initialize(song_info)
      process_attributes song_info['attributes']
      process_policies song_info['policies']
    end

    def process_attributes(attributes_info)
      return unless attributes_info

      @id = attributes_info['id']
      @title = attributes_info['title']
      @duration_seconds = attributes_info['duration_seconds']
      @artists = attributes_info['artists']
      @external_url = attributes_info['external_url']
      @external_id = attributes_info['external_id']
    end

    def process_policies(policies_info)
      return unless policies_info

      @policies = OpenStruct.new(policies_info)
    end

    def to_json(*_args)
      JSON(
        title: @title,
        duration_seconds: @duration_seconds,
        external_url: @external_url,
        external_id: @external_id,
        artists: @artists
      )
    end
  end
end
