defmodule LiveViewStudioWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :live_view_studio,
    pubsub_server: LiveViewStudio.PubSub

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, topic)
  end

  def track_user(current_user, topic, meta) do
    {:ok, _} =
      track(self(), topic, current_user.id, meta)
  end

  defp simple_presence_map(presences) do
    Enum.into(presences, %{}, fn {user_id, %{metas: [meta | _]}} -> {user_id, meta} end)
  end

  def list_users(topic) do
    topic |> list() |> simple_presence_map()
  end

  def update_user(user, topic, new_meta) do
    %{metas: [meta | _]} = get_by_key(topic, user.id)
    update(self(), topic, user.id, Map.merge(meta, new_meta))
  end

  def handle_diff(socket, diff) do
    socket
    |> remove_presences(diff.leaves)
    |> add_presences(diff.joins)
  end

  defp remove_presences(socket, leaves) do
    users_ids = Enum.map(leaves, fn {user_id, _meta} -> user_id end)
    presences = Map.drop(socket.assigns.presences, users_ids)
    Phoenix.Component.assign(socket, :presences, presences)
  end

  defp add_presences(socket, joins) do
    presences = Map.merge(socket.assigns.presences, simple_presence_map(joins))
    Phoenix.Component.assign(socket, :presences, presences)
  end
end
