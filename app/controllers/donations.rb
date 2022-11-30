# frozen_string_literal: true

require_relative './app'

module Coinbase
  # Web Controller for Coinbase API
  class Api < Roda
    route('donations') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @donation_route = "#{@api_root}/donations"

      # GET api/v1/donations/[don_id]
      routing.on String do |donation_id|
        @req_donation = Donation.first(id: donation_id)

        routing.get do
          donation = GetDonationQuery.call(
            auth: @auth, donation: @req_donation
          )

          { data: donation }.to_json
        rescue GetDonationQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetDonationQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET DONATION ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
