# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AuthenticateAccount service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Coinbase::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = Coinbase::AuthenticateAccount.call(
      email: credentials['email'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    _(proc {
      Coinbase::AuthenticateAccount.call(
        email: credentials['email'], password: 'malword'
      )
    }).must_raise Coinbase::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    _(proc {
      Coinbase::AuthenticateAccount.call(
        email: 'maluser', password: 'malword'
      )
    }).must_raise Coinbase::AuthenticateAccount::UnauthorizedError
  end
end
