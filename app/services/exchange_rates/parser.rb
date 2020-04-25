require 'net/http'

module ExchangeRates
  class Parser
    URL = 'http://www.cbr.ru/scripts/XML_daily.asp'.freeze

    def initialize(exchange_rate, force)
      @exchange_rate = exchange_rate
      @force = force
    end

    def call
      return if !@force && @exchange_rate.rate_at > Time.zone.now

      response_body = get_content_by_url
      raise 'Could not retrieve data from URL' unless response_body

      rate_value = extract_rate_value(response_body)
      return if rate_value.zero?

      ExchangeRate.where(id: @exchange_rate).update_all(rate_value: rate_value)
      ExchangeRates::Push.new(@exchange_rate.reload).call
    end

    private

    def get_content_by_url
      uri = URI.parse(URL)

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      raise response.error! unless response.is_a?(Net::HTTPSuccess)

      response.body
    rescue StandardError
      false
    end

    def extract_rate_value(response_body)
      result = 0
      xml_doc = Nokogiri::XML(response_body)
      root_element = xml_doc.xpath('ValCurs').first
      return result unless root_element.present?

      xml_doc.xpath('//Valute').each do |element|
        currency = element.xpath('CharCode').text
        next unless currency.downcase == @exchange_rate.currency

        result = element.xpath('Value').text.gsub(',', '.').to_f
        break
      end

      result
    end
  end
end
