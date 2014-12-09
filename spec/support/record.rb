

class Record < ActiveRecord::Base
  acts_as_dead_record
  has_many :non_dead_records, dependent: :destroy
  has_many :elements, dependent: :destroy
end

class MicroElement < ActiveRecord::Base
  belongs_to :element
  acts_as_dead_record
end

class Element < ActiveRecord::Base
  belongs_to :record
  belongs_to :has_one_element
  has_many :micro_elements, dependent: :destroy
  acts_as_dead_record
end

class HasOneElementRecord < ActiveRecord::Base
  self.table_name = "records"

  acts_as_dead_record
  has_one :element, dependent: :destroy
end


class NonDeadRecord < ActiveRecord::Base

end