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

    <.form class="relative" for={@price_input} phx-submit="submit" phx-change="validate">
      <div class="flex mt-2 items-center font-semibold justify-center absolute left-0 top-0 h-[46px] sm:h-[42px] rounded-l-lg w-8 text-xl text-white bg-green-600">
        $
      </div>
      
      <div class="flex w-full items-start">
        <.input
          placeholder="Guess the price here (e.g $1.23)"
          class="flex-1"
          input_class="pl-9 text-xl w-full"
          phx-hook="PriceInput"
          step="0.01"
          phx-blur="format_price"
          field={@price_input[:price]}
        />
        <button title="Submit" class="mt-[14px] ml-1">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="currentColor"
            class="size-8 hover:fill-gray-500"
            viewBox="2.25 2.25 19.5 19.5"
          >
            <path
              fill-rule="evenodd"
              d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm4.28 10.28a.75.75 0 0 0 0-1.06l-3-3a.75.75 0 1 0-1.06 1.06l1.72 1.72H8.25a.75.75 0 0 0 0 1.5h5.69l-1.72 1.72a.75.75 0 1 0 1.06 1.06l3-3Z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
      </div>
    </.form>

    <p>Result: {if @is_correct_guess, do: "✅", else: "❌"}</p>

    <p>Score: {@number_of_correct} / 10</p>
    """
  end

  def handle_event("submit", %{"price_input" => %{"price" => price}}, socket) do
    changeset = PriceInput.changeset(%PriceInput{}, %{"price" => price})

    if changeset.valid? do
      formatted_price = format_price_input(price)

      input_price = String.to_float(formatted_price)
      actual_price = socket.assigns.product.price
      is_correct_guess = 0.9 * actual_price <= input_price and input_price <= 1.1 * actual_price

      number_of_correct =
        if is_correct_guess,
          do: socket.assigns.number_of_correct + 1,
          else: socket.assigns.number_of_correct

      {:noreply,
       socket
       |> assign(:price_input, to_form(PriceInput.changeset(%PriceInput{}, %{})))
       |> assign(:is_correct_guess, is_correct_guess)
       |> assign(:number_of_correct, number_of_correct)
       |> assign(:product, Products.get_random_product())}
    else
      {:noreply, assign(socket, :price_input, to_form(changeset |> Map.put(:action, :submit)))}
    end
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
