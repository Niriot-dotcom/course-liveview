defmodule Servy.BearController do
  import Servy.View, only: [render: 3]

  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.BearView

  # defp bear_item(bear) do
  #   "\t<li>#{bear.name} - #{bear.type}</li>\n"
  # end

  def index(conv) do
    # items =
    #   Wildthings.list_bears()
    #   |> Enum.filter(&Bear.is_grizzly/1)
    #   |> Enum.sort(&Bear.order_asc_by_name/2)
    #   |> Enum.map(&bear_item/1)
    #   # |> Enum.filter(fn(b) -> Bear.is_grizzly(b) end)
    #   # |> Enum.sort(fn(b1, b2) -> Bear.order_asc_by_name(b1, b2) end)
    #   # |> Enum.map(fn(b) -> bear_item(b) end)
    #   |> Enum.join
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    # render(conv, "index.eex", bears: bears)
    %{ conv | status: 200, resp_body: BearView.index(bears) }
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    # render(conv, "show.eex", bear: bear)
    %{ conv | status: 200, resp_body: BearView.show(bear) }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv| status: 201,
        resp_body: "Create a bear named #{name} of type #{type}."
    }
  end

  def remove(conv, %{"id" => id}) do
    %{conv | status: 200, resp_body: "Bear #{id} has been deleted."}
  end
end
