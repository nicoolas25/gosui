$ ->
  cards = new Army
    player: 'Nicolas'
  view = new ArmyView
    model:cards
  $('body').append view.render().el
  cards.setCards full_gosu_deck()[0..4]
  setTimeout ->
    cards.setCards _.map(['013','070','039','019','019'], (gid) -> window.goban_index[gid] )
  , 2000

  deck = new Deck
  view = new DeckView
    collection:deck
  $('body').append view.render().el
  deck.reset(full_gosu_deck())
