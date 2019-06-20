# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for MusicShare API
  class App < Roda # rubocop:disable ClassLength
    route('auth') do |routing| # rubocop:disable BlockLength
      @login_route = '/auth/login'
      routing.is 'login' do # rubocop:disable BlockLength
        # GET /auth/login
        routing.get do
          view :login, locals: {
            gh_oauth_url: CreateSSOURL.new(App.config).gh_oauth_url,
            sp_oauth_url: CreateSSOURL.new(App.config).sp_oauth_url
          }
        end

        # POST /auth/login
        routing.post do
          credentials = Form::LoginCredentials.call(routing.params)
          if credentials.failure?
            flash[:error] = 'Please enter both username and password'
            routing.redirect @login_route
          end
          authenticated = AuthenticateAccount.new(App.config).call(credentials)

          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token]
          )
          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome back #{current_account.username}!"
          routing.redirect '/playlists'
        rescue AuthenticateAccount::NotAuthenticatedError
          flash[:error] = 'Username and password did not match our records'
          response.status = 401
          routing.redirect @login_route
        rescue StandardError => e
          puts "LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      # routing.is 'sso_callback' do # rubocop:disable BlockLength
      # GET /auth/sso_callback
      routing.is 'sso_callback/github' do
        routing.get do
          authorized = AuthorizeGithubAccount.new(App.config)
                                             .call(routing.params['code'])

          current_account = Account.new(
            authorized[:account],
            authorized[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome #{current_account.username}!"
          routing.redirect '/playlists'
        rescue AuthorizeGithubAccount::UnauthorizedError
          flash[:error] = 'Could not login with Github'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
          response.status = 500
          routing.redirect @login_route
        end
      end
      routing.is 'sso_callback/spotify' do
        routing.get do
          authorized = AuthorizeSpotifyAccount.new(App.config)
                                              .call(routing.params)

          current_account = Account.new(
            authorized[:account],
            authorized[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome #{current_account.username}!"
          routing.redirect '/playlists'
        rescue AuthorizeSpotifyAccount::UnauthorizedError
          flash[:error] = 'Could not login with spotify'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
          response.status = 500
          routing.redirect @login_route
        end
      end
      # end

      routing.on 'logout' do
        routing.get do
          CurrentSession.new(session).delete
          flash[:notice] = 'Logout succesful!'
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do # rubocop:disable BlockLength
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end

          # POST /auth/register
          routing.post do
            registration = Form::Registration.call(routing.params)

            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end
            VerifyRegistration.new(App.config).call(registration)
            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue StandardError => e
            puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
            flash[:error] = 'Registration details are not valid'
            routing.redirect @register_route
          end
        end
        # GET /auth/register/<token>
        routing.get(String) do |registration_token|
          flash.now[:notice] = 'Email Verified! Please choose a new password'
          new_account = SecureMessage.decrypt(registration_token)
          view :register_confirm,
               locals: { new_account: new_account,
                         registration_token: registration_token }
        end
      end
    end
  end
end
