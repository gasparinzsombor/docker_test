defmodule DockerTestWeb.PageController do
  use DockerTestWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
