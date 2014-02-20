class Status < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail

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
  status_by_name :under_review
  status_by_name :awaiting_approval
  status_by_name :approved
  status_by_name :rejected # XXX: deprecated

  def self.by_name name
    Status.where(:name => name).first
  end
end
