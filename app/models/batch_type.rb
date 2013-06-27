class BatchType < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail
end
