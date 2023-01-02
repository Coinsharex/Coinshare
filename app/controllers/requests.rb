# frozen_string_literal: true

require 'roda'
require_relative './app'

module Coinbase
  # Web Controller for Coinbase API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('requests') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @req_route = "#{@api_root}/requests"

      routing.on 'personal' do
        routing.get do
          data = GetAllRequests.call(@auth_account.requests)
          output = { data: }
          JSON.pretty_generate(output)
        end
      end

      routing.on 'categories' do
        routing.on String do |category|
          # GET api/v1/requests/categories/[category]
          routing.get do
            data = GetAllRequests.call(Request.where(category:).all)
            output = { data: }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find requests' }.to_json
          end
        end
      end

      routing.on String do |req_id|
        @req = Request.first(id: req_id)
        # GET api/v1/requests/[ID]
        routing.get do
          request = GetRequestQuery.call(
            auth: @auth, request: @req
          )
          { data: request }.to_json
        rescue GetRequestQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          routing.halt 500, { message: e.message }.to_json
        end

        routing.delete do
          DeleteRequest.call(
            auth: @auth,
            request: @req
          )
          response.status = 200
          { message: 'Request deleted' }.to_json
        rescue DeleteRequest::NotAllowedError
          routing.halt 403, { message: 'You cannot delete request that already has donations' }.to_json
        end

        # PUT api/v1/requests/[ID] => json/data
        routing.put do
          data = JSON.parse(routing.body.read)

          updated_req = UpdateRequest.call(
            auth: @auth,
            request: @req,
            data:
          )
          response.status = 200
          { message: 'Request updated', data: updated_req }.to_json
        rescue UpdateRequest::YearlyFundsAllownaceError
          routing.halt 403, { message: 'You have asked more than the allowed threshold for the year' }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 400, { message: e.message }.to_json
        end

        routing.on 'donations' do
          # GET api/v1/requests/[req_id]/donations
          routing.get do
            output = { data: Request.first(id: req_id).donations }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find donations' }.to_json
          end

          # POST api/v1/requests/[ID]/donations
          routing.post do
            donation_data = JSON.parse(routing.body.read)
            request = Request.first(id: req_id)

            CreateDonation.call(
              auth: @auth,
              request:,
              donation_data:
            )

            response.status = 201
            # response['Location'] = "#{@donation_route}/#{new_donation.id}"
            { message: 'Donation saved', data: new_donation }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError
            routing.halt 500, { message: 'Database error' }.to_json
          end
        end
      end

      # GET api/v1/requests
      routing.get do
        data = GetAllRequests.call(Request.all)
        JSON.pretty_generate(data:)
        # JSON.pretty_generate(data: Request.all)
      rescue StandardError
        routing.halt 404, { message: 'Could not find requests' }.to_json
      end

      # POST api/v1/requests
      routing.post do
        new_data = JSON.parse(routing.body.read)

        new_req = CreateRequest.call(
          auth: @auth, req_data: new_data
        )
        # raise('Could not save request') unless new_req.save

        response.status = 201
        response['Location'] = "#{@req_route}/#{new_req.id}"
        # new_req.add_donation_summary
        { message: 'Request saved', data: new_req }.to_json
      rescue CreateRequest::MonthlyRequestAllowanceError
        routing.halt 401, { message: 'You already posted 2 requests this month' }.to_json
      rescue CreateRequest::YearlyFundsAllownaceError
        routing.halt 403, { message: 'You have asked more than the allowed threshold for the year' }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKNOWN ERROR: #{e.message}"
        routing.halt 400, { message: e.message }.to_json
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
