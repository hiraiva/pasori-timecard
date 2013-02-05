class MemberTime < ActiveRecord::Base
  attr_accessible :created_at, :member_id, :kind
end
