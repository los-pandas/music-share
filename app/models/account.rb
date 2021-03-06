# frozen_string_literal: true

module MusicShare
  # Behaviors of the currently logged in account
  class Account
    def initialize(account_info, auth_token = nil)
      @account_info = account_info
      @auth_token = auth_token
    end

    attr_reader :account_info, :auth_token

    def username
      @account_info ? @account_info['attributes']['username'] : nil
    end

    def display_name
      @account_info ? @account_info['attributes']['display_name'] : username
    end

    def email
      @account_info ? @account_info['attributes']['email'] : nil
    end

    def logged_out?
      @account_info.nil?
    end

    def logged_in?
      !logged_out?
    end

    def logged_in_spotify?
      !@account_info['spotify_token'].nil?
    end

    def spotify_token
      @account_info ? @account_info['spotify_token']['token'] : nil
    end
  end
end
