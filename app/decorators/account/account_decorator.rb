module Account
  class AccountDecorator < Draper::Decorator
    delegate_all

    def balance
      object.balance_cents / 100.0
    end

    def kind
      case object.kind
      when 'savings' then 'Banco'
      when 'broker' then 'Corretora'
      when 'card' then 'Cartão'
      else 'Desconhecido'
      end
    end
  end
end
