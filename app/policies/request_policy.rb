# frozen_string_literal: true

module Coinbase
  # Policy to determine access-type of requests
  class RequestPolicy
    def initialize(account, request)
      @account = account
      @request = request
    end

    def can_edit?
      account_is_requestor?
    end

    def can_delete?
      account_is_requestor?
    end

    def can_add_donations?
      !account_is_requestor?
    end

    def summary
      {
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_donations: can_add_donations?
      }
    end

    private

    def account_is_requestor?
      @request.requestor == @account
    end
  end
end
