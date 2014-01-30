class Type < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail

  def self.type_by_name name
    method_create = name.downcase.gsub(/\s+/, '_').to_sym
    define_singleton_method method_create do
      Type.where(:name => name).first
    end
  end

  type_by_name "Approve Package"
  type_by_name "Archive Package"
  type_by_name "Create AIP"
  type_by_name "Create DIP"
  type_by_name "Create Solr JSON"
  type_by_name "Delete AIP Cache"
  type_by_name "Delete DIP Cache"
  type_by_name "Delete Log Cache"
  type_by_name "Delete SIP Cache"
  type_by_name "Delete Solr JSON Cache"
  type_by_name "Get Identifiers"
  type_by_name "Index into Solr"
  type_by_name "Index into Test Solr"
  type_by_name "Pull SIP"
  type_by_name "Store AIP"
  type_by_name "Store DIP"
  type_by_name "Store Logs"
  type_by_name "Store Oral History Files"
  type_by_name "Store Solr JSON"
  type_by_name "Store Test DIP"
  type_by_name "Store Test Oral History Files"
end
