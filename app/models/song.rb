# frozen_string_literal: true

module MusicShare
  # song class
  class Song
    attr_reader :id, :title, :duration_seconds, :artists, :policies

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
    end

    def process_policies(policies_info)
      return unless policies_info

      @policies = OpenStruct.new(policies_info)
    end
  end
end
