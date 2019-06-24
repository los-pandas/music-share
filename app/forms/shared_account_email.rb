# frozen_string_literal: true

require_relative 'form_base'

module MusicShare
  module Form
    SharedAccountEmail = Dry::Validation.Params do
      configure do
        config.messages_file = File.join(__dir__, 'errors/account_details.yml')
      end

      required(:email).filled(format?: EMAIL_REGEX)
    end
  end
end
