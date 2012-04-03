$ ->
  cards = new Army
    player: 'Nicolas'
  view = new ArmyView
    model:cards
  $("body").append view.render().el
  cards.setCards [{name:'Kameo',level:2},{name:'Visionnaire',level:1}]
  setTimeout ->
    cards.setCards [{name:'Ange',level:3},{name:'Kokoshomoshu',level:2},{name:'Exprat',level:2},{name:'Recruteur',level:1},{name:'Recruteur',level:1}]
  , 2000
