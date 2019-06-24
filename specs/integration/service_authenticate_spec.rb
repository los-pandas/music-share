# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Service Objects' do # rubocop:disable BlockLength
  before do
    @credentials = { username: 'xavier', password: '12345678' }
    @mal_credentials = { username: 'xavier', password: 'wrongpassword' }
    @api_account = { attributes:
         { account:
           { username: 'xavier', email: 'xavier@nthu.edu.tw' } } }
  end

  after do
    WebMock.reset!
  end

  describe 'Find authenticated account' do # rubocop:disable BlockLength
    it 'HAPPY AUTHENTCATION: should find an authenticated account' do
      auth_return = { 'data' => {
        'attributes' => {
          'account' => @api_account,
          'auth_token' => 'thisisnotarealtoken'
        }
      } }
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: SignedMessage.sign(@credentials).to_json)
             .to_return(body: auth_return.to_json,
                        headers: { 'content-type' => 'application/json' })

      auth = MusicShare::AuthenticateAccount.new(app.config)
                                            .call(@credentials)
      account = auth[:account]['attributes']
      _(account).wont_be_nil
      _(account['username']).must_equal @api_account[:attributes][:username]
      _(account['email']).must_equal @api_account[:attributes][:email]
    end

    it 'BAD AUTHENTICATION: should not find a false authenticated account' do
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: SignedMessage.sign(@mal_credentials).to_json)
             .to_return(status: 403)
      proc {
        MusicShare::AuthenticateAccount.new(app.config).call(@mal_credentials)
      }.must_raise MusicShare::AuthenticateAccount::NotAuthenticatedError
    end
  end
end
