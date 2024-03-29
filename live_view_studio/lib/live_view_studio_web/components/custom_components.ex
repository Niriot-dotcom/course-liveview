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
end
