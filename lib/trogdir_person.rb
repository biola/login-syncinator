class TrogdirPerson
  attr_reader :uuid

  def initialize(uuid)
    @uuid = uuid
  end

  def biola_id
    biola_id = get_value_from_nested_record(:ids, :biola_id, :identifier)
    biola_id.to_i unless biola_id.nil?
  end

  def netid
    get_value_from_nested_record(:ids, :netid, :identifier)
  end

  def personal_email
    get_value_from_nested_record(:emails, :personal, :address)
  end

  private

  def hash
    @hash ||= Trogdir::APIClient::People.new.show(uuid: uuid).perform.parse
  end

  def get_value_from_nested_record(collection, type, return_attr)
    record = Array(hash[collection.to_s]).find { |record| record['type'] == type.to_s }
    record[return_attr.to_s] unless record.nil?
  end
end
