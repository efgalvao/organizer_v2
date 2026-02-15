module FilesServices
  class BbStatementCsvParser
    require 'csv'

    PARCELS           = 1
    DATE_INDEX        = 0
    LANCAMENTO_INDEX  = 1
    DETALHES_INDEX    = 2
    DOCUMENTO_INDEX   = 3
    VALOR_INDEX       = 4
    TIPO_INDEX        = 5

    IGNORED_LANCAMENTOS = ['Saldo Anterior', 'Saldo do dia', 'SALDO'].freeze

    def initialize(file, account_id)
      @file = file
      @account_id = account_id
    end

    def self.call(file, account_id)
      new(file, account_id).call
    end

    def call
      parse_file
    end

    private

    attr_reader :file, :account_id

    def parse_file
      transactions = []
      first_row = true

      CSV.foreach(Rails.root + file.path, headers: false) do |row|
        # Skip header row
        if first_row
          first_row = false
          next
        end

        # Skip rows with ignored lançamentos
        next if ignored_lancamento?(row[LANCAMENTO_INDEX])

        # Skip rows with invalid dates (00/00/0000)
        next if row[DATE_INDEX] == '00/00/0000'

        transactions << parse_transaction(row)
      end
      transactions
    end

    def parse_transaction(row)
      tipo_lancamento = row[TIPO_INDEX].to_s.strip
      is_saida = tipo_lancamento == 'Saída'
      is_entrada = tipo_lancamento == 'Entrada'

      {
        date: row[DATE_INDEX],
        title: build_title(row[LANCAMENTO_INDEX], row[DETALHES_INDEX]),
        amount: format_amount(row[VALOR_INDEX]),
        category: nil,
        kind: if is_saida
                0
              else
                (is_entrada ? 1 : 0)
              end,
        type: if is_saida
                0
              else
                (is_entrada ? 1 : 0)
              end,
        parcels: PARCELS,
        group: is_saida ? 5 : nil,
        account: account.name
      }
    end

    def account
      @account ||= Account::Account.find(account_id)
    end

    def ignored_lancamento?(lancamento)
      return true if lancamento.nil? || lancamento.strip.empty?

      # Normalize by removing spaces and converting to uppercase for comparison
      normalized = lancamento.strip.gsub(/\s+/, '').upcase
      IGNORED_LANCAMENTOS.any? { |ignored| ignored.gsub(/\s+/, '').upcase == normalized }
    end

    def build_title(lancamento, detalhes)
      title_parts = [lancamento, detalhes].compact.reject(&:empty?)
      title_parts.join(' ').strip
    end

    def format_amount(amount_str)
      # Convert Brazilian format (e.g., "429,09" or "1.300,45") to decimal
      # Remove dots (thousands separator) and replace comma with dot (decimal separator)
      normalized = amount_str.to_s.strip
                             .gsub('.', '') # Remove thousands separator
                             .gsub(',', '.') # Replace decimal comma with dot
      normalized.to_d.abs
    end
  end
end
