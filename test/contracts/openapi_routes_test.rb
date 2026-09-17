require "test_helper"
require "yaml"

class OpenapiRoutesTest < ActiveSupport::TestCase
  SPEC_PATH = Rails.root.join("docs/user_manual/integrations/api/openapi.yaml")
  HTTP_METHODS = %w[get post put patch delete options head trace].freeze

  test "OpenAPI contract covers every B2 and B3 route" do
    assert_equal rails_operations, documented_operations
  end

  test "OpenAPI contract is internally consistent" do
    assert_equal "3.1.0", spec.fetch("openapi")

    references(spec).each do |reference|
      assert reference.start_with?("#/"), "external reference is not supported by this contract test: #{reference}"
      assert reference.delete_prefix("#/").split("/").reduce(spec) { |value, key| value.fetch(key) }
    end

    spec.fetch("paths").each do |path, path_item|
      declared_parameters = Array(path_item["parameters"])
      path_item.each do |method, operation|
        next unless HTTP_METHODS.include?(method)

        parameters = declared_parameters + Array(operation["parameters"])
        parameter_names = parameters.filter_map do |parameter|
          parameter = resolve_reference(parameter.fetch("$ref")) if parameter.key?("$ref")
          parameter["name"] if parameter["in"] == "path"
        end
        assert_equal path.scan(/\{([^}]+)\}/).flatten.sort, parameter_names.sort, "#{method.upcase} #{path} path parameters differ"
      end
    end
  end

  test "OpenAPI operations have unique IDs, summaries, and responses" do
    operations = spec.fetch("paths").flat_map do |path, path_item|
      path_item.filter_map do |method, operation|
        [path, method, operation] if HTTP_METHODS.include?(method)
      end
    end

    operation_ids = operations.map { |_path, _method, operation| operation.fetch("operationId") }
    assert_equal operation_ids.uniq, operation_ids

    operations.each do |path, method, operation|
      assert operation["summary"].present?, "#{method.upcase} #{path} has no summary"
      assert operation["responses"].present?, "#{method.upcase} #{path} has no responses"
    end
  end

  private

  def spec
    @spec ||= YAML.safe_load_file(SPEC_PATH)
  end

  def documented_operations
    spec.fetch("paths").flat_map do |path, path_item|
      path_item.keys.filter_map do |method|
        "#{method.upcase} #{path}" if HTTP_METHODS.include?(method)
      end
    end.sort
  end

  def rails_operations
    Rails.application.routes.routes.filter_map do |route|
      controller = route.defaults[:controller].to_s
      next unless controller.start_with?("api/b2/", "api/b3/")

      path = route.path.spec.to_s.delete_suffix("(.:format)").gsub(/:([a-z_]+)/, '{\\1}')
      route.verb.to_s.split("|").map { |verb| "#{verb} #{path}" }
    end.flatten.sort
  end

  def references(value)
    case value
    when Hash
      value.flat_map { |key, child| key == "$ref" ? [child] : references(child) }
    when Array
      value.flat_map { |child| references(child) }
    else
      []
    end
  end

  def resolve_reference(reference)
    reference.delete_prefix("#/").split("/").reduce(spec) { |value, key| value.fetch(key) }
  end
end
