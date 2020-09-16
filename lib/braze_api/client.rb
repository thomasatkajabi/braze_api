require 'faraday'
require 'JSON'
require 'braze_api/response/raise_error'
require 'braze_api/errors'

module BrazeAPI
  # The top-level class that handles configuration and connection to the Braze API.
  class Client
    def initialize(api_key:, braze_url:, app_id:)
      @api_key = api_key
      @braze_url = braze_url
      @app_id = app_id
    end

    # Returns a parsed response from a post request
    def post(endpoint, params: {})
      response = client.post(endpoint, params.to_json)
      JSON.parse(response.body)
    end

    private

    attr_reader :api_key, :app_id, :braze_url
    # Creates a Faraday connection if there is none, otherwise returns the existing.
    def client
      @client ||= Faraday.new(braze_url) do |faraday|
        faraday.use BrazeAPI::Response::RaiseError
        faraday.adapter Faraday.default_adapter
        faraday.headers['User-Agent'] = "Braze API Client gem v#{BrazeAPI::VERSION}"
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['Authorization'] = "Bearer #{api_key}"
      end
    end
  end
end