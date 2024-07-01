require 'csv'

module FilesServices
  class ImportTransactionsFromCsv
    def initialize(file_path)
      @file_path = file_path
    end

    def self.call(file_path)
      new(file_path).call
    end

    def call
      transactions = []
      CSV.foreach(file_path, headers: true) do |row|
        transactions << build_transaction(row)
      end
      transactions.each { |transaction| AccountServices::ProcessTransactionRequest.call(transaction) }
    end

    private

    attr_reader :file_path

    def build_transaction(row)
      {
        account_id: account_id(row['account_name']).id,
        kind: row['kind'],
        value: (row['value_cents'].to_f / 100.0),
        date: row['date'],
        category_id: category_id(row['category_name']).id,
        title: row['title']
      }
    end

    def account_id(name)
      downcased_name = name.downcase.strip
      # binding.pry
      Account::Account.find_by('LOWER(name) = ?', downcased_name)
    end

    def category_id(name)
      downcased_name = name.downcase.strip
      Category.find_by('LOWER(name) = ?', downcased_name)
    end
  end
end

# [[2,	'Financiamento'],
# [6,	'Escola'],
# [7,	'Eleonora'],
# [9,	'Pendente'],
# [10,	'Carro'],
# [12,	'Juros'],
# [13,	'Diversos'],
# [14,	'Celular'],
# [17,	'Recebimentos'],
# [18,	'Mercado'],
# [15,	'Saude'],
# [11,	'Salario'],
# [8,	'Diversao'],
# [5,	'Alimentacao'],
# [19,	'Imposto'],
# [20,	'Presente'],
# [21,	'Manutencao da casa'],
# [22,	'Gastos mensais']]

# a.each {|c| Category.create(id: c[0], name: c[1], user_id: 1)}
