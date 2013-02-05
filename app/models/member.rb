class Member < ActiveRecord::Base
  attr_accessible :created_at, :idm, :name
  validates_uniqueness_of :idm
end
