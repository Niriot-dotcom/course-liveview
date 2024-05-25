defmodule LiveViewStudioWeb.PresenceLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.Presence

  @topic "users:video"

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Presence.subscribe(@topic)

      Presence.track_user(current_user, @topic, %{
        username: current_user.email |> String.split("@") |> hd(),
        is_playing: false
      })
    end

    socket =
      socket
      |> assign(:is_playing, false)
      |> assign(:presences, Presence.list_users(@topic))

    {:ok, socket}
  end

  # defp simple_presence_map(presences) do
  #   Enum.into(presences, %{}, fn {user_id, %{metas: [meta | _]}} -> {user_id, meta} end)
  # end

  def render(assigns) do
    ~H"""
    <div id="presence">
      <div class="users">
        <h2>
          Who's Here?
          <button phx-click={toggle_show_presences()}>
            <.icon name="hero-list-bullet-solid" />
          </button>
        </h2>

        <ul id="presences">
          <li :for={{_user_id, meta}<- @presences}>
            <span class="status">
              <%= if meta.is_playing, do: "👀", else: "🙈" %>
            </span>
            <span class="username">
              <%= meta.username %>
            </span>
          </li>
        </ul>
      </div>
      <div class="video" phx-click="toggle-playing">
        <%= if @is_playing do %>
          <.icon name="hero-pause-circle-solid" />
        <% else %>
          <.icon name="hero-play-circle-solid" />
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("toggle-playing", _, socket) do
    socket = update(socket, :is_playing, fn playing -> !playing end)

    # update is_playing emoji on meta info
    # %{current_user: current_user} = socket.assigns
    # %{metas: [meta | _]} = Presence.get_by_key(@topic, current_user.id)
    # new_meta = %{meta | is_playing: socket.assigns.is_playing}
    # Presence.update(self(), @topic, current_user.id, new_meta)
    %{current_user: current_user} = socket.assigns

    Presence.update_user(current_user, @topic, %{
      is_playing: socket.assigns.is_playing
    })

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end

  defp toggle_show_presences(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#presences")
    |> JS.remove_class(
      "bg-slate-400",
      to: ".hero-list-bullet-solid.bg-slate-400"
    )
    |> JS.add_class(
      "bg-slate-400",
      to: ".hero-list-bullet-solid:not(.bg-slate-400)"
    )
  end
end
