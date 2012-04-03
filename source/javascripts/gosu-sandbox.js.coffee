$ ->
  cards = new Army
    player: 'Nicolas'
  view = new ArmyView
    model:cards
  $("body").append view.render().el
  cards.setCards [{name:'Kameo',level:2,faction:'meka',gid:'051'},{name:'Visionnaire',level:1,faction:'ancient',gid:'005'}]
  setTimeout ->
    cards.setCards [
      {name:'Ange',level:3,faction:'ancient',gid:'013'},
      {name:'Kokoshomoshu',level:2,faction:'dark',gid:'070'},
      {name:'Exprat',level:2,faction:'fire',gid:'039'},
      {name:'Recruteur',level:1,faction:'alpha',gid:'019'},
      {name:'Recruteur',level:1,faction:'alpha',gid:'019'}]
  , 2000
