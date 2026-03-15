# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Files::ProcessFile do
  subject(:process_file) { described_class.call(params, user.id) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:file) { instance_double(File, path: '/tmp/sample.csv') }
  let(:origin) { 'bb_statement' }
  let(:params) do
    {
      file: file,
      account_id: account.id,
      origin: origin
    }
  end

  before do
    allow(Files::ProcessContent).to receive(:call)
  end

  describe '.call' do
    it 'instantiates the service with params and user_id and invokes #call' do
      instance = instance_double(described_class, call: nil)
      allow(described_class).to receive(:new).with(params, user.id).and_return(instance)

      process_file

      expect(instance).to have_received(:call)
    end

    context "when origin is 'nu_invoice'" do
      let(:origin) { 'nu_invoice' }
      let(:parsed_content) { [{ date: '01/03/2026', title: 'Fatura', amount: 500.0 }] }

      before do
        allow(Files::NuInvoiceCsvParser).to receive(:call)
          .with(file, account.id)
          .and_return(parsed_content)
      end

      it 'calls NuInvoiceCsvParser with file and account_id' do
        process_file

        expect(Files::NuInvoiceCsvParser).to have_received(:call).with(file, account.id)
      end

      it 'passes parsed content to ProcessContent' do
        process_file

        expect(Files::ProcessContent).to have_received(:call).with(parsed_content)
      end
    end

    context "when origin is 'nu_statement'" do
      let(:origin) { 'nu_statement' }
      let(:parsed_content) { [{ date: '01/03/2026', title: 'Pagamento', amount: 100.0 }] }

      before do
        allow(Files::NuStatementCsvParser).to receive(:call)
          .with(file, account.id)
          .and_return(parsed_content)
      end

      it 'calls NuStatementCsvParser with file and account_id' do
        process_file

        expect(Files::NuStatementCsvParser).to have_received(:call).with(file, account.id)
      end

      it 'passes parsed content to ProcessContent' do
        process_file

        expect(Files::ProcessContent).to have_received(:call).with(parsed_content)
      end
    end

    context "when origin is 'bb_statement'" do
      let(:origin) { 'bb_statement' }
      let(:parsed_content) { [] }

      before do
        allow(Files::BbStatementCsvParser).to receive(:call)
          .with(file, account.id)
          .and_return(parsed_content)
      end

      it 'calls BbStatementCsvParser with file and account_id' do
        process_file

        expect(Files::BbStatementCsvParser).to have_received(:call).with(file, account.id)
      end

      it 'passes parsed content to ProcessContent' do
        process_file

        expect(Files::ProcessContent).to have_received(:call).with(parsed_content)
      end
    end

    context "when origin is 'ml_statement'" do
      let(:origin) { 'ml_statement' }
      let(:parsed_content) { [{ date: '01/03/2026', title: 'Pix', amount: 100.0 }] }

      before do
        allow(Files::Parsers::MlStatementCsvParser).to receive(:call)
          .with(file, account.id)
          .and_return(parsed_content)
      end

      it 'calls MlStatementCsvParser with file and account_id' do
        process_file

        expect(Files::Parsers::MlStatementCsvParser).to have_received(:call).with(file, account.id)
      end

      it 'passes parsed content to ProcessContent' do
        process_file

        expect(Files::ProcessContent).to have_received(:call).with(parsed_content)
      end
    end

    context 'when account does not belong to user' do
      let(:origin) { 'ml_statement' }
      let(:other_user) { create(:user) }
      let(:account) { create(:account, user: other_user) }

      before do
        allow(Files::Parsers::MlStatementCsvParser).to receive(:call)
      end

      it 'does not call the parser' do
        process_file

        expect(Files::Parsers::MlStatementCsvParser).not_to have_received(:call)
      end

      it 'does not call ProcessContent' do
        process_file

        expect(Files::ProcessContent).not_to have_received(:call)
      end

      it 'returns nil (early return)' do
        expect(process_file).to be_nil
      end
    end

    context 'when account is not found' do
      let(:origin) { 'nu_statement' }
      let(:params) do
        {
          file: file,
          account_id: 999_999,
          origin: origin
        }
      end

      before do
        allow(AccountRepository).to receive(:find_by).with(id: 999_999).and_return(nil)
      end

      it 'raises when checking account ownership' do
        expect { process_file }.to raise_error(NoMethodError)
      end
    end

    context 'when origin is invalid' do
      let(:origin) { 'unknown_origin' }

      it 'raises UnknownFileTypeError' do
        expect { process_file }.to raise_error(Files::ProcessFile::UnknownFileTypeError, 'Invalid Origin')
      end

      it 'does not call ProcessContent' do
        expect { process_file }.to raise_error(Files::ProcessFile::UnknownFileTypeError)
        expect(Files::ProcessContent).not_to have_received(:call)
      end
    end

    context 'when return value' do
      let(:origin) { 'bb_statement' }
      let(:parsed_content) { [] }
      let(:process_content_result) { instance_double(Object) }

      before do
        allow(Files::BbStatementCsvParser).to receive(:call).with(file, account.id).and_return(parsed_content)
        allow(Files::ProcessContent).to receive(:call).with(parsed_content).and_return(process_content_result)
      end

      it 'returns the result of ProcessContent.call' do
        expect(process_file).to eq(process_content_result)
      end
    end
  end

  describe Files::ProcessFile::UnknownFileTypeError do
    it 'inherits from StandardError' do
      expect(described_class).to be < StandardError
    end
  end
end
