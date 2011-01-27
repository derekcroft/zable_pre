require 'test_helper'

class ZableTest < ActionView::TestCase

  ## Test helpers for this gem
  def assert_html_table(collection)
    assert_match /<table.*>.*<\/table>/, zable(collection, Item, &@COLUMN_PROC)
  end

  ## test that the plugin is loaded properly
  test "modules exist in the current scope" do
    assert_kind_of Module, Zable
    assert_kind_of Module, Zable::Html
    assert_kind_of Module, Zable::Sort
    assert_kind_of Module, Zable::Sort::ActiveRecord
    assert_kind_of Module, Zable::ActiveRecord
    assert_kind_of Module, Zable::ActiveRecord::ClassMethods::Helpers
    assert_kind_of Module, ZableHelper
  end

  ## test overall functionality of plugin
  test "helper method can be called with an empty collection" do
    collection = []
    assert_nothing_raised { zable collection, Item, &@COLUMN_PROC }
  end

  test "empty_table_body_row called when collection is empty" do
    collection = []
    ZableTest.any_instance.expects(:empty_table_body_row)
    zable collection, Item, &@COLUMN_PROC
  end

  test "empty table body row creates a tr with a td" do
    columns = []
    @rendered = empty_table_body_row(columns)
    assert_select "#zable-empty-set"
  end

  test "empty table body row creates a td with messages" do
    columns = []
    @rendered = empty_table_body_row(columns)
    assert_select 'td', "No items found.".html_safe
  end

  # plugin adds "populate" method to models
  test "populate method" do
    assert_respond_to Item, :populate
  end

  test "populate method passes page value and size to paginate method" do
    Item.expects(:paginate).with(has_entries(:page => 2, :per_page => 3))
    Item.populate :page => {:num => 2, :size => 3}
  end

  # given a block, helper populates columns array
  test "columns populate from block" do
    col = columns do
      column :col_1
      column :col_2
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
  end

  test "column stores block value passed to it" do
    col = columns do |c|
      column :col_1 do |i|
        i.string_column.upcase + " - extra stuff"
      end
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
    assert_kind_of Proc, column[:block]
  end

  test "column stores title passed to it" do
    col = columns do |c|
      column :col_1, :title => "Col 1 Title"
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
    assert_equal "Col 1 Title", column[:title]
  end

  test "column stores sort value passed to it" do
    col = columns do |c|
      column :col_1, :sort => false
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
    assert_equal false, column[:sort]
  end

  test "sort value for column defaults to true" do
    col = columns do |c|
      column :col_1
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
    assert_equal true, column[:sort]
  end

  # helper called with a non-empty collection
  test "main helper method returns an html table" do
    collection = 2.times.collect { Factory :item }
    assert_html_table collection
  end

  # helper called with table classes
  test "html table can have additional classes" do
    collection    = 2.times.collect { Factory :item }
    table_classes = ["wmg-result-list", "hrca-table"]
    html          = zable collection, Item, :table_class => table_classes, &@COLUMN_PROC
    table_classes.each do |tc|
      assert_match /<table.+class=['"].*#{tc}.*['"]>.*<\/table>/, html
    end
  end

  ## test functionality of individual methods
  test "helper method returns html table" do
    collection = []
    assert_html_table collection
  end

  test "list all non-Rails attributes on a model" do
    assert_respond_to Item, :attribute_columns_only
    assert_equal ["integer_column", "string_column",
                  "integer_column_2", "string_column_2",
                  "integer_column_3", "string_column_3",
                  "something_happened_on", "date_column"].sort,
                 Item.attribute_columns_only.sort
  end

  test "sort order of non-sorted column is nil" do
    self.expects(:sorted_column?).returns(false)
    assert_nil link_sort_order(:col_1)
  end

  test "link sort order is :desc if current sort order is :asc" do
    self.expects(:sorted_column?).with(:col_1).returns(true)
    self.expects(:current_sort_order).returns(:desc)
    assert_equal :asc, link_sort_order(:col_1)
  end

  test "link sort order is :asc if current sort order is :desc" do
    self.expects(:sorted_column?).with(:col_1).returns(true)
    self.expects(:current_sort_order).returns(:asc)
    assert_equal :desc, link_sort_order(:col_1)
  end

end
