defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  # BADGE
  attr(:label, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def badge(assigns) do
    ~H"""
    <span
      {@rest}
      class={"inline-flex items-center gap-0.5 rounded-full
            bg-gray-300 px-3 py-0.5 text-sm font-medium
            text-gray-800 hover:cursor-pointer #{@class}"}>
      <%= @label %>
      <Heroicons.x_mark class="h-3 w-3 text-gray-600" />
    </span>
    """
  end

  # LOADING INDICATOR
  attr(:loading, :boolean, required: true)

  def loader(assigns) do
    ~H"""
    <div :if={@loading} class="loader"></div>
    """
  end

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @server.name %></h2>
        <button phx-click="toggle-status" phx-value-id={@server.id} class={@server.status}>
          <%= @server.status %>
        </button>
      </div>
      <div class="body">
        <div class="row">
          <span>
            <%= @server.deploy_count %> deploys
          </span>
          <span>
            <%= @server.size %> MB
          </span>
          <span>
            <%= @server.framework %>
          </span>
        </div>
        <h3>Last Commit Message:</h3>
        <blockquote>
          <%= @server.last_commit_message %>
        </blockquote>
      </div>
    </div>
    """
  end
end
