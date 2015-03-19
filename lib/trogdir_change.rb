class TrogdirChange
  attr_reader :hash
  def initialize(hash)
    @hash = hash
  end

  def sync_log_id
    hash['sync_log_id']
  end

  def person_uuid
    hash['person_id']
  end

  def create?
    hash['action'] == 'create'
  end

  def personal_email?
    scope == 'email' && type == 'personal'
  end

  def netid?
    scope == 'id' && type == 'netid'
  end

  private

  def scope
    hash['scope']
  end

  def type
    all_attrs = hash['all_attributes']
    all_attrs['type'] unless all_attrs.nil?
  end
end
