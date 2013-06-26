class Batch < ActiveRecord::Base
  belongs_to :batch_type
  belongs_to :server
  belongs_to :status
  attr_accessible :dark_archive, :name, :oral_history, :batch_type_id, :server_id, :status_id
  before_create :mark_as_started
  after_create :create_packages

  private

  def mark_as_started
    self.status ||= Status.started
  end

  def create_packages
    # find the right place for this
    base = '/opt/pdp/services/staging/processing'
    path = File.join(
      base,
      self.name,
      'sips'
    )
    Dir.glob("#{path}/*").each do |sip_path|
      Package.create(
        batch_id: self.id,
        sip_path: sip_path,
        oral_history: self.oral_history,
        dark_archive: self.dark_archive,
        approved: false
      )
    end
  end
end
