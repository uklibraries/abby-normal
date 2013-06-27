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
  type_by_name "Index into Test Solr"
end
