# frozen_string_literal: true

class TestSidekiqJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "=" * 50
    Rails.logger.info "TEST SIDEKIQ JOB EXECUTED SUCCESSFULLY"
    Rails.logger.info "Time: #{Time.current}"
    Rails.logger.info "=" * 50
  end
end
