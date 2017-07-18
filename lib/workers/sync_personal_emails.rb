module Workers
  class SyncPersonalEmails
    include Sidekiq::Worker

    class TrogdirAPIError < StandardError; end

    sidekiq_options retry: false

    def perform
      Log.info "[#{jid}] Starting job for Login Syncinator"

      hashes = []
      response = []

      begin
        loop do
          response = change_syncs.start(limit: 10).perform
          break if response.parse.empty?
          raise TrogdirAPIError, response.parse['error'] unless response.success?

          hashes += Array(response.parse)
        end
      rescue StandardError => error
          Log.error "Error in SyncPersonalEmails: #{error.message}"
      end

      changes = hashes.map { | hash| TrogdirChange.new(hash) }


      # Keep processing batches until we run out
      if changes.any?
        changes.each do |change|
          if change.create? && (change.personal_email? || change.netid?)
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
