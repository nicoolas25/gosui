$ ->
  window.Goban = Backbone.Model.extend
    getImagePath: (size) -> "images/gobans/#{size}/#{@get('clan')}/#{@get('gid')}.jpg"

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
      renderedContent = @template
        attr : @model.toJSON()
        url  : @model.getImagePath('small')

      @$el.html(renderedContent)
      this

  # Army cards get a popover on them
  window.ArmyGobanCardView = GobanCardView.extend
    # Preload fullsize image
    preload: -> $('<img />').attr('src', @model.getImagePath('original'))

    render: ->
      @preload()
      @$el.popover
        title     : @model.get('name')
        placement : 'fixed'
        content   : "<img src=\"#{@model.getImagePath('original')}\" />"
        template  : '<div class="army-card player-' + @model.get('army').get('player') + ' popover"><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'
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
          when "bakuto" then $bakutos
          when "hero"   then $heros
          when "ozeki"  then $ozekis
        targetLine.append(gobanView.render().el)

      this

