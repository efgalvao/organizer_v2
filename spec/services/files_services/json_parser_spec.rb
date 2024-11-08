require 'rails_helper'

RSpec.describe FilesServices::JsonParser, type: :service do
  subject(:parse_file) { described_class.call(file) }

  let!(:user) { create(:user) }

  context 'with valid data' do
    let(:file) { File.new("#{file_fixture_path}/transactions.json") }
    let(:expected_content) do
      { invoices: [{ account: 'First Account', amount: '22.1', card: 'Card Account', date: '2023-02-12' }],
        transactions: [{ account: 'First Account', category: 'fun', date: '2023-02-12', kind: 'income', title: 'ticket to mars', amount: '22.1', parcels: '1', group: 'metas' }],
        transferences: [{ amount: '10.0', date: '2023-02-12', receiver: 'Second Account', sender: 'First Account' }] }
    end

    it 'parse file content' do
      response = parse_file

      expect(response).to eq(expected_content)
    end
  end
end
