defmodule NtucPriceIsRightWeb.HomeLive do
  use NtucPriceIsRightWeb, :live_view
  alias NtucPriceIsRight.Products
  alias NtucPriceIsRight.PriceInput

  def mount(_params, _session, socket) do
    product = if connected?(socket), do: Products.get_random_product(), else: nil
    price_input = to_form(PriceInput.changeset(%PriceInput{}, %{}))

    {:ok,
     socket
     |> assign(:is_correct_guess, false)
     |> assign(:number_of_correct, 0)
     |> assign(:product, product)
     |> assign(:price_input, price_input)}
  end

  def render(assigns) do
    ~H"""
    <div :if={@product} class="flex p-2 flex-col items-center border">
      <img src={@product.image} alt={@product.title} />
      <div class="flex flex-col gap-2">
        <p class="font-bold text-3xl">${:erlang.float_to_binary(@product.price, decimals: 2)}</p>
        
        <p class="text-2xl">{@product.title}</p>
        
        <p class="text-xl font-medium text-gray-500">{@product.quantity}</p>
      </div>
    </div>

    <.form for={@price_input} phx-submit="submit" phx-change="validate">
      <.input
        placeholder="Guess the price here (e.g $1.23)"
        phx-hook="PriceInput"
        step="0.01"
        phx-blur="format_price"
        field={@price_input[:price]}
      /> <button>submit</button>
    </.form>

    <p>Result: {if @is_correct_guess, do: "✅", else: "❌"}</p>

    <p>Score: {@number_of_correct} / 10</p>
    """
  end

  def handle_event("submit", %{"price_input" => %{"price" => price}}, socket) do
    formatted_price = format_price_input(price)

    changeset =
      %PriceInput{}
      |> PriceInput.changeset(%{"price" => ""})

    input_price = String.to_float(formatted_price)
    actual_price = socket.assigns.product.price
    is_correct_guess = 0.9 * actual_price <= input_price and input_price <= 1.1 * actual_price

    number_of_correct =
      if is_correct_guess,
        do: socket.assigns.number_of_correct + 1,
        else: socket.assigns.number_of_correct

    {:noreply,
     socket
     |> assign(:price_input, to_form(changeset))
     |> assign(:is_correct_guess, is_correct_guess)
     |> assign(:number_of_correct, number_of_correct)
     |> assign(:product, Products.get_random_product())}
  end

  def handle_event("validate", %{"price_input" => price}, socket) do
    changeset =
      %PriceInput{}
      |> PriceInput.changeset(price)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:price_input, to_form(changeset))}
  end

  def handle_event("format_price", %{"value" => price}, socket) do
    formatted_price = format_price_input(price)

    changeset =
      %PriceInput{}
      |> PriceInput.changeset(%{"price" => formatted_price})
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:price_input, to_form(changeset))}
  end

  defp format_price_input(price) do
    price
    |> String.trim()
    |> String.replace(~r/[^0-9\.]/, "")
    |> String.split(".")
    |> case do
      [integer, decimal] when byte_size(decimal) > 2 ->
        "#{integer}.#{String.slice(decimal, 0, 2)}"

      [integer, decimal] ->
        "#{integer}.#{String.pad_trailing(decimal, 2, "0")}"

      [integer] when integer != "" ->
        "#{integer}.00"

      _ ->
        ""
    end
  end
end
