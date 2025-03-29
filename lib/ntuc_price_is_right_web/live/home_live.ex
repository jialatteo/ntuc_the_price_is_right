defmodule NtucPriceIsRightWeb.HomeLive do
  use NtucPriceIsRightWeb, :live_view
  alias NtucPriceIsRight.Products

  def mount(_params, _session, socket) do
    product = if connected?(socket), do: Products.get_random_product(), else: nil

    {:ok, assign(socket, :product, product)}
  end

  def render(assigns) do
    ~H"""
    <div :if={@product}>
      <p>Title: {@product.title}</p>
      
      <p>Quantity: {@product.quantity}</p>
       <img src={@product.image} alt={@product.title} />
      <p>Price: {@product.price}</p>
    </div>
    """
  end
end
