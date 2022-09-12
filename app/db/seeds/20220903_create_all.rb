# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding account, requests and loans'
    create_accounts
    create_requests_made
    create_loans
    add_loans_to_request
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/account_seeds.yml")
REQUESTOR_INFO = YAML.load_file("#{DIR}/requestors.yml")
REQUEST_INFO = YAML.load_file("#{DIR}/request_seeds.yml")
LOAN_INFO = YAML.load_file("#{DIR}/loan_seeds.yml")
LOAN_SUBMITTER_INFO = YAML.load_file("#{DIR}/submitters_loans.yml")
REQUEST_LOANS = YAML.load_file("#{DIR}/requests_loans.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Coinbase::Account.create(account_info)
  end
end

def create_requests_made
  REQUESTOR_INFO.each do |requestor|
    account = Coinbase::Account.first(email: requestor['email'])
    requestor['req_title'].each do |request|
      req_data = REQUEST_INFO.find { |req| req['title'] == request }
      Coinbase::CreateRequest.call(
        requestor: account.id, req_data:
      )
    end
  end
end

def create_loans
  LOAN_SUBMITTER_INFO.each do |lender|
    account = Coinbase::Account.first(email: lender['email'])
    lender['loan_identifier'].each do |loan|
      loan_data = LOAN_INFO.find { |don| don['identifier'] == loan }
      Coinbase::CreateLoan.call(
        submitter_id: account.id, loan_data:
      )
    end
  end
end

def add_loans_to_request
  REQUEST_LOANS.each do |req_loan|
    req = Coinbase::Request.first(title: req_loan['req_title'])
    loan = Coinbase::Loan.first(identifier: req_loan['loan_identifier'])
    Coinbase::AddLoanToRequest.call(
      request_id: req.id, loan_id: loan.id
    )
  end
end
