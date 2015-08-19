module Workers
  class SyncPersonalEmail
    include Sidekiq::Worker

    sidekiq_options retry: false

    def perform(sync_log_id, person_uuid)
      begin
        trogdir_person = TrogdirPerson.new(person_uuid)

        if !trogdir_person.personal_email
          Log.info "No personal email for #{person_uuid}. Nothing to do yet."
          TrogdirChangeFinishWorker.perform_async(sync_log_id, :skip)
          return false
        elsif !trogdir_person.netid
          Log.info "No NetID for #{person_uuid}. Nothing to do yet."
          TrogdirChangeFinishWorker.perform_async(sync_log_id, :skip)
          return false
        end

        login_personal_email = LoginPersonalEmail.new(trogdir_person.netid)

        if login_personal_email.exists?
          login_personal_email.update! trogdir_person.personal_email
          Log.info %{Login personalemail record updated for "#{trogdir_person.netid}" with email "#{trogdir_person.personal_email}".}
          TrogdirChangeFinishWorker.perform_async(sync_log_id, :update)
          return true
        else
          login_personal_email.create! trogdir_person.personal_email
          Log.info %{Login personalemail record created for "#{trogdir_person.netid}" with email "#{trogdir_person.personal_email}".}
          TrogdirChangeFinishWorker.perform_async(sync_log_id, :create)
          return true
        end
      rescue StandardError => err
        TrogdirChangeErrorWorker.perform_async(sync_log_id, err.message)
        Raven.capture_exception(err) if defined? Raven
      end
    end
  end
end
