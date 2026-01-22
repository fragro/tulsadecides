# frozen_string_literal: true

# SMS Gateway for Twilio
# Used by Decidim SMS verification workflow
class TwilioSmsGateway
  attr_reader :mobile_phone_number, :code, :organization

  def initialize(mobile_phone_number, code, organization = nil)
    @mobile_phone_number = mobile_phone_number
    @code = code
    @organization = organization
  end

  def deliver_code
    return false if twilio_credentials_missing?

    client = Twilio::REST::Client.new(account_sid, auth_token)
    
    message = client.messages.create(
      from: from_number,
      to: mobile_phone_number,
      body: sms_body
    )

    message.sid.present?
  rescue Twilio::REST::RestError => e
    Rails.logger.error("Twilio SMS Error: #{e.message}")
    false
  end

  private

  def sms_body
    org_name = extract_org_name
    "Your #{org_name} verification code is: #{code}"
  end

  def extract_org_name
    return "TulsaDecides" if organization.nil?
    
    if organization.is_a?(Hash)
      organization[:name] || organization["name"] || "TulsaDecides"
    elsif organization.respond_to?(:name)
      organization.name
    else
      "TulsaDecides"
    end
  end

  def account_sid
    ENV.fetch("TWILIO_ACCOUNT_SID", nil)
  end

  def auth_token
    ENV.fetch("TWILIO_AUTH_TOKEN", nil)
  end

  def from_number
    ENV.fetch("TWILIO_PHONE_NUMBER", nil)
  end

  def twilio_credentials_missing?
    account_sid.blank? || auth_token.blank? || from_number.blank?
  end
end
