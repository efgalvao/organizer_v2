require 'rails_helper'

RSpec.describe 'Route authentication' do
  public_paths = [
    '/login',
    '/signup',
    '/logout',
    '/refresh_historical_location',
    '/resume_historical_location',
    '/recede_historical_location'
  ].freeze

  Rails.application.routes.routes.each do |r|
    next if r.path.spec.to_s.include?('rails')
    next if r.defaults[:controller].blank?
    next if r.verb.blank?
    next if public_paths.any? { |public_path| r.path.spec.to_s.gsub('(.:format)', '').start_with?(public_path) }

    it "requires authentication for #{r.verb} #{r.path.spec}" do
      path = r.path.spec.to_s.gsub('(.:format)', '')
      verb = r.verb.respond_to?(:source) ? r.verb.source.gsub(/[$^]/, '') : r.verb.to_s

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
