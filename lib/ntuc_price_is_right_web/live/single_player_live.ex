defmodule NtucPriceIsRightWeb.SinglePlayerLive do
  use NtucPriceIsRightWeb, :live_view
  alias NtucPriceIsRight.Products
  alias NtucPriceIsRight.GuessedPrice

  defmodule Submission do
    defstruct [
      :id,
      :product_name,
      :image,
      :actual_price,
      :guessed_price,
      :quantity
    ]

    @type t :: %__MODULE__{
            id: String.t(),
            product_name: String.t(),
            image: String.t(),
            quantity: String.t(),
            actual_price: float(),
            guessed_price: float()
          }
  end

  def mount(_params, _session, socket) do
    product = if connected?(socket), do: Products.get_random_product(), else: nil
    guessed_price_form = to_form(GuessedPrice.changeset(%GuessedPrice{}, %{}))

    {:ok,
     socket
     |> assign(:score, 0)
     |> assign(:is_game_in_progress, true)
     |> assign(:correct_streak, 0)
     |> assign(:product, product)
     |> stream(:submissions, [])
     |> assign(:guessed_price_form, guessed_price_form)}
  end

  def render(assigns) do
    ~H"""
    <div
      :if={@is_game_in_progress}
      phx-update="ignore"
      id="countdown"
      phx-hook="CountdownTimer"
      class="w-full bg-gray-300 rounded-lg text-center h-10 my-4 relative overflow-hidden"
    >
      <span class="absolute inset-0 flex items-center justify-center text-white font-bold">
        <!-- Countdown text will be updated here -->
      </span>
      <div
        id="progress-bar"
        class="bg-blue-500 h-10"
        style="width: 100%; transition: width 1s linear;"
      />
    </div>

    <div :if={@product && @is_game_in_progress} class="border rounded-lg p-4">
      <div class="flex flex-col items-center">
        <img class="size-80" src={@product.image} alt={@product.title} />
      </div>
      
      <div class="flex flex-col gap-2">
        <p class="font-bold text-3xl">${:erlang.float_to_binary(@product.price, decimals: 2)}</p>
        
        <p class="text-2xl">{@product.title}</p>
        
        <p class="text-xl font-medium text-gray-500">{@product.quantity}</p>
      </div>
    </div>

    <.form
      :if={@is_game_in_progress}
      class="relative"
      for={@guessed_price_form}
      phx-submit="submit"
      phx-change="validate"
    >
      <div class="flex mt-[9px] items-center font-semibold justify-center absolute left-0 top-0 h-[44px] sm:h-[42px] rounded-l-lg w-8 text-xl border-r">
        $
      </div>
      
      <div class="flex w-full items-start">
        <.input
          placeholder="Guess the price (e.g $1.23)"
          class="flex-1"
          phx-debounce="300"
          input_class="pl-9 text-xl w-full rounded-r-none"
          phx-hook="GuessedPrice"
          step="0.01"
          phx-blur="format_price"
          autocomplete="off"
          field={@guessed_price_form[:price]}
        />
        <button
          title="Submit"
          class="mt-[8px] font-semibold rounded-r-lg py-[11px] text-white hover hover:bg-gray-400 bg-black px-1 sm:py-[9px]"
        >
          <p>Guess</p>
        </button>
      </div>
    </.form>

    <div class="border rounded-lg mt-6 mb-6 p-2 pb-6">
      <p class="text-2xl font-bold mb-4">Score</p>
      
      <div class="flex justify-center text-2xl font-bold ">
        <div class="relative ">
          <div
            id="score-flash"
            class="absolute bottom-4 text-green-500 font-bold text-3xl opacity-0 transition-all duration-500"
            phx-hook="ScoreAnimation"
          >
            +{min(@correct_streak, 5)}
          </div>
          
          <p class="text-3xl">{@score}</p>
        </div>
      </div>
      
      <div :if={!@is_game_in_progress} class="flex text-2xl flex-col items-center font-bold mt-10">
        <p>Great job!</p>
         <img src="/images/smiling_emoji.png" class="size-28" alt="Win Image" />
      </div>
    </div>

    <div class="border rounded-lg p-2">
      <p class="text-2xl font-bold mb-4">Previous guesses</p>
      
      <.table table_class="w-full" id="submissions" rows={@streams.submissions}>
        <:col :let={{dom_id, submission}} label="Product">
          <div class="flex sm:flex-row flex-col sm:items-center text-sm">
            <img class="size-12" src={submission.image} alt="submission.product_name" />
            <span class="sm:ml-1">
              {submission.product_name} ({submission.quantity})
            </span>
          </div>
        </:col>
        
        <:col :let={{dom_id, submission}} label="Actual Price">
          <p class="text-xl font-semibold">
            ${submission.actual_price}
          </p>
        </:col>
        
        <:col :let={{dom_id, submission}} label="Guessed Price">
          <p class="text-xl font-semibold">
            ${submission.guessed_price}
          </p>
        </:col>
        
        <:col :let={{dom_id, submission}} label="Points">
          <p class={[
            "text-2xl font-bold",
            if(@correct_streak > 0, do: "text-green-500", else: "text-gray-400")
          ]}>
            +{min(@correct_streak, 5)}
          </p>
        </:col>
      </.table>
    </div>
    """
  end

  def handle_event("submit", %{"guessed_price" => %{"price" => price}}, socket) do
    changeset = GuessedPrice.changeset(%GuessedPrice{}, %{"price" => price})

    if changeset.valid? do
      guessed_price = price |> format_guessed_price() |> String.to_float()
      actual_price = socket.assigns.product.price

      is_correct_guess =
        0.8 * actual_price <= guessed_price and guessed_price <= 1.2 * actual_price

      correct_streak =
        if is_correct_guess,
          do: socket.assigns.correct_streak + 1,
          else: 0

      score = socket.assigns.score + min(correct_streak, 5)

      submission = %Submission{
        id: Ecto.UUID.generate(),
        image: socket.assigns.product.image,
        product_name: socket.assigns.product.title,
        quantity: socket.assigns.product.quantity,
        actual_price: :erlang.float_to_binary(actual_price, decimals: 2),
        guessed_price: format_guessed_price(price)
      }

      socket =
        if is_correct_guess,
          do: push_event(socket, "animate_score", %{}),
          else: socket

      {:noreply,
       socket
       |> stream_insert(:submissions, submission, at: 0)
       |> assign(:guessed_price_form, to_form(GuessedPrice.changeset(%GuessedPrice{}, %{})))
       |> assign(:is_correct_guess, is_correct_guess)
       |> assign(:correct_streak, correct_streak)
       |> assign(:score, score)
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

    changeset =
      %GuessedPrice{}
      |> GuessedPrice.changeset(%{"price" => formatted_price})
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:guessed_price_form, to_form(changeset))}
  end

  def handle_event("countdown_completed", _params, socket) do
    {:noreply, assign(socket, :is_game_in_progress, false)}
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
