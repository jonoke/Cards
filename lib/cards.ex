defmodule Cards.CLI do #{
  def main(_args \\ []) do
    Cards.do_something()
  end
end #}

defmodule Cards do #{
  @moduledoc """
    a deal is
      { {c_north,c_east,c_south,c_west}, {s_north,s_east,s_south,s_west}}
    c_north|c_east|c_south|c_west is
      {clubs,diamonds,hearts,spades}
    clubs|diamonds|hearts|spades is
      [ {suit, rank}
    suit is
      0..3
    rank is
      2..14
  """

  @cl 0
  @di 1
  @he 2
  @sp 3
  @nt 4

  @deck_size 14
  @deck  for x <- 0..3, y <- 2..@deck_size, do: {x, y}

  @hcpts { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4 }
  @suits { :C, :D, :H, :S, :NT }
  @ranks { 0, 0, 2, 3, 4, 5, 6, 7, 8, 9, :T, :J, :Q, :K, :A }

  @balanced [{3, 3, 3, 4}, {2, 3, 4, 4}, {2, 3, 3, 5} ]
  @semi_balanced [{2, 2, 4, 5}]

  def insert(card, []), do: [card]
  def insert(card, [hd|tl]) when card < hd, do: [hd|insert(card, tl)]
  def insert(card, holding), do: [card|holding]

  def slip(card = {@cl, _}, {clubs, diamonds, hearts, spades}), do: {insert(card,clubs), diamonds, hearts, spades}
  def slip(card = {@di, _}, {clubs, diamonds, hearts, spades}), do: {clubs, insert(card,diamonds), hearts, spades}
  def slip(card = {@he, _}, {clubs, diamonds, hearts, spades}), do: {clubs, diamonds, insert(card,hearts), spades}
  def slip(card = {@sp, _}, {clubs, diamonds, hearts, spades}), do: {clubs, diamonds, hearts, insert(card,spades)}

  def deal(deck, north\\{[],[],[],[]}, east\\{[],[],[],[]}, south\\{[],[],[],[]}, west\\{[],[],[],[]})
  def deal([], north, east, south, west), do: {{north, east, south, west}, {stats(north), stats(east), stats(south), stats(west)}}
  def deal([hd|tl], north, east, south, west), do: deal(tl, east, south, west, slip(hd, north))

  def hand() do
    @deck |>
    Enum.shuffle()  |>
    deal()
  end

  def balanced?(lens), do: List.to_tuple(Enum.sort(Tuple.to_list(lens))) in @balanced
  def semi_balanced?(lens), do: List.to_tuple(Enum.sort(Tuple.to_list(lens))) in @semi_balanced

  def lengths({clubs,diamonds,hearts,spades}), do: {length(clubs),length(diamonds),length(hearts),length(spades)}

  def hcp(cards, total\\0)
  def hcp([], total), do: total
  def hcp([{_, rank}|tl], total) when rank < 11, do: hcp(tl, total)
  def hcp([{_, rank}|tl], total), do: hcp(tl, total + elem(@hcpts,rank))
  def hcps({clubs,diamonds,hearts,spades}) do
    hcp(clubs) + hcp(diamonds) + hcp(hearts) + hcp(spades)
  end
  def stats(hand) do
    lens = lengths(hand)
    {hcps(hand), lens, balanced?(lens), semi_balanced?(lens)}
  end

  def showCard(rank), do: IO.write "#{elem(@ranks,rank)} "

  def showSuit([]), do: IO.puts ""
  def showSuit([{_,rank}|rest]) do
    showCard(rank)
    showSuit(rest)
  end
  def showSuits({c, d, h, s}) do
    IO.write " C: "
    showSuit(c)
    IO.write " D: "
    showSuit(d)
    IO.write " H: "
    showSuit(h)
    IO.write " S: "
    showSuit(s)
  end
  def show(hand = {{cn, cs, ce, cw},{sn,ss,se,sw}}) do
    IO.puts "North"
    showSuits(cn)
    IO.puts "  #{inspect(sn)}"
    IO.puts "East"
    showSuits(ce)
    IO.puts "  #{inspect(se)}"
    IO.puts "South"
    showSuits(cs)
    IO.puts "  #{inspect(ss)}"
    IO.puts "West"
    showSuits(cw)
    IO.puts "  #{inspect(sw)}"
    hand
  end
  def do_something do
    hand = {{_c_north, _c_east, _c_south, _c_west},{_s_north, _s_east, _s_south, _s_west}} = hand()
    hand |>
#    IO.inspect() |>
    show()
  end
end #}

