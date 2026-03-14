# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'
require 'bigdecimal'

RSpec.describe Files::Parsers::MlStatementCsvParser do
  subject(:parser) { described_class.call(file, account.id) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user, name: 'Mercado Livre') }
  let(:csv_content) do
    <<~CSV
      02/02/2026;Ordem Bancária;REF001;871,36;1300,00;;;
      04/02/2026;Pix - Enviado;REF002;-150,00;1150,00;;5
      06/02/2026;Recebimento;REF003;822,53;1972,53;Proventos;
      06/02/2026;Pix - Enviado;REF004;-7.089,00;567,75;Transferência;Grupo1
    CSV
  end
  let(:temp_file_path) do
    file_path = Rails.root.join('tmp', "ml_statement_#{SecureRandom.hex}.csv")
    File.write(file_path, csv_content)
    file_path
  end

  let(:file) do
    relative_path = temp_file_path.relative_path_from(Rails.root).to_s
    instance_double(File, path: relative_path)
  end

  after do
    FileUtils.rm_f(temp_file_path)
  end

  describe '.call' do
    it 'returns an array of transactions', :aggregate_failures do
      result = parser

      expect(result).to be_an(Array)
      expect(result.length).to eq(4)
    end

    it 'parses entrada transactions correctly', :aggregate_failures do
      result = parser
      entrada = result.find { |t| t[:title] == 'Ordem Bancária' }

      expect(entrada).not_to be_nil
      expect(entrada[:date]).to eq('02/02/2026')
      expect(entrada[:title]).to eq('Ordem Bancária')
      expect(entrada[:amount]).to eq(BigDecimal('871.36'))
      expect(entrada[:kind]).to eq(1)
      expect(entrada[:type]).to eq(1)
      expect(entrada[:parcels]).to eq(1)
      expect(entrada[:group]).to be_blank
      expect(entrada[:category]).to be_blank
      expect(entrada[:account]).to eq('Mercado Livre')
    end

    it 'parses saída transactions correctly', :aggregate_failures do
      result = parser
      saida = result.find { |t| t[:amount] == BigDecimal('150.0') }

      expect(saida).not_to be_nil
      expect(saida[:date]).to eq('04/02/2026')
      expect(saida[:title]).to eq('Pix - Enviado')
      expect(saida[:amount]).to eq(BigDecimal('150.0'))
      expect(saida[:kind]).to eq(0)
      expect(saida[:type]).to eq(0)
      expect(saida[:parcels]).to eq(1)
      expect(saida[:group]).to eq('5')
      expect(saida[:category]).to be_blank
      expect(saida[:account]).to eq('Mercado Livre')
    end

    it 'formats Brazilian currency values correctly', :aggregate_failures do
      result = parser

      expect(result.any? { |t| t[:amount] == BigDecimal('871.36') }).to be true
      expect(result.any? { |t| t[:amount] == BigDecimal('822.53') }).to be true
      expect(result.any? { |t| t[:amount] == BigDecimal('7089.0') }).to be true
    end

    it 'stores category and group from CSV columns', :aggregate_failures do
      result = parser
      with_category = result.find { |t| t[:category] == 'Proventos' }
      with_group = result.find { |t| t[:group] == 'Grupo1' }

      expect(with_category).not_to be_nil
      expect(with_category[:title]).to eq('Recebimento')
      expect(with_group).not_to be_nil
      expect(with_group[:category]).to eq('Transferência')
    end

    it 'uses absolute value for amount in output' do
      result = parser
      saida = result.find { |t| t[:title] == 'Pix - Enviado' && t[:date] == '04/02/2026' }

      expect(saida[:amount]).to eq(BigDecimal('150.0'))
      expect(saida[:amount]).to be_positive
    end

    context 'when row has blank date' do
      let(:csv_content) do
        <<~CSV
          02/02/2026;Valid;REF001;100,00;;;
          ;Blank date;REF002;50,00;;;
        CSV
      end

      it 'ignores the row with blank date' do
        result = parser

        expect(result.length).to eq(1)
        expect(result.first[:date]).to eq('02/02/2026')
      end
    end

    context 'when row has blank amount' do
      let(:csv_content) do
        <<~CSV
          02/02/2026;Valid;REF001;100,00;;;
          03/02/2026;Blank amount;REF002;;;
        CSV
      end

      it 'ignores the row with blank amount' do
        result = parser

        expect(result.length).to eq(1)
        expect(result.first[:title]).to eq('Valid')
      end
    end

    context 'when file has only rows with blank date or amount' do
      let(:csv_content) do
        <<~CSV
          ;No date;REF001;100,00;;;
          02/02/2026;No amount;REF002;;;
        CSV
      end

      it 'returns an empty array' do
        result = parser

        expect(result).to eq([])
      end
    end

    context 'when file is empty' do
      let(:csv_content) { '' }

      it 'returns an empty array' do
        result = parser

        expect(result).to eq([])
      end
    end
  end
end
