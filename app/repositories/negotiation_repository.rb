module NegotiationRepository
  module_function

  def create!(attributes)
    Investments::Negotiation.create!(attributes)
  end

  def find_all_by_id(id)
    Investments::Negotiation.where(negotiable_id: id).order(date: :desc).limit(5)
  end
end
