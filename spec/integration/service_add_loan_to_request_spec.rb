# frozen_string_literal: true

describe 'Test AddLoanToRequest service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Coinbase::Account.create(account_data)
    end

    request_data = DATA[:requests].first

    @requestor = Coinbase::Account.all[0]
    @loan = Coinbase::Loan.all[0]
    @request = Coinbase::CreateRequest.call(
      requestor: @requestor, request_data:
    )

    it 'HAPPY: should be able to add a loan to a request' do
      Coinbase::AddLoanToRequest.call(
        request_id: @request.id,
        loan_id: @loan.id
      )

      _(@request.loans.count).must_equal 1
      _(@request.loans.first).must_equal @loan
    end

    it 'BAD: should not be able to add requestor' do
      loan = @requestor.add_loan(Coinbase::Loan.all[1])
      _(proc {
        Coinbase::AddLoanToRequest.call(
          request_id: @request.id,
          loan_id: loan.id
        )
      }).must_raise Coinbase::AddLoanToRequest::RequestorNotLender
    end
  end
end
