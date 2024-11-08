require 'rails_helper'

RSpec.describe FilesServices::CsvParser, type: :service do
  subject(:parse_file) { described_class.call(file) }

  let!(:user) { create(:user) }

  context 'with valid data' do
    let(:file) { File.new("#{file_fixture_path}/transactions.csv") }
    let(:expected_content) do
      { invoices: [{ account: 'First Account', amount: '22.12', card: 'Card Account', date: '2024-02-12' }],
        transactions: [{ account: 'First Account', category: 'fun', date: '2023-02-12', kind: 'income', title: 'ticket to mars', amount: '22.1', parcels: '1', group: 'metas' }],
        transferences: [{ amount: '22.1', date: '2023-02-11', receiver: 'Second Account', sender: 'First Account' }] }
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

# let(:content) do
#   { invoices: [{ account: 'First Account', card: 'Card Account', amount: '12.40', date: '2024-01-02' }],
#     transactions: [{ account: 'First Account', category: 'fun', date: '2023-02-12', kind: 'income', title: 'ticket to mars', amount: '22.1', parcels: '1' }],
#     transferences: [{ sender: 'First Account', receiver: 'Second Account', amount: '12.34', date: '2024-01-01' }] }
# end
