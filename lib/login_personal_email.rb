class LoginPersonalEmail
  attr_reader :netid

  NETID_SANITIZER = /[^a-z0-9]/i
  DB = Sequel.connect(Settings.login.db_connection_string)

  def initialize(netid)
    @netid = netid.gsub(NETID_SANITIZER, '')
  end

  def exists?
    !record.nil?
  end

  def email
    record[:email]
  end

  def create!(personal_email)
    DB[:personalemail].insert(netid: netid, email: personal_email)
  end

  private

  def record
    @record ||= DB[:personalemail].where(netid: netid).first
  end
end
