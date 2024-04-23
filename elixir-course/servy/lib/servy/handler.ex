defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."

  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  alias Servy.Conv

  @pages_path Path.expand("../../pages/", __DIR__)
  # @pages_path Path.expand("pages", File.cwd!)

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> emojify
    |> track
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Todd, Snow, Firulais"}
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    file =
      @pages_path
      |> Path.join("form.html")

    # |> File.read()
    # |> handle_file(conv)

    case File.read(file) do
      {:ok, content} ->
        %{conv | status: 200, resp_body: content}

      {:error, :enoent} ->
        %{conv | status: 404, resp_body: "File not found."}

      {:error, reason} ->
        %{conv | status: 500, resp_body: "File error: #{reason}"}
    end
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id} has been deleted."}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> html_file} = conv) do
    @pages_path
    |> Path.join("#{html_file}.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{} = conv) do
    %{conv | status: 404, resp_body: "No #{conv.method} #{conv.path} here!"}
  end

  def emojify(%Conv{status: 200, resp_body: resp_body} = conv) do
    %{conv | resp_body: "🎉\n" <> resp_body <> "\n🎉"}
  end

  def emojify(%Conv{} = conv), do: conv

  def format_response(conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bears/123 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
DELETE /bears/2 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bears?id=3 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()

request = """
GET /pages/contact HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request |> Servy.Handler.handle() |> IO.puts()
