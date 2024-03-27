defmodule LiveViewStudioWeb.BoatsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats

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

      <.promo hours_expiration={2}>
        Save 25% on rentals

        <:legal>
          <Heroicons.exclamation_circle />
          Limit 1 per party
        </:legal>
      </.promo>

      <div class="boats">
        <div :for={boat <- @boats} class="boat">
          <img src={boat.image} />
          <div class="content">
            <div class="model">
              <%= boat.model %>
            </div>
            <div class="details">
              <span class="price">
                <%= boat.price %>
              </span>
              <span class="type">
                <%= boat.type %>
              </span>
            </div>
          </div>
        </div>
      </div>

      <.promo>
        Hurry, only 3 boats left!

        <:legal>
          Excluding weekends
        </:legal>
      </.promo>
    </div>
    """
  end

  # types (requirements)
  attr(:hours_expiration, :integer, default: 24)
  slot(:legal)
  slot(:inner_block, required: true)

  # function components
  def promo(assigns) do
    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>

      <div class="expiration">
        DEAL EXPIRES IN <%= @hours_expiration %> HOURS
      </div>

      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
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
