require 'rails_helper'

RSpec.describe FilesServices::BbStatementCsvParser do
  subject(:parser) { described_class.call(file, account.id) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user, name: 'Banco do Brasil') }
  let(:csv_content) do
    <<~CSV
      "Data","Lançamento","Detalhes","Nº documento","Valor","Tipo Lançamento","Category","Group"
      "15/01/2026","Saldo Anterior","","","429,09","","",""
      "02/02/2026","Ordem Bancária","DEP FAZENDA E PLANEJAMENTO","202600000000001","871,36","Entrada","",""
      "00/00/0000","Saldo do dia","","","1.300,45","","",""
      "04/02/2026","Pix - Enviado","04/02 20:49 PESSOA EXEMPLO","20001","-150,00","Saída","","5"
      "00/00/0000","Saldo do dia","","","1.150,45","","",""
      "06/02/2026","Recebimento de Proventos","12.345.678/0001-90 EMPRESA EXEMPLO LTDA","10001","822,53","Entrada","",""
      "06/02/2026","Pix - Recebido","06/02 09:52 11999999999 PESSOA EXEMPLO","60952000000001","50,00","Entrada","",""
      "06/02/2026","Pix - Enviado","06/02 08:23 CICLANO DA SILVA","20002","-7.089,00","Saída","",""
      "18/02/2026","S A L D O","","","567,75","","",""
    CSV
  end
  let(:temp_file_path) do
    file_path = Rails.root.join('tmp', "bb_statement_#{SecureRandom.hex}.csv")
    File.write(file_path, csv_content)
    file_path
  end

  let(:file) do
    # Create a mock file object that returns the path
    # The parser uses Rails.root + file.path, so we return the relative path from Rails.root
    mock_file = double('File')
    relative_path = temp_file_path.relative_path_from(Rails.root).to_s
    allow(mock_file).to receive(:path).and_return(relative_path)
    mock_file
  end

  after do
    # Clean up the temp file
    File.unlink(temp_file_path) if File.exist?(temp_file_path)
  end

  describe '.call' do
    it 'returns an array of transactions', :aggregate_failures do
      result = parser

      expect(result).to be_an(Array)
      expect(result.length).to eq(5)
    end

    it 'ignores header row' do
      result = parser

      expect(result.none? { |t| t[:date] == 'Data' }).to be true
    end

    it 'ignores "Saldo Anterior" entries' do
      result = parser

      expect(result.none? { |t| t[:title].include?('Saldo Anterior') }).to be true
    end

    it 'ignores "Saldo do dia" entries' do
      result = parser

      expect(result.none? { |t| t[:title].include?('Saldo do dia') }).to be true
    end

    it 'ignores "SALDO" entries' do
      result = parser

      expect(result.none? { |t| t[:title].include?('SALDO') }).to be true
    end

    it 'ignores rows with invalid dates (00/00/0000)' do
      result = parser

      expect(result.none? { |t| t[:date] == '00/00/0000' }).to be true
    end

    it 'parses entrada transactions correctly', :aggregate_failures do
      result = parser
      entrada = result.find { |t| t[:title].include?('Ordem Bancária') }

      expect(entrada).not_to be_nil
      expect(entrada[:date]).to eq('02/02/2026')
      expect(entrada[:title]).to eq('Ordem Bancária DEP FAZENDA E PLANEJAMENTO')
      expect(entrada[:amount]).to eq(871.36)
      expect(entrada[:kind]).to eq(1)
      expect(entrada[:type]).to eq(1)
      expect(entrada[:parcels]).to eq(1)
      expect(entrada[:group]).to be_nil
      expect(entrada[:category]).to be_nil
      expect(entrada[:account]).to eq('Banco do Brasil')
    end

    it 'parses saída transactions correctly', :aggregate_failures do
      result = parser
      saida = result.find { |t| t[:title].include?('Pix - Enviado') && t[:amount] == 150.00 }

      expect(saida).not_to be_nil
      expect(saida[:date]).to eq('04/02/2026')
      expect(saida[:title]).to eq('Pix - Enviado 04/02 20:49 PESSOA EXEMPLO')
      expect(saida[:amount]).to eq(150.00)
      expect(saida[:kind]).to eq(0)
      expect(saida[:type]).to eq(0)
      expect(saida[:parcels]).to eq(1)
      expect(saida[:group]).to eq(5)
      expect(saida[:category]).to be_nil
      expect(saida[:account]).to eq('Banco do Brasil')
    end

    it 'formats Brazilian currency values correctly', :aggregate_failures do
      result = parser

      entrada_871 = result.find { |t| t[:amount] == 871.36 }
      entrada_822 = result.find { |t| t[:amount] == 822.53 }
      entrada_50 = result.find { |t| t[:amount] == 50.00 }
      saida_7089 = result.find { |t| t[:amount] == 7089.00 }

      expect(entrada_871).not_to be_nil
      expect(entrada_822).not_to be_nil
      expect(entrada_50).not_to be_nil
      expect(saida_7089).not_to be_nil
    end

    it 'concatenates lançamento and detalhes in title' do
      result = parser
      entrada = result.find { |t| t[:title].include?('Recebimento de Proventos') }

      expect(entrada[:title]).to eq('Recebimento de Proventos 12.345.678/0001-90 EMPRESA EXEMPLO LTDA')
    end

    it 'handles transactions with empty detalhes' do
      result = parser
      entrada = result.find { |t| t[:title] == 'Ordem Bancária DEP FAZENDA E PLANEJAMENTO' }

      expect(entrada).not_to be_nil
    end

    context 'when file has only ignored entries' do
      let(:csv_content) do
        <<~CSV
          "Data","Lançamento","Detalhes","Nº documento","Valor","Tipo Lançamento","Category","Group"
          "28/01/2026","Saldo Anterior","","","429,09","","",""
          "00/00/0000","Saldo do dia","","","1.300,45","","",""
          "18/02/2026","S A L D O","","","567,75","","",""
        CSV
      end

      it 'returns an empty array' do
        result = parser

        expect(result).to eq([])
      end
    end

    context 'when file is empty except for header' do
      let(:csv_content) do
        <<~CSV
          "Data","Lançamento","Detalhes","Nº documento","Valor","Tipo Lançamento","Category","Group"
        CSV
      end

      it 'returns an empty array' do
        result = parser

        expect(result).to eq([])
      end
    end
  end
end
