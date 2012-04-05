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

  window.Deck = Backbone.Collection.extend
    model: window.Goban


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
      @preload()
      this

    # Preload fullsize image
    preload: (cb) ->
      @preloadedImg = $('<img />')
      @preloadedImg.attr('src', @model.getImagePath('original'))
      @preloadedImg.load(cb) if cb?

  # Army cards get a popover on them
  window.ArmyGobanCardView = GobanCardView.extend
    render: ->
      @$el.popover
        title     : @model.get('name')
        placement : 'fixed'
        content   : "<img src=\"#{@model.getImagePath('original')}\" />"
        template  : '<div class="army-card player-' + @model.get('army').get('player') + ' popover"><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'
      GobanCardView.prototype.render.call(this)

  window.DeckGobanCardView = GobanCardView.extend
    events:
      mouseover: 'zoom'

    zoom: ->
      if @preloadedImg?
        @options.deck.$('div.zoom').html(@preloadedImg)
      else
        @preload =>
          @options.deck.$('div.zoom').html(@preloadedImg)

  window.ArmyView = Backbone.View.extend
    tagName: 'div'
    className: 'army'
    template: _.template($('#goban-army-template').html())

    initialize: ->
      _.bindAll(this, 'render')
      @model.bind('change', @render)

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

  window.DeckView = Backbone.View.extend
    tagName: 'div'
    className: 'deck'
    template: _.template($('#goban-deck-template').html())

    events:
      'change .commands select[name="level-filter"]' : 'filter'
      'change .commands select[name="clan-filter"]'  : 'filter'
      'click  #clear-filter-btn'                     : 'filterClear'

    initialize: ->
      _.bindAll(this, 'render')
      @collection.bind('reset', @render)

    filter: ->
      clan = @$('div.commands select[name="clan-filter"] option:selected').val()
      level = @$('div.commands select[name="level-filter"] option:selected').val()
      @gobanFilteredViews = _.filter @gobanViews, (gobanView) ->
        (gobanView.model.get('level') is level or level is "") and
          (gobanView.model.get('clan') is clan or clan is "")
      @renderFilter()

    filterClear: ->
      @$('div.commands select').val("")
      @gobanFilteredViews = @gobanViews
      @renderFilter()

    renderFilter: ->
      $listElements = @$('ul.list li.card')
      $listElements.hide()
      _.each @gobanFilteredViews, (gobanView) ->
        gobanView.$el.show()

    render: ->
      @$el.html(@template({}))

      @gobanViews = []
      col         = @collection
      $list       = @$('ul.list')

      col.each (goban, idx) =>
        gobanView = new DeckGobanCardView
          model: goban
          deck: this
        @gobanViews.push(gobanView)
        $list.append(gobanView.render().el)
        gobanView.zoom() if idx is 0

      @gobanFilteredViews = @gobanViews

      this

