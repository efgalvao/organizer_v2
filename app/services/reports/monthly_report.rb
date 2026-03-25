module Reports
  class MonthlyReport
    IDEAL_LIMIT = 5500.0

    def initialize(user, date)
      @user = user
      @date = date.to_date
    end

    def self.call(user, date = Time.zone.today)
      new(user, date).call
    end

    def call
      transactions = @user.transactions
                          .where(date: @date.beginning_of_month..@date.next_month.end_of_month)
                          .where.not(type: ['Account::Transference', 'Account::InvoicePayment'])
                          .includes(:account)

      current_month_trans = transactions.select { |t| @date.all_month.cover?(t.date) }
      next_month_trans    = transactions.select { |t| t.date >= @date.next_month.beginning_of_month }

      {
        metadata: {
          period: I18n.l(@date, format: '%B %Y').capitalize,
          generated_at: Time.current
        },
        totals: calculate_totals(current_month_trans),
        forecast: calculate_forecast(current_month_trans, next_month_trans),
        limit_progress: calculate_limit_progress(current_month_trans),
        transactions: format_transactions(current_month_trans),
        income_quality: calculate_income_quality(current_month_trans)
      }
    end

    private

    def calculate_totals(current_trans)
      expenses = current_trans.select { |t| t.type == 'Account::Expense' }
      incomes  = current_trans.select { |t| t.type == 'Account::Income' }

      total_income   = sum_values(incomes)
      debit_realized = sum_values(expenses.reject { |e| e.account.card? })

      # Ajuste aqui: usando o método booleano .one_time? que o enum fornece para cada objeto
      fixed_val    = sum_values(expenses.select { |t| t.recurring? || t.installment? })
      eventual_val = sum_values(expenses.select(&:one_time?))

      {
        incomes: total_income,
        expenses_total: sum_values(expenses),
        debit_realized: debit_realized,
        fixed_realized: fixed_val,
        eventual_realized: eventual_val,
        current_balance: total_income - debit_realized
      }
    end

    def sum_values(transactions)
      # O to_a garante que se vier um Relation do ActiveRecord ou um Array simples, funcione igual
      transactions.to_a.sum { |t| t.amount.to_f }.abs
    end

    def calculate_forecast(current_trans, next_trans)
      # Fatura: Gastos de cartão do mês atual (independente da recorrência)
      estimated_invoice = sum_values(current_trans.select { |t| t.account.card? && t.type == 'Account::Expense' })

      # Fixos de Débito: O que já está agendado no banco para o mês que vem
      # Agora usamos os métodos do enum: .recurring? (mensal) e .installment? (parcelado)
      debit_fixed = sum_values(next_trans.select { |t| !t.account.card? && (t.recurring? || t.installment?) })

      # Fallback: Se não houver lançamentos futuros, espelhamos o que é recorrente no débito atual
      debit_fixed = sum_values(current_trans.select { |t| !t.account.card? && t.recurring? }) if debit_fixed.zero?

      {
        fatura_estimada: estimated_invoice,
        fixos_debito: debit_fixed,
        total_comprometido: estimated_invoice + debit_fixed
      }
    end

    def debit_fixed?(transaction)
      !transaction.account.card? && (transaction.recurring? || transaction.installment?)
    end

    def calculate_limit_progress(current_trans)
      spent = current_trans.select { |t| t.type == 'Account::Expense' && t.account.card? }
                           .sum { |t| t.amount.to_f }.abs

      percent = IDEAL_LIMIT.positive? ? (spent / IDEAL_LIMIT * 100).round(2) : 0

      {
        limit: IDEAL_LIMIT,
        spent: spent,
        percent: [percent, 100].min,
        is_over_limit: spent > IDEAL_LIMIT
      }
    end

    def format_transactions(transactions)
      formatted = transactions.filter_map do |t|
        next unless ['Account::Income', 'Account::Expense'].include?(t.type)

        {
          date_raw: t.date,
          date: t.date&.strftime('%d/%m'),
          description: t.title,
          value: t.amount.to_f.abs,
          kind: format_kind(t)
        }
      end

      formatted.sort_by { |t| t[:date_raw] }
    end

    def format_kind(transaction)
      return 'Entrada' if transaction.type == 'Account::Income'

      case transaction.recurrence
      when 'recurring'   then 'Fixo'
      when 'installment' then 'Parcelado'
      else 'Eventual'
      end
    end

    def calculate_income_quality(current_trans)
      incomes = current_trans.select { |t| t.type == 'Account::Income' }

      recurring_income = incomes.select(&:recurring?).sum { |t| t.amount.to_f }.abs
      one_time_income  = incomes.select(&:one_time?).sum { |t| t.amount.to_f }.abs

      {
        guaranteed_ratio: if recurring_income.positive?
                            (recurring_income / (recurring_income + one_time_income) * 100)
                              .round
                          else
                            0
                          end,
        recurring_value: recurring_income,
        one_time_value: one_time_income
      }
    end
  end
end
