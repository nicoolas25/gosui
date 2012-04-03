$ ->
  window.Goban = Backbone.Model.extend
    defaults:
      level: 1
      url: "http://placehold.it/175x250"

  window.GobanList = Backbone.Collection.extend
    model: window.Goban

  window.Army = Backbone.Model.extend
    defaults: ->
      cards: new GobanList

    setCards: (encodedCards) ->
      encodedCards = _.map(encodedCards, (encodedCard) => encodedCard.army = this ; encodedCard)
      @set
        cards: new GobanList(encodedCards)

  window.GobanCardView = Backbone.View.extend
    tagName: 'li'
    className: 'card'
    template: _.template($('#goban-card-template').html())

    initialize: ->
      _.bindAll(this, 'render')
      @model.bind 'change', @render

    render: ->
      renderedContent = @template(@model.toJSON())
      @$el.html(renderedContent)
      this

  # Army cards get a popover on them
  window.ArmyGobanCardView = GobanCardView.extend
    render: ->
      @$el.popover
        title   : @model.get('name')
        content : "<img src=\"#{@model.get('url')}\" />"
        template: '<div class="army-card player-' + @model.get('army').get('player') + ' popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'
      GobanCardView.prototype.render.call(this)

  window.ArmyView = Backbone.View.extend
    tagName: 'div'
    className: 'army'
    template: _.template($('#goban-army-template').html())

    initialize: ->
      _.bindAll(this, 'render')
      @model.bind('change', @render)
      @bakutos = @heros = @ozekis = []

    render: ->
      @$el.html(@template({}))

      col      = @model.get('cards')
      player   = @model.get('player')
      $bakutos = @$('.bakutos')
      $heros   = @$('.heros')
      $ozekis  = @$('.ozekis')

      $bakutos.empty()
      $heros.empty()
      $ozekis.empty()
      $("div.popover.player-#{player}").remove()

      col.each (goban) ->
        gobanView = new ArmyGobanCardView
          model: goban
        targetLine = switch goban.get('level')
          when 1 then $bakutos
          when 2 then $heros
          when 3 then $ozekis
        targetLine.append(gobanView.render().el)

      this

