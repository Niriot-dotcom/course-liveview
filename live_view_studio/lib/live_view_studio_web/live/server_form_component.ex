defmodule LiveViewStudioWeb.ServerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(socket) do
    changeset = Servers.change_server(%Server{})

    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-submit="save" phx-change="validate" phx-target={@myself}>
        <.label for="name">Name</.label>
        <.input field={@form[:name]} autocomplete="off" phx-debounce="2000"/>
        <.label for="framework">Framework</.label>
        <.input field={@form[:framework]} autocomplete="off" phx-debounce="2000"/>
        <.label for="size">Size (MB)</.label>
        <.input field={@form[:size]} type="number" autocomplete="off" phx-debounce="blur"/>

        <.button phx-disable-with="Saving...">
          Save
        </.button>
        <.link patch={~p"/servers"} class="cancel">
          Cancel
        </.link>
      </.form>
    </div>
    """
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, new_server} ->
        send(self(), {:server_created, new_server})

        changeset = Servers.change_server(%Server{})

        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, changeset} ->
        socket = put_flash(socket, :error, "Please check the provided information")
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
