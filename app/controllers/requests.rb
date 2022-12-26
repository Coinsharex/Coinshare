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

      routing.on 'categories' do
        routing.on String do |category|
          # GET api/v1/requests/categories/[category]
          routing.get do
            output = { data: Request.where(category:).all }
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

        routing.on 'donations' do
          # @donation_route = "#{@api_root}/requests/#{req_id}/donations"
          # # GET api/v1/requests/[req_id]/donations/[donation_id]
          # routing.get String do |donation_id|
          #   donation = Donation.first(id: donation_id)
          #   donation ? donation.to_json : raise('Donation not found')
          # rescue StandardError => e
          #   routing.halt 404, { message: e.message }.to_json
          # end

          # GET api/v1/requests/[req_id]/donations
          routing.get do
            output = { data: Request.first(id: req_id).donations }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find donations' }.to_json
          end

          # POST api/v1/requests/[ID]/donations
          routing.post do
            binding.pry
            new_data = JSON.parse(routing.body.read)
            ## TO BE CHANGED SOON, THIS IS TEMPORARY
            ## THIS IS WHERE WE WILL CALL THE EXTERNAL API

            req = Request.first(id: req_id)
            new_donation = req.add_donation(new_data)
            raise 'Could not save donation' unless new_donation

            response.status = 201
            response['Location'] = "#{@donation_route}/#{new_donation.id}"
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
        JSON.pretty_generate(data: Request.all)
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
