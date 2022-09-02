defmodule DockerTest.Repo do
  use Ecto.Repo,
    otp_app: :docker_test,
    adapter: Ecto.Adapters.Postgres
end
