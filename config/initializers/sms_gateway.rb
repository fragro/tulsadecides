# frozen_string_literal: true

# Configure SMS Gateway for Decidim verifications
Decidim.configure do |config|
  config.sms_gateway_service = "TwilioSmsGateway"
end
