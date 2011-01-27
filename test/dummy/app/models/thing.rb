class Thing < ActiveRecord::Base
  scope :sort_key, lambda { |criteria| order("key #{criteria[:order]}") }
  scope :sort_name, lambda { |criteria| {} }
  scope :sort_some_boolean, lambda { |criteria| order("some_boolean #{criteria[:order]}") }
  scope :search_key, lambda { |value| where( :key => value ) }
  scope :search_name, lambda { |value| where(["upper(things.name) like ?", "%#{value.upcase}%"]) }
end
