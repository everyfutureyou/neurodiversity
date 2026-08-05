# Lightweight method-replacement stub compatible with Minitest 6.
#
# Usage:
#   with_stub(MyClass, :class_method, return_value) { ... }
#   with_stub(object_instance, :instance_method, return_value) { ... }
module StubHelper
  def with_stub(target, method_name, return_value, &block)
    original = target.method(method_name)
    target.define_singleton_method(method_name) { |*_args, **_kwargs| return_value }
    block.call
  ensure
    target.define_singleton_method(method_name, original)
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include StubHelper
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include StubHelper
end
