defmodule LiveViewStudioWeb.PromoComponents do
  use Phoenix.Component

  # embed templates
  # embed_templates("icons/*")

  # PROMO
  attr(:hours_expiration, :integer, default: 24)
  attr(:minutes_expiration, :integer)
  slot(:legal)
  slot(:inner_block, required: true)

  def promo(assigns) do
    # assigns = assign(assigns, :minutes_expiration, assigns.hours_expiration * 60)
    assigns = assign_new(assigns, :minutes_expiration, fn -> assigns.hours_expiration * 60 end)

    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>

      <div class="expiration">
        DEAL EXPIRES IN <%= @hours_expiration %> HOURS
        <p>(<%= @minutes_expiration %> minutes)</p>
      </div>

      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end
end
