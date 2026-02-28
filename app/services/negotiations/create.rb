module Negotiations
  module Create
    class << self
      def call(attributes)
        NegotiationRepository.create!(attributes)
      end
    end
  end
end
