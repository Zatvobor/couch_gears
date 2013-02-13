defmodule CouchGears.Mixfile do
  use Mix.Project

  def project do
    [ app: :couch_gears,
      version: "0.6.dev",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:dynamo]]
  end

  # Returns the list of dependencies in the format:
  defp deps do
    [{:dynamo, "0.1.0.dev", github: "josevalim/dynamo"},
    {:mochiweb, "2.4.2", [git: "https://github.com/mochi/mochiweb.git", tag: "v2.4.2"]}
    ]
  end
end
