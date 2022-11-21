# frozen_string_literal: true

module Coinbase
  # Get details about a donation
  class GetDonationQuery
    # Error for account can't access donation
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that donation'
      end
    end

    # Error for cannot find a donation
    class NotFoundError < StandardError
      def message
        'We could not find that donation'
      end
    end

    # Donation for given
    def self.call(auth:, donation:)
      raise NotFoundError unless donation

      policy = DonationPolicy.new(auth[:account], donation, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      donation
    end
  end
end
