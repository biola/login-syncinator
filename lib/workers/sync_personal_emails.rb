module Workers
  class SyncPersonalEmails
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    class TrogdirAPIError < StandardError; end

    sidekiq_options retry: false

    recurrence do
      hourly.hour_of_day(*(8..20).to_a).day(:monday, :tuesday, :wednesday, :thursday, :friday)
    end

    def perform
      response = change_syncs.start.perform
      raise TrogdirAPIError, response.parse['error'] unless response.success?

      hashes = Array(response.parse)
      changes = hashes.map { | hash| TrogdirChange.new(hash) }

      # Keep processing batches until we run out
      if changes.any?
        changes.each do |change|
          if (change.create? || change.update?) && (change.personal_email? || change.netid?)
            SyncPersonalEmail.perform_async(change.sync_log_id, change.person_uuid)
          else
            TrogdirChangeFinishWorker.perform_async(change.sync_log_id, :skip)
          end
        end

        SyncPersonalEmails.perform_async
      end
    end

    private

    def change_syncs
      Trogdir::APIClient::ChangeSyncs.new
    end
  end
end
