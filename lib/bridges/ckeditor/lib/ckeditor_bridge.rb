#coding: utf-8

module ActiveScaffold
  module CKEditorBridge
    def self.included(base)
      base.class_eval do
        include FormColumnHelpers
        include SearchColumnHelpers
        include ViewHelpers
      end
    end

    module ViewHelpers
      def self.included(base)
        base.alias_method_chain :active_scaffold_includes, :ckeditor
      end

      def active_scaffold_includes_with_ckeditor(*args)
	ckeditor_js = javascript_tag(%|
var action_link_close = ActiveScaffold.ActionLink.Abstract.prototype.close;
ActiveScaffold.ActionLink.Abstract.prototype.close = function() {
  this.adapter.select('textarea.CKEditor').each(function(elem) {
   if (CKEDITOR.instances[elem.id]) {CKEDITOR.instances[elem.id].destroy(false);}
  });
  action_link_close.apply(this);
};
	|) #if using_ckeditor?
        active_scaffold_includes_without_ckeditor(*args)  + (ckeditor_js || '') #+ (include_ckeditor_if_needed || '')
      end
    end

    module FormColumnHelpers
      def self.included(base)
        base.alias_method_chain :onsubmit, :ckeditor
      end

      def active_scaffold_input_ckeditor(column, options)
	options[:width] ||= (column.options[:width] ||= "600px")
	options[:height] ||= (column.options[:height] ||= "200px")
	options[:language] ||= (column.options[:language] ||= I18n.locale.to_s)
	options[:class] = "#{options[:class]} CKEditor #{column.options[:class]}".strip
	options[:resize_enabled] ||= (column.options[:resize_enabled] ||= true)
	options[:ajax] ||= (column.options[:ajax] ||= true)
	ckeditor_textarea( :record, column.name, :id => options[:id], :name => options[:name], :width => options[:width], :height => options[:height], :language => options[:language], :class => options[:class], :resize_enabled => options[:resize_enabled], :ajax => options[:ajax])
      end

      def onsubmit_with_ckeditor
        submit_js = 'this.select("textarea.CKEditor").each(function(elem) {var oEditor = CKEDITOR.instances[elem.id]; document.getElementById(elem.id+"_hidden").value = oEditor.getData();CKEDITOR.instances[elem.id].destroy(false);});' #if using_ckeditor?
        [onsubmit_without_ckeditor, submit_js].compact.join ';'
      end
    end

    module SearchColumnHelpers
      def self.included(base)
        base.class_eval { alias_method :active_scaffold_search_ckeditor, :active_scaffold_search_text }
      end
    end
  end
end

ActionView::Base.class_eval {include ActiveScaffold::CKEditorBridge }
