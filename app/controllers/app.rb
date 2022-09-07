# frozen_string_literal: true

require 'roda'
require 'json'

module Coinbase
  # Web controller for Coinbase API
  class Api < Roda
    plugin :halt

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CoinbaseAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username:)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account created', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            Api.logger.error 'Unknown error saving account'
            routing.halt 500, { message: e.message }.to_json
          end
        end
        routing.on 'requests' do
          @req_route = "#{@api_root}/requests"

          routing.on String do |req_id|
            routing.on 'donations' do
              @donation_route = "#{@api_root}/requests/#{req_id}/donations"
              # GET api/v1/requests/[req_id]/donations/[donation_id]
              routing.get String do |donation_id|
                donation = Donation.where(request_id: req_id, id: donation_id).first
                donation ? donation.to_json : raise('Donation not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/requests/[req_id]/donations
              routing.get do
                output = { data: Request.first(id: req_id).donations }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find donations'
              end

              # POST api/v1/requests/[ID]/donations
              routing.post do
                new_data = JSON.parse(routing.body.read)
                req = Request.first(id: req_id)
                new_donation = req.add_donation(new_data)
                raise 'Could not save donation' unless new_donation

                response.status = 201
                response['Location'] = "#{@donation_route}/#{new_donation.id}"
                { message: 'Donation saved', data: new_donation }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/requests/[ID]
            routing.get do
              req = Request.first(id: req_id)
              req ? req.to_json : raise('Request not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/requests
          routing.get do
            output = { data: Request.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find requests' }.to_json
          end

          # POST api/v1/requests
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_req = Request.new(new_data)
            raise('Could not save request') unless new_req.save

            response.status = 201
            response['Location'] = "#{@req_route}/#{new_req.id}"
            { message: 'Request saved', data: new_req }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
