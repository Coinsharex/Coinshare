# frozen_string_literal: true

module Coinbase
  # Service Object to allow users to delete requests
  class DeleteRequest
    class NotAllowedError < StandardError; end

    def self.call(auth:, request:)
      policy = RequestPolicy.new(auth[:account], request, auth[:scope])

      raise NotAllowedError unless policy.can_delete?

      delete_request(request)
    end

    def self.delete_request(request)
      Request.where(id: request.id).delete
    end
  end
end
