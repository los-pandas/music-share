# frozen_string_literal: true

require_relative 'form_base'

module MusicShare
  module Form
    NewPlaylist = Dry::Validation.Params do
      required(:title).filled
      optional(:description).maybe
      optional(:is_private).maybe
      configure do
        config.messages_file = File.join(__dir__, 'errors/new_playlist.yml')
      end
    end
  end
end
