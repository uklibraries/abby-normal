class Status < ActiveRecord::Base
  attr_accessible :name

  def self.status_by_name symbol
    define_singleton_method symbol do
      Status.by_name symbol.to_s.gsub(/_/, ' ')
    end
  end

  status_by_name :ready
  status_by_name :not_ready
  status_by_name :started
  status_by_name :completed
  status_by_name :archived
  status_by_name :failed

  def self.by_name name
    Status.where(:name => name).first
  end
end
