module ZableHelper

  def self.included(base)
    base.send :include, Zable::Html
  end

  def zable(collection, klass, args={}, &block)
    stylesheet_link_tag("zable") << (args[:paginate] ?
      (pagination_element << zable_element(args, block, collection, klass) << pagination_element ) :
      zable_element(args, block, collection, klass))
  end

  def zable_element(args, block, collection, klass)
    cols = columns(&block)
    cols.instance_variable_set :@search_params, controller.request.params[:search]
    content_tag(:table, tag_args(args)) do
      table_header(klass, cols) << table_body(collection, cols)
    end
  end

  def pagination_element
    content_tag :div, :class => 'brownFilterResultsBox' do
      page_entries_info(@relationships) << will_paginate(@relationships)
    end
  end

  def columns
    controller.request.instance_variable_set :@zable_columns, []
    yield
  end

  def sorted_column?(name)
    params[:sort][:attr] == name.to_s rescue false
  end

  def current_sort_order
    params[:sort][:order].downcase.to_sym rescue :asc
  end

  def link_sort_order(name)
    return nil unless sorted_column?(name)
    current_sort_order == :desc ? :asc : :desc
  end

  def column(name, options={}, &block)
    col = {
        :name       => name,
        :title      => options[:title],
        :sort       => options.has_key?(:sort) ? options[:sort] : true,
        :block      => block,
        :sorted?    => sorted_column?(name),
        :sort_order => link_sort_order(name)
    }

    zable_columns = controller.request.instance_variable_get :@zable_columns
    zable_columns << col
  end

end
