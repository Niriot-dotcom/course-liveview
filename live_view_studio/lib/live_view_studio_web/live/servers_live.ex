defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server
  alias LiveViewStudioWeb.CustomComponents

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    changeset = Servers.change_server(%Server{})

    socket =
      assign(socket,
        servers: servers,
        coffees: 0,
        form: to_form(changeset)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">
            + Add New Server
          </.link>
          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <.form for={@form} phx-submit="save">
              <.label for="name">Name</.label>
              <.input field={@form[:name]} autocomplete="off"/>
              <.label for="framework">Framework</.label>
              <.input field={@form[:framework]} autocomplete="off"/>
              <.label for="size">Size (MB)</.label>
              <.input field={@form[:size]} type="number" autocomplete="off"/>

              <.button phx-disable-with="Saving...">
                Save
              </.button>
              <.link patch={~p"/servers"} class="cancel">
                Cancel
              </.link>
            </.form>
          <% else %>
            <CustomComponents.server server={@selected_server} />
          <% end %>

          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust lights
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)

    {:noreply,
     assign(socket,
       selected_server: server,
       page_title: "Here #{server.name}"
     )}
  end

  def handle_params(_, _uri, socket) do
    # {:noreply,
    #  assign(socket,
    #    selected_server: hd(socket.assigns.servers)
    #  )}
    socket =
      if socket.assigns.live_action == :new do
        changeset = Servers.change_server(%Server{})

        assign(socket,
          selected_server: nil,
          form: to_form(changeset)
        )
      else
        assign(socket,
          selected_server: hd(socket.assigns.servers)
        )
      end

    {:noreply, socket}
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, new_server} ->
        socket =
          update(
            socket,
            :servers,
            fn servers -> [new_server | servers] end
          )

        changeset = Servers.change_server(%Server{})

        socket = put_flash(socket, :info, "New server saved successfully!")
        # socket = push_patch(socket, to: ~p"/servers/#{length(socket.assigns.servers)}")
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, changeset} ->
        socket = put_flash(socket, :error, "Please check the provided information")
        IO.inspect(changeset, label: "changeset")
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
