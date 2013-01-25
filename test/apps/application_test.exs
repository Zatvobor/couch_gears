Code.require_file "../../test_helper.exs", __FILE__

defmodule ApplicationTest do
  use ExUnit.Case, async: true


  test "returns a default environment" do
    defmodule App1 do
      use CouchGears.App

      config :dynamo, env: "dev", endpoint: Endpoint
    end

    assert App1.config[:dynamo][:env] == "dev"
  end

  test "applies an environment's config" do
    defmodule App2 do
      use CouchGears.App

      config :dynamo, env: CouchGears.env, endpoint: Endpoint

      environment "dev" do
        config :dynamo, compile_on_demand: true, reload_modules: true
      end
    end

    assert App2.config[:dynamo][:compile_on_demand] == true
    assert App2.config[:dynamo][:reload_modules]    == true
  end


  test "uses environment as a regexp" do
    defmodule App3 do
      use CouchGears.App

      config :dynamo, env: CouchGears.env, endpoint: Endpoint

      environment %r(prod|dev) do
        config :dynamo, compile_on_demand: false, reload_modules: false
      end
    end
    assert App3.config[:dynamo][:compile_on_demand] == false
    assert App3.config[:dynamo][:reload_modules]    == false
  end

end