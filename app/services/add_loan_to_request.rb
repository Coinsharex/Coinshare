# frozen_string_literal: true

module Coinbase
  # Add a loan to a request
  class AddLoanToRequest
    # Error for requestor cannot be lender
    class RequestorNotLender < StandardError
      def message = 'Requestor cannot be lender'
    end

    def self.call(request_id:, loan_id:)
      request = Request.first(id: request_id)
      loan = Loan.first(id: loan_id)
      raise(RequestorNotLender) if request.requestor == loan.lender

      request.add_loan(loan)
    end
  end
end
