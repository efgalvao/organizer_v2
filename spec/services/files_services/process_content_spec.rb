require 'rails_helper'

RSpec.describe FilesServices::ProcessContent, type: :service do
  subject(:process_content) { described_class.call(content, user.id) }

  let(:user) { create(:user) }
  let!(:first_account) { create(:account, name: 'First Account', user: user) }
  let!(:second_account) { create(:account, name: 'Second Account', user: user) }
  let!(:card_account) { create(:account, :card, name: 'Card Account', user: user) }
  let(:content) do
    { invoices: [{ account: 'First Account', card: 'Card Account', amount: '12.40', date: '2024-01-02' }],
      transactions: [{ account: 'First Account', category: 'fun', date: '2023-02-12', type: 1, title: 'ticket to mars', amount: '22.1', parcels: '5', group: 'conforto' }],
      transferences: [{ sender: 'First Account', receiver: 'Second Account', amount: '12.34', date: '2024-01-01' }] }
  end

  context 'with valid data' do
    it 'creates records', :aggregate_failures do
      process_content

      expect(Transference.count).to eq(1)
      expect(Account::Income.count).to eq(5)
      expect(Account::InvoicePayment.count).to eq(2)
      expect(Account::Transference.count).to eq(2)
    end
  end
end
