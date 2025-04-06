defmodule NtucPriceIsRightWeb.HomeLive do
  use NtucPriceIsRightWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center py-8 px-4">
      <!-- Game Title -->
      <img src="/images/fairprice.png" alt="fairprice" />
      <h1 class="text-5xl font-bold mb-12">The Price Is Right</h1>
      
    <!-- Game Modes -->
      <div class="flex flex-col gap-4 mb-6">
        <a
          class="text-4xl rounded p-4 text-center text-white bg-[#005596] hover:bg-[#0055968c]"
          href="/single-player"
        >
          Single player
        </a>
        
        <a
          class="text-4xl rounded p-4 text-center text-white bg-[#005596] hover:bg-[#0055968c]"
          href="/multi-player"
        >
          Multi player
        </a>
        
        <a
          class="text-4xl rounded p-4 text-center text-white bg-[#005596] hover:bg-[#0055968c]"
          href="/leaderboard"
        >
          Leaderboard
        </a>
      </div>
      
    <!-- Game Rules -->
      <div class="my-6">
        <h2 class="text-xl font-semibold mb-3">How to Play:</h2>
        
        <p>Guess within 20% of the product's actual price.</p>
        
        <p>You have 30 seconds to get as many points as possible!</p>
        
        <ul class="list-inside list-disc mt-3 flex flex-col items-start">
          <li>1 correct streak = 1 point</li>
          
          <li>2 correct streak = 2 points</li>
          
          <li>3 correct streak = 3 points</li>
          
          <li>4 correct streak = 4 points</li>
          
          <li>5+ correct streak = 5 points</li>
        </ul>
      </div>
      
    <!-- Product Info -->
      <div class="text-center text-sm text-gray-600 mb-6">
        <p>
          Products were scraped as of 27 March 2025 from
          <a
            class="text-blue-500 hover:text-blue-300 hover:underline"
            href="https://www.fairprice.com.sg"
            target="_blank"
          >
            fairprice.com.sg
          </a>
        </p>
      </div>
    </div>
    """
  end
end
