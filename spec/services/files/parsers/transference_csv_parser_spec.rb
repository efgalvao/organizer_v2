# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

RSpec.describe Files::Parsers::TransferenceCsvParser do
  subject(:parser_call) { described_class.call(file, user_id) }

  let(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:account_origem) { create(:account, user: user, name: 'Conta Origem') }
  let(:account_destino) { create(:account, user: user, name: 'Conta Destino') }
  let(:accounts) { [account_origem, account_destino] }

  before do
    allow(AccountRepository).to receive(:all_by_user).with(user_id).and_return(accounts)
  end

  def build_csv_file(rows)
    tempfile = Tempfile.new(['transferences', '.csv'])
    rows.each { |row| tempfile.puts(row.join(';')) }
    tempfile.rewind
    tempfile
  end

  after do
    file&.close
    file&.unlink
  end

  describe '.call' do
    context 'delegation' do
      let(:file) { build_csv_file([]) }

      it 'instantiates the parser with file and user_id and invokes #call' do
        instance = instance_double(described_class, call: [])
        allow(described_class).to receive(:new).with(file, user_id).and_return(instance)

        parser_call

        expect(instance).to have_received(:call)
      end
    end

    context 'with a single valid row' do
      let(:file) do
        build_csv_file([
                         ['01/03/2026', '150.00', 'Conta Origem', 'Conta Destino']
                       ])
      end

      it 'returns the parsed transference with resolved account ids' do
        expect(parser_call).to eq(
          [
            {
              date: '01/03/2026',
              amount: '150.00',
              sender_id: account_origem.id,
              receiver_id: account_destino.id,
              user_id: user_id
            }
          ]
        )
      end

      it 'fetches accounts scoped to the given user_id' do
        parser_call

        expect(AccountRepository).to have_received(:all_by_user).with(user_id)
      end
    end

    context 'with multiple valid rows' do
      let(:file) do
        build_csv_file([
                         ['01/03/2026', '150.00', 'Conta Origem', 'Conta Destino'],
                         ['02/03/2026', '50.00', 'Conta Destino', 'Conta Origem']
                       ])
      end

      it 'parses every valid row' do
        expect(parser_call.size).to eq(2)
      end

      it 'memoizes the account lookup and calls AccountRepository only once' do
        parser_call

        expect(AccountRepository).to have_received(:all_by_user).once
      end
    end

    context 'when account names differ in casing or have surrounding whitespace' do
      let(:file) do
        build_csv_file([
                         ['01/03/2026', '150.00', '  CONTA ORIGEM  ', 'conta destino']
                       ])
      end

      it 'matches accounts case-insensitively and ignoring whitespace' do
        result = parser_call.first

        expect(result[:sender_id]).to eq(account_origem.id)
        expect(result[:receiver_id]).to eq(account_destino.id)
      end
    end

    context 'when the sender account name is unknown' do
      let(:file) do
        build_csv_file([
                         ['01/03/2026', '150.00', 'Conta Inexistente', 'Conta Destino']
                       ])
      end

      it 'sets sender_id to nil' do
        expect(parser_call.first[:sender_id]).to be_nil
      end

      it 'still resolves the known receiver' do
        expect(parser_call.first[:receiver_id]).to eq(account_destino.id)
      end
    end

    context 'when the receiver account name is unknown' do
      let(:file) do
        build_csv_file([
                         ['01/03/2026', '150.00', 'Conta Origem', 'Conta Inexistente']
                       ])
      end

      it 'sets receiver_id to nil' do
        expect(parser_call.first[:receiver_id]).to be_nil
      end

      it 'still resolves the known sender' do
        expect(parser_call.first[:sender_id]).to eq(account_origem.id)
      end
    end

    context 'when a row is missing a required field' do
      let(:file) do
        build_csv_file([
                         ['01/03/2026', '', 'Conta Origem', 'Conta Destino'],
                         ['', '50.00', 'Conta Origem', 'Conta Destino'],
                         ['01/03/2026', '50.00', '', 'Conta Destino'],
                         ['01/03/2026', '50.00', 'Conta Origem', '']
                       ])
      end

      it 'skips every invalid row' do
        expect(parser_call).to eq([])
      end
    end

    context 'when a row has fewer columns than required' do
      let(:file) { build_csv_file([['01/03/2026', '50.00', 'Conta Origem']]) }

      it 'skips the row' do
        expect(parser_call).to eq([])
      end
    end

    context 'when the file mixes valid and invalid rows' do
      let(:file) do
        build_csv_file([
                         ['01/03/2026', '150.00', 'Conta Origem', 'Conta Destino'],
                         ['02/03/2026', '', 'Conta Origem', 'Conta Destino'],
                         ['03/03/2026', '30.00', 'Conta Destino', 'Conta Origem']
                       ])
      end

      it 'parses only the valid rows, preserving order' do
        result = parser_call

        expect(result.size).to eq(2)
        expect(result.map { |t| t[:date] }).to eq(%w[01/03/2026 03/03/2026])
      end
    end

    context 'when the file has no rows' do
      let(:file) { build_csv_file([]) }

      it 'returns an empty array' do
        expect(parser_call).to eq([])
      end

      it 'does not attempt to resolve any account (lazy memoization is never triggered)' do
        parser_call

        expect(AccountRepository).not_to have_received(:all_by_user)
      end
    end

    context 'when the accounts belong only to the given user' do
      let(:other_user) { create(:user) }

      let(:file) do
        build_csv_file([
                         ['01/03/2026', '150.00', 'Conta Origem', 'Conta Destino']
                       ])
      end

      before do
        allow(AccountRepository).to receive(:all_by_user).with(user_id).and_return(accounts)
      end

      it 'only queries AccountRepository for the transference user_id, not any other' do
        parser_call

        expect(AccountRepository).not_to have_received(:all_by_user).with(other_user.id)
      end
    end
  end
end
