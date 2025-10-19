# spec/requests/route_authentication_spec.rb
require 'rails_helper'

RSpec.describe 'Route authentication' do
  Rails.application.routes.routes.each do |r|
    next if r.path.spec.to_s.include?('rails') # ignora rotas internas
    next if r.defaults[:controller].blank?
    next if r.verb.blank?

    path = r.path.spec.to_s.gsub('(.:format)', '')

    # ignora rotas públicas
    next if [
      '/login',
      '/signup',
      '/logout',
      '/refresh_historical_location',
      '/resume_historical_location',
      '/recede_historical_location'
    ].any? { |public_path| path.start_with?(public_path) }

    verb = r.verb.respond_to?(:source) ? r.verb.source.gsub(/[$^]/, '') : r.verb.to_s

    it "requires authentication for #{verb} #{path}" do
      case verb
      when 'GET'
        get path
      when 'POST'
        post path
      when 'PUT', 'PATCH'
        put path
      when 'DELETE'
        delete path
      end

      expect(response).to redirect_to(login_path).or have_http_status(:unauthorized)
    end
  end
end
