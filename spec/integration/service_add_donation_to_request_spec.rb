# frozen_string_literal: true

describe 'Test AddDonationToRequest service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Coinbase::Account.create(account_data)
    end

    request_data = DATA[:requests].first

    @requestor = Coinbase::Account.all[0]
    @donation = Coinbase::Donation.all[0]
    @request = Coinbase::CreateRequest.call(
      requestor: @requestor, request_data:
    )

    it 'HAPPY: should be able to add a donation to a request' do
      Coinbase::AddDonationToRequest.call(
        request_id: @request.id,
        donation_id: @donation.id
      )

      _(@request.donations.count).must_equal 1
      _(@request.donations.first).must_equal @donation
    end

    it 'BAD: should not be able to add requestor' do
      donation = @requestor.add_donation(Coinbase::Donation.all[1])
      _(proc {
        Coinbase::AddDonationToRequest.call(
          request_id: @request.id,
          donation_id: donation.id
        )
      }).must_raise Coinbase::AddDonationToRequest::RequestorNotDonor
    end
  end
end
