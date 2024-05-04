defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:form, to_form(changeset))

    # IO.inspect(socket.assigns.streams.volunteers, label: "mount")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="save" phx-change="validate">
        <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000" />
        <.input field={@form[:phone]} type="tel" placeholder="Phone" autocomplete="off" phx-debounce="blur" />

        <.button phx-disable-with="Saving...">
          Check In
        </.button>
      </.form>
      <%!-- <pre>
        <%= inspect(@form, pretty: true) %>
      </pre> --%>

      <div id="volunteers" phx-update="stream">
      <div
        :for={{volunteer_id, volunteer} <- @streams.volunteers}
        class={"volunteer #{if volunteer.checked_out, do: "out"}"}
        id={volunteer_id}
      >
        <div class="name">
          <%= volunteer.name %>
        </div>
        <div class="phone">
          <%= volunteer.phone %>
        </div>
        <div class="status">
          <button phx-click="toggle-status" phx-value-id={volunteer.id}>
            <%= if volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
          <.link class="delete" phx-click="delete" phx-value-id={volunteer.id} data-confirm="Are you sure you want to delete it?">
            <.icon name="hero-trash-solid" />
          </.link>
        </div>
      </div>
      </div>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, volunteer} =
      Volunteers.delete_volunteer(volunteer)

    socket = stream_delete(socket, :volunteers, volunteer)
    IO.inspect(socket.assigns.streams.volunteers, label: "delete")
    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, volunteer} =
      Volunteers.toggle_status_volunteer(volunteer)

    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)

    # IO.inspect(socket.assigns.streams.volunteers, label: "validate (after render volunteers)")
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    # # IO.inspect(volunteer_params, label: "Volunteer params")
    # # IO.inspect(result, label: "result Volunteer")
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        socket = stream_insert(socket, :volunteers, volunteer, at: 0)

        changeset = Volunteers.change_volunteer(%Volunteer{})

        socket = put_flash(socket, :info, "New volunteer saved successfully!")
        # IO.inspect(socket.assigns.streams.volunteers, label: "save (after stream_insert)")
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, changeset} ->
        socket = put_flash(socket, :error, "Please check the provided information")
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
