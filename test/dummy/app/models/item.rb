class Item < ActiveRecord::Base

  searchable :string_column, :integer_column, :something_happened_on
  sortable :string_column

  def some_method
    "value"
  end
end