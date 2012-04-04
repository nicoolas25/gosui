describe "default deck", ->
  it "should contains 100 cards", ->
    deck = full_gosu_deck()
    expect(deck.length).toBe(100)
