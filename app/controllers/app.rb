# frozen_string_literal: true

require 'roda'
require 'json'

module Coinbase
  # Web controller for Coinbase API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CoinbaseAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
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

                if new_donation
                  response.status = 201
                  response['Location'] = "#{@donation_route}/#{new_donation.id}"
                  { message: 'Donation saved', data: new_donation }.to_json
                else
                  routing.halt 400, 'Could not save donation'
                end

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
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'requests' do
            # GET api/v1/requests/[id]
            routing.get String do |id|
              response.status = 200
              Request.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Request not found' }.to_json
            end

            # GET api/v1/requests
            routing.get do
              response.status = 200
              output = { request_ids: Request.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/requests
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_request = Request.new(new_data)

              if new_request.save
                response.status = 201
                { message: 'Request saved', id: new_request.id }.to_json
              else
                routing.halt 400, { message: 'Could not save request' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
