# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/request'

module Coinbase
  # Web controller for Coinbase API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Request.setup
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'CoinbaseAPI up at /api/v1' }.to_json
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
