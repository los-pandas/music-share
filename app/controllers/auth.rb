# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for MusicShare API
  class App < Roda
    route('auth') do |routing| # rubocop:disable BlockLength
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          account = AuthenticateAccount.new(App.config).call(
            username: routing.params['username'],
            password: routing.params['password']
          )
          SecureSession.new(session).set(:current_account, account)
          flash[:notice] = "Welcome back #{account['username']}!"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash[:error] = 'Username and password did not match our records'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      routing.on 'logout' do
        routing.get do
          SecureSession.new(session).delete(:current_account)
          flash[:notice] = 'Logout succesful!'
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.is 'register' do
        routing.get do
          view :register
        end

        routing.post do
          account_data = JsonRequestBody.symbolize(routing.params)
          CreateAccount.new(App.config).call(account_data)

          flash[:notice] = 'Please login with your new account information'
          routing.redirect '/auth/login'
        rescue StandardError => e
          puts "ERROR CREATING ACCOUNT: #{e.inspect}"
          puts e.backtrace
          flash[:error] = 'Could not create account'
          routing.redirect @register_route
        end
      end
    end
  end
end
