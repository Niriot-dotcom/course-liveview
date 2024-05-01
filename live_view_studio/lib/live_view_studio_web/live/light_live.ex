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
