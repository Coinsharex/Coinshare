# frozen_string_literal: true

require_relative './app'

module Coinbase
  # Web Controller for Coinbase API
  class Api < Roda
    route('donations') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @donation_route = "#{@api_root}/donations"

      # GET api/v1/donations/[don_id]
      routing.on 'personal' do
        routing.get do
          data = @auth_account.donations
          output = { data: }
          JSON.pretty_generate(output)
        rescue StandardError => e
          puts "GET DONATION ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
