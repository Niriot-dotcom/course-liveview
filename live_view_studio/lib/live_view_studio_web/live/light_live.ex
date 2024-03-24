defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  # utils functions
  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        brightness: 10,
        temp: "3000"
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Focus Light Render</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background-color: #{temp_color(@temp)}"}><%= assigns.brightness %>%</span>
      </div>

      <%!-- actions --%>
      <button phx-click="off">
        <img src="/images/light-off.svg" />
      </button>

      <button phx-click="down">
        <img src="/images/down.svg" />
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" />
      </button>

      <button phx-click="on">
        <img src="/images/light-on.svg" />
      </button>


      <button phx-click="fire">
        <img src="/images/fire.svg" />
      </button>

      <%!-- slider --%>
      <form phx-change="slide">
        <input type="range" min="0" max="100" name="brightness" value={@brightness} phx-debounce="250" />
      </form>

      <%!-- temperature --%>
      <form phx-change="update-temp">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input type="radio" id={temp} name="temp" value={temp} checked={temp === @temp} />
              <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>
    </div>
    """
  end

  # handles
  def handle_event("off", _, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(0, &1 - 10))
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(100, &1 + 10))
    {:noreply, socket}
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("fire", _, socket) do
    socket = assign(socket, brightness: Enum.random(0..100))
    {:noreply, socket}
  end

  def handle_event("slide", params, socket) do
    %{"brightness" => b} = params
    # i didn't need to convert, why? ==> String.to_integer(brightness))
    socket = assign(socket, brightness: b)
    {:noreply, socket}
  end

  def handle_event("update-temp", params, socket) do
    %{"temp" => t} = params
    {:noreply, assign(socket, temp: t)}
  end
end
