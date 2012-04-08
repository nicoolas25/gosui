$ ->
  cards    = new GobanList
  opponent = new Opponent
    player : 'Nicolas'
    army   : cards
    hand   : 5
  view     = new OpponentView
    model  : opponent

  $('body').append view.render().el

  cards.reset full_gosu_deck()[0..4]
  setTimeout ->
    cards.reset _.map(['013','070','039','019','019'], (gid) -> window.goban_index[gid] )
  , 2000

  setTimeout ->
    opponent.set({hand: 7})
  , 3000

  deck = new Deck
  view = new DeckView
    collection:deck
  $('body').append view.render().el
  deck.reset(full_gosu_deck())
