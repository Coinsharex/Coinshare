# frozen_string_literal: true

module Coinbase
  # Policy to determine access-type of requests
  class RequestPolicy
    def initialize(account, request, auth_scope = nil)
      @account = account
      @request = request
      @auth_scope = auth_scope
    end

    def can_view?
      true
    end

    def can_edit?
      can_write? && account_is_requestor?
    end

    def can_delete?
      account_is_requestor?
    end

    def can_add_donations?
      !account_is_requestor?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_donations: can_add_donations?
      }
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('requests') : false
    end

    def account_is_requestor?
      @request.requestor == @account
    end
  end
end
