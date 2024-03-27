defmodule LiveViewStudioWeb.BoatsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats
  alias LiveViewStudioWeb.CustomComponents
  # import LiveViewStudioWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filter: %{type: "", prices: []},
        boats: Boats.list_boats()
      )

    # after mount, reset the boats to save memory
    {:ok, socket, temporary_assigns: [boats: []]}
    # {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Daily Boat Rentals</h1>
    <div id="boats">
      <.filter_form filter={@filter} />

      <CustomComponents.promo hours_expiration={2}>
        Save 25% on rentals

        <:legal>
          <Heroicons.exclamation_circle />
          Limit 1 per party
        </:legal>
      </CustomComponents.promo>

      <div class="boats">
        <.boat_card :for={boat <- @boats} boat={boat} />
      </div>

      <CustomComponents.promo>
        Hurry, only 3 boats left!

        <:legal>
          Excluding weekends
        </:legal>
      </CustomComponents.promo>
    </div>
    """
  end

  # BOATS function components
  attr(:boat, LiveViewStudio.Boats.Boat, required: true)

  def boat_card(assigns) do
    ~H"""
    <div class="boat">
      <img src={@boat.image} />
      <div class="content">
        <div class="model">
          <%= @boat.model %>
        </div>
        <div class="details">
          <span class="price">
            <%= @boat.price %>
          </span>
          <span class="type">
            <%= @boat.type %>
          </span>
        </div>
      </div>
    </div>
    """
  end

  attr(:filter, :map, required: true)

  def filter_form(assigns) do
    ~H"""
    <form phx-change="filter">
      <div class="filters">
        <select name="type">
          <%= Phoenix.HTML.Form.options_for_select(
            type_options(),
            @filter.type
          ) %>
        </select>
        <div class="prices">
          <%= for price <- ["$", "$$", "$$$"] do %>
            <input
              type="checkbox"
              name="prices[]"
              value={price}
              id={price}
              checked={price in @filter.prices}
            />
            <label for={price}><%= price %></label>
          <% end %>
          <input type="hidden" name="prices[]" value="" />
        </div>
      </div>
    </form>
    """
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    filter = %{type: type, prices: prices}
    boats = Boats.list_boats(filter)

    # boats assigned to the socket. with temporary_assigns, is 0
    IO.inspect(length(socket.assigns.boats), label: "Assigned boats")
    IO.inspect(length(boats), label: "Filtered boats")

    {:noreply, assign(socket, boats: boats, filter: filter)}
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end
end
