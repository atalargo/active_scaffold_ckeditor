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
  this.adapter.select('textarea').each(function(elem) {
   if (/_editor$/.test(elem.id)) {if (CKEDITOR.instances[elem.id]) {CKEDITOR.instances[elem.id].destroy(false);}}
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
	ckeditor_textarea( :record, column.name, :width => "600px", :height => "200px", :language => I18n.locale.to_s, :class => 'CKEditor', :resize_enabled => true, :ajax => true)
#         options[:class] = "#{options[:class]} mceEditor #{column.options[:class]}".strip
#         html = []
#         html << send(override_input(:textarea), column, options)
#         html << javascript_tag("tinyMCE.execCommand('mceAddControl', false, '#{options[:id]}');") if request.xhr? || params[:iframe]
#         html.join "\n"
      end

      def onsubmit_with_ckeditor
        submit_js = 'this.select("textarea").each(function(elem) {if (/_editor$/.test(elem.id)) {var oEditor = CKEDITOR.instances[elem.id]; document.getElementById(elem.id+"_hidden").value = oEditor.getData();CKEDITOR.instances[elem.id].destroy(false);}});' #if using_ckeditor?
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
