# frozen_string_literal: true

require 'roda'
require_relative './app'

module Coinbase
  # Web Controller for Coinbase API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |email|
        routing.halt(403, UNAUTH_MSG) unless @auth_account

        # GET api/v1/accounts/[email]
        routing.get do
          auth = AuthorizeAccount.call(
            auth: @auth, email:,
            auth_scope: AuthScope.new(AuthScope::READ_ONLY)
          )
          { data: auth }.to_json
        rescue AuthorizeAccount::ForbiddenError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET ACCOUNT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end

        # PUT api/v1/accounts[email]
        routing.put do
          data = JSON.parse(routing.body.read)
          updated_data = UpdateAccount.call(
            auth: @auth,
            email:,
            data:
          )
          response.status = 200
          { message: 'Account successfully updated', data: updated_data }.to_json
        rescue UpdateAccount::ForbiddenError => e
          routing.halt 404, { message: e.message }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASSS-ASSIGNMENT:: #{data.keys}"
          routing.halt 400, { message: 'Illegal Information ' }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_account = Account.new(new_data)
        raise('Could not save account') unless new_account.save

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.email}"
        { message: 'Account created', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        Api.logger.error 'Unknown error saving account'
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
