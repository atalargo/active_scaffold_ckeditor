ActiveScaffold.bridge "CKEditor" do
    require File.join(File.dirname(__FILE__), "/lib/ckeditor_bridge.rb")
   install do
    require File.join(File.dirname(__FILE__), "/lib/ckeditor_bridge.rb")
#     ActiveScaffold::Config::Core.send :include, ActiveScaffold::CKEditorBridge
   end
end
