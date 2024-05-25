defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  # alias LiveViewStudio.Volunteers.Volunteer
  alias LiveViewStudioWeb.VolunteerFormComponent
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end

    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component module={VolunteerFormComponent} id={:new} count={@count} />
      <%!-- <pre>
        <%= inspect(@form, pretty: true) %>
      </pre> --%>

      <div id="volunteers" phx-update="stream">
        <.volunteer :for={{volunteer_id, volunteer} <- @streams.volunteers} id={volunteer_id} volunteer={volunteer} />
      </div>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} =
      Volunteers.delete_volunteer(volunteer)

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} =
      Volunteers.toggle_status_volunteer(volunteer)

    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket = update(socket, :count, &(&1 + 1))
    {:noreply, stream_insert(socket, :volunteers, volunteer, at: 0)}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end

  def handle_info({:volunteer_deleted, volunteer}, socket) do
    socket = update(socket, :count, &(&1 - 1))
    {:noreply, stream_delete(socket, :volunteers, volunteer)}
  end

  def volunteer(assigns) do
    ~H"""
    <div
        class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
        id={@id}
      >
        <div class="name">
          <%= @volunteer.name %>
        </div>
        <div class="phone">
          <%= @volunteer.phone %>
        </div>
        <div class="status">
          <button phx-click={toggle_status(@volunteer.id)}>
            <%= if @volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
          <.link class="delete" phx-click={delete_volunteer(@volunteer.id)} data-confirm="Are you sure you want to delete it?">
            <.icon name="hero-trash-solid" />
          </.link>
        </div>
      </div>
    """
  end

  defp delete_volunteer(volunteer_id) do
    JS.push("delete", value: %{id: volunteer_id})
    |> JS.hide(
      transition: "ease duration-1000 scale-150",
      to: "#volunteers-#{volunteer_id}",
      time: 500
    )
  end

  defp toggle_status(volunteer_id) do
    JS.push("toggle-status", value: %{id: volunteer_id})
    |> JS.transition("shake", to: "#volunteers-#{volunteer_id}", time: 500)
  end
end
