# frozen_string_literal: true

class Views::Web::Help::Api3 < Views::Web::BasicLayout
  def initialize(root_url:, **layout_args)
    super(**layout_args)
    @root_url = root_url
  end

  def view_template
    main(class: "container") do
      h1 { plain "Loomio API docs /api/b3" }
      p { plain "/api/b3 namespace is for server level opertations. You must set an ENV['B3_API_KEY'] and pass a b3_api_key param to authenticate. B3_API_KEY must be longer than 16 chars" }
      p { plain "Please user the /api/b2 namespace for all group level operations" }

      h2 { plain "deactivate user" }
      h3 { plain "example" }
      pre { plain "curl -X POST -H 'Content-Type: application/json' -d '{\"b3_api_key\": secret_not_shown, \"id\": 123}'}' #{@root_url}api/b3/users/deactivate" }
      h3 { plain "params" }
      table do
        tr { td { plain "b3_api_key" }; td { plain "The value you specified in ENV['B3_API_KEY']" } }
        tr { td { plain "id" }; td { plain "the user id you want to deactivate" } }
      end

      h2 { plain "reactivate user" }
      h3 { plain "example" }
      pre { plain "curl -X POST -H 'Content-Type: application/json' -d '{\"b3_api_key\": secret_not_shown, \"id\": 123}'}' #{@root_url}api/b3/users/reactivate" }
      h3 { plain "params" }
      table do
        tr { td { plain "b3_api_key" }; td { plain "The value you specified in ENV['B3_API_KEY']" } }
        tr { td { plain "id" }; td { plain "the user id you want to reactivate" } }
      end
    end
  end
end
