# frozen_string_literal: true

require_relative 'song'

module MusicShare
  # playlist class
  class Playlist
    attr_reader :id, :title, :description, :songs, :policies, :creator,
                :is_private

    def initialize(playlist_info)
      process_attributes playlist_info['attributes']
      process_relationships playlist_info['relationships']
      process_policies playlist_info['policies']
    end

    def process_attributes(attributes_info)
      # attributes
      return unless attributes_info

      @id = attributes_info['id']
      @title = attributes_info['title']
      @description = attributes_info['description']
      @is_private = attributes_info['is_private']
    end

    def process_relationships(relationships_info)
      # relationships
      return unless relationships_info

      @songs = relationships_info['songs'].map do |song_info|
        Song.new(song_info)
      end
      @creator = Account.new(relationships_info['owner'])
    end

    def process_policies(policies_info)
      # policies
      return unless policies_info

      @policies = OpenStruct.new(policies_info)
    end
  end
end
