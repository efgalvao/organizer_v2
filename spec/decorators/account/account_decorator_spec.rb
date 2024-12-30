require 'rails_helper'

RSpec.describe Account::AccountDecorator do
  subject(:decorated_account) { account.decorate }

  describe '#balance' do
    let(:account) { create(:account, balance: 12.34) }

    it 'returns the balance in the correct format' do
      expect(decorated_account.balance).to eq('R$ 12,34')
    end
  end

  describe '#type' do
    context 'when the type is broker' do
      let(:account) { create(:account, :broker) }

      it 'returns the type in the correct format' do
        expect(decorated_account.type).to eq('Corretora')
      end
    end

    context 'when the type is savings' do
      let(:account) { create(:account) }

      it 'returns the type in the correct format' do
        expect(decorated_account.type).to eq('Banco')
      end
    end

    context 'when the type is card' do
      let(:account) { create(:account, :card) }

      it 'returns the type in the correct format' do
        expect(decorated_account.type).to eq('Cartão')
      end
    end

    context 'when the type is unknown' do
      let(:account) { create(:account, type: 'unknown') }

      it 'returns the type in the correct format' do
        expect(decorated_account.type).to eq('Desconhecido')
      end
    end
  end

  describe '#current_report' do
    let(:account) do
      create(:account, account_reports: [report, old_report])
    end
    let(:report) { create(:account_report, reference: Date.current.strftime('%m%y')) }
    let(:old_report) { create(:account_report, reference: (Date.current - 2.months).strftime('%m%y')) }

    it 'returns the balance in the correct format' do
      expect(decorated_account.current_report).to eq(report.decorate)
    end
  end

  describe '#investments' do
    let(:account) do
      create(:account, investments: [investment])
    end
    let(:investment) { create(:investment) }

    it 'returns the balance in the correct format' do
      expect(decorated_account.investments).to eq([investment.decorate])
    end
  end

  describe '#past_reports' do
    let(:account) do
      create(:account, account_reports: [report, old_report])
    end
    let(:report) { create(:account_report, reference: Date.current.strftime('%m%y')) }
    let(:old_report) do
      create(:account_report, reference: (Date.current - 2.months).strftime('%m%y'),
                              date: Date.current - 2.months)
    end

    it 'returns the balance in the correct format' do
      expect(decorated_account.past_reports).to eq([old_report.decorate])
    end
  end

  describe '#past_reports_chart_data' do
    let(:account) do
      create(:account, account_reports: [old_report])
    end
    let(:old_report) do
      create(:account_report, reference: (Date.current - 2.months).strftime('%m%y'),
                              date: Date.current - 2.months)
    end
    let(:chart_data) do
      {
        balances: { old_report.date.strftime('%B-%Y').to_s => old_report.month_balance },
        expenses: { old_report.date.strftime('%B-%Y').to_s => old_report.month_expense },
        incomes: { old_report.date.strftime('%B-%Y').to_s => old_report.month_income },
        invested: { old_report.date.strftime('%B-%Y').to_s => old_report.month_invested }
      }
    end

    it 'returns the balance in the correct format' do
      expect(decorated_account.past_reports_chart_data).to eq(chart_data)
    end
  end

  describe '#broker?' do
    let(:account) { create(:account) }

    it 'returns true if the account is a broker' do
      broker = create(:account, :broker)
      decorated_broker = described_class.decorate(broker)
      expect(decorated_broker.broker?).to be(true)
    end

    it 'returns false if the account is not a broker' do
      expect(decorated_account.broker?).to be(false)
    end
  end

  describe '#back_path' do
    let(:account) { create(:account) }

    it 'returns the path to the card' do
      expect(decorated_account.back_path).to eq("/accounts/#{account.id}")
    end
  end
end
