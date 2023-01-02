# frozen_string_literal: true

module Coinbase
  # Service object to determine if a user can update a given request
  class UpdateRequest
    # Error classes
    class YearlyFundsAllownaceError < StandardError; end

    def self.call(auth:, request:, data:)
      policy = UpdateRequestPolicy.new(auth[:account], request, data, auth[:auth_scope])
      raise YearlyFundsAllownaceError unless policy.can_update?

      update_request(request, data)
    end

    def self.update_request(request, data)
      Request.where(id: request.id).update(data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
