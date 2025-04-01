defmodule NtucPriceIsRightWeb.HomeLive do
  use NtucPriceIsRightWeb, :live_view
  alias NtucPriceIsRight.Products
  alias NtucPriceIsRight.GuessedPrice

  defmodule Submission do
    defstruct [:id, :product_name, :image, :actual_price, :guessed_price, :quantity, :is_correct]

    @type t :: %__MODULE__{
            id: String.t(),
            product_name: String.t(),
            image: String.t(),
            quantity: String.t(),
            actual_price: float(),
            guessed_price: float(),
            is_correct: boolean()
          }
  end

  def mount(_params, _session, socket) do
    product = if connected?(socket), do: Products.get_random_product(), else: nil
    guessed_price_form = to_form(GuessedPrice.changeset(%GuessedPrice{}, %{}))

    {:ok,
     socket
     |> assign(:number_of_correct, 0)
     |> assign(:product, product)
     |> stream(:submissions, [])
     |> assign(:guessed_price_form, guessed_price_form)}
  end

  def render(assigns) do
    ~H"""
    <div :if={@product} class="border p-4">
      <div class="flex flex-col items-center">
        <img src={@product.image} alt={@product.title} />
      </div>
      
      <div class="flex flex-col gap-2">
        <p class="font-bold text-3xl">${:erlang.float_to_binary(@product.price, decimals: 2)}</p>
        
        <p class="text-2xl">{@product.title}</p>
        
        <p class="text-xl font-medium text-gray-500">{@product.quantity}</p>
      </div>
    </div>

    <.form class="relative" for={@guessed_price_form} phx-submit="submit" phx-change="validate">
      <div class="flex mt-[9px] items-center font-semibold justify-center absolute left-0 top-0 h-[44px] sm:h-[42px] rounded-l-lg w-8 text-xl border-r">
        $
      </div>
      
      <div class="flex w-full items-start">
        <.input
          placeholder="Guess the price (e.g $1.23)"
          class="flex-1"
          phx-debounce="300"
          input_class="pl-9 text-xl w-full"
          phx-hook="GuessedPrice"
          step="0.01"
          phx-blur="format_price"
          field={@guessed_price_form[:price]}
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

    <p>Score: {@number_of_correct} / 10</p>

    <div id="submissions" phx-update="stream">
      <div
        :for={{dom_id, submission} <- @streams.submissions}
        class={[
          submission.is_correct && "bg-green-300",
          !submission.is_correct && "bg-red-300"
        ]}
        class="flex"
        id={dom_id}
      >
        <img src={submission.image} alt={submission.product_name} />
        <p>{submission.product_name} ({submission.quantity})</p>
        
        <p>{submission.actual_price}</p>
        
        <p>{submission.guessed_price}</p>
      </div>
    </div>
    """
  end

  def handle_event("submit", %{"guessed_price" => %{"price" => price}}, socket) do
    changeset = GuessedPrice.changeset(%GuessedPrice{}, %{"price" => price})

    if changeset.valid? do
      guessed_price = price |> format_guessed_price() |> String.to_float()
      actual_price = socket.assigns.product.price

      is_correct_guess =
        0.9 * actual_price <= guessed_price and guessed_price <= 1.1 * actual_price

      number_of_correct =
        if is_correct_guess,
          do: socket.assigns.number_of_correct + 1,
          else: socket.assigns.number_of_correct

      submission = %Submission{
        id: Ecto.UUID.generate(),
        image: socket.assigns.product.image,
        product_name: socket.assigns.product.title,
        quantity: socket.assigns.product.quantity,
        actual_price: actual_price,
        guessed_price: guessed_price,
        is_correct: is_correct_guess
      }

      {:noreply,
       socket
       |> stream_insert(:submissions, submission, at: 0)
       |> assign(:guessed_price_form, to_form(GuessedPrice.changeset(%GuessedPrice{}, %{})))
       |> assign(:is_correct_guess, is_correct_guess)
       |> assign(:number_of_correct, number_of_correct)
       |> assign(:product, Products.get_random_product())}
    else
      {:noreply,
       assign(socket, :guessed_price_form, to_form(changeset |> Map.put(:action, :submit)))}
    end
  end

  def handle_event("validate", %{"guessed_price" => price}, socket) do
    changeset =
      %GuessedPrice{}
      |> GuessedPrice.changeset(price)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:guessed_price_form, to_form(changeset))}
  end

  def handle_event("format_price", %{"value" => price}, socket) do
    formatted_price = format_guessed_price(price)

    IO.inspect(formatted_price, label: "formatted_price")

    changeset =
      %GuessedPrice{}
      |> GuessedPrice.changeset(%{"price" => formatted_price})
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:guessed_price_form, to_form(changeset))}
  end

  defp format_guessed_price(price) do
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
