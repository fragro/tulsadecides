# frozen_string_literal: true

namespace :sidekiq do
  desc "Check Sidekiq health and connectivity"
  task health: :environment do
    require "sidekiq/api"

    puts "=" * 50
    puts "SIDEKIQ HEALTH CHECK"
    puts "=" * 50

    # Check Redis connectivity
    begin
      redis_info = Sidekiq.redis { |conn| conn.info }
      puts "✓ Redis connected (v#{redis_info["redis_version"]})"
    rescue => e
      puts "✗ Redis connection FAILED: #{e.message}"
      exit 1
    end

    # Check Sidekiq processes
    ps = Sidekiq::ProcessSet.new
    if ps.size > 0
      puts "✓ Sidekiq processes running: #{ps.size}"
      ps.each do |process|
        puts "  - PID #{process["pid"]}: #{process["concurrency"]} threads, #{process["busy"]} busy"
      end
    else
      puts "✗ No Sidekiq processes running\!"
      exit 1
    end

    # Check queues
    puts "\nQueues:"
    Sidekiq::Queue.all.each do |queue|
      puts "  - #{queue.name}: #{queue.size} jobs"
    end

    # Check stats
    stats = Sidekiq::Stats.new
    puts "\nStats:"
    puts "  - Processed: #{stats.processed}"
    puts "  - Failed: #{stats.failed}"
    puts "  - Enqueued: #{stats.enqueued}"
    puts "  - Scheduled: #{stats.scheduled_size}"
    puts "  - Retries: #{stats.retry_size}"
    puts "  - Dead: #{stats.dead_size}"

    puts "\n" + "=" * 50
    puts "SIDEKIQ HEALTH CHECK PASSED"
    puts "=" * 50
  end

  desc "Test Sidekiq by enqueuing a test job"
  task test: :environment do
    puts "Enqueuing test job..."
    TestSidekiqJob.perform_async
    puts "✓ Test job enqueued successfully"
    puts "Check logs with: journalctl -u sidekiq -f"
  end
end
