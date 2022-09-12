# frozen_string_literal: true

module Coinbase
  # Service object to create a loan for an account
  class CreateLoan
    def self.call(submitter_id:, loan_data:)
      Account.find(id: submitter_id)
             .add_loan(loan_data)
    end
  end
end
