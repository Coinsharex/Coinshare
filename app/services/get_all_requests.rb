# frozen_string_literal: true

module Coinbase
  # Get All requests
  class GetAllRequests
    def self.call(requests)
      # requests.map do |request|
      #   request.full_details
      # end

      requests.map(&:full_details)
    end
  end
end
