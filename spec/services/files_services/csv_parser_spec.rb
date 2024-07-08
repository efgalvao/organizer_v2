require 'rails_helper'

RSpec.describe FilesServices::CsvParser, type: :service do
  subject(:parse_file) { described_class.call(file) }

  let!(:user) { create(:user) }

  context 'with valid data' do
    let(:file) { File.new("#{file_fixture_path}/transactions.csv") }
    let(:expected_content) do
      { credit: [],
        invoices: [],
        transactions: [{ account: 'BB Fer', category: 'diversao', date: '2023-02-12', kind: 'income', title: 'ticket to mars', value: '22.1', parcels: '1' }],
        transferences: [] }
    end

    it 'creates an Account' do
      response = parse_file

      expect(response).to eq(expected_content)
    end
  end

  context 'with invalid data' do
    let(:file) { '' }

    it 'creates an Account' do
      response = parse_file

      expect(response).to eq('Invalid CSV file')
    end
  end
end
