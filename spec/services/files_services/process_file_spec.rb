require 'rails_helper'

RSpec.describe FilesServices::ProcessFile, type: :service do
  subject(:process_file) { described_class.call(file, user.id) }

  let(:user) { create(:user) }
  let!(:first_account) { create(:account, name: 'First Account', user: user) }
  let!(:second_account) { create(:account, name: 'Second Account', user: user) }
  let!(:card_account) { create(:account, :card, name: 'Card Account', user: user) }

  context 'when filetype is CSV' do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        filename: 'transactions.csv',
        type: 'text/csv',
        tempfile: File.new("#{file_fixture_path}/transactions.csv")
      )
    end
    let(:expected_content) do
      { invoices: [{ account: 'First Account', amount: '22.12', card: 'Card Account', date: '2024-02-12' }],
        transactions: [{ account: 'First Account', category: 'fun', date: '2023-02-12', kind: 'income', title: 'ticket to mars', amount: '22.1', parcels: '1', group: 'metas' }],
        transferences: [{ amount: '22.1', date: '2023-02-11', receiver: 'Second Account', sender: 'First Account' }] }
    end

    before do
      allow(FilesServices::ProcessContent).to receive(:call)
    end

    it 'parse CSV file' do
      process_file

      expect(FilesServices::ProcessContent).to have_received(:call).with(expected_content, user.id)
    end
  end

  context 'when filetype is JSON' do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        filename: 'transactions.csv',
        type: 'application/json',
        tempfile: File.new("#{file_fixture_path}/transactions.json")
      )
    end
    let(:expected_content) do
      { invoices: [{ account: 'First Account', amount: '22.1', card: 'Card Account', date: '2023-02-12' }],
        transactions: [{ account: 'First Account', category: 'fun', date: '2023-02-12', kind: 'income', title: 'ticket to mars', amount: '22.1', parcels: '1', group: 'metas' }],
        transferences: [{ amount: '10.0', date: '2023-02-12', receiver: 'Second Account', sender: 'First Account' }] }
    end

    before do
      allow(FilesServices::ProcessContent).to receive(:call)
    end

    it 'parse JSON file' do
      process_file

      expect(FilesServices::ProcessContent).to have_received(:call).with(expected_content, user.id)
    end
  end

  context 'when filetype is Unknown' do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        filename: 'transactions.csv',
        type: 'application/xpto',
        tempfile: File.new("#{file_fixture_path}/transactions.json")
      )
    end

    it 'raises error' do
      expect { process_file }.to raise_error(FilesServices::ProcessFile::UnknownFileTypeError)
    end
  end
end
