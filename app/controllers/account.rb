# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for MusicShare API
  class App < Roda
    route('account') do |routing| # rubocop:disable BlockLength
      routing.on do # rubocop:disable BlockLength
        # GET /account
        routing.get String do |username|
          if @current_account && @current_account.username == username
            view :account, locals: { current_account: @current_account }
          else
            routing.redirect '/auth/login'
          end
        end
        # POST /account/<token>
        routing.post String do |registration_token|
          passwords = Form::Passwords.call(routing.params)
          if passwords.failure?
            flash[:error] = Form.validation_errors(passwords)
            routing.redirect(
              "#{App.config.APP_URL}/auth/register/#{registration_token}"
            )
          end
          # raise 'Passwords do not match or empty' if
          #  routing.params['password'].empty? ||
          #  routing.params['password'] != routing.params['password_confirm']

          new_account = SecureMessage.decrypt(registration_token)
          CreateAccount.new(App.config).call(
            email: new_account['email'],
            username: new_account['username'],
            password: routing.params['password']
          )
          flash[:notice] = 'Account created! Please login'
          routing.redirect '/auth/login'
        rescue CreateAccount::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/register'
        rescue StandardError => e
          flash[:error] = e.message
          routing.redirect(
            "#{App.config.APP_URL}/auth/register/#{registration_token}"
          )
        end
      end
    end
  end
end
