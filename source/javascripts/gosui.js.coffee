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
    tagName: 'span'

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

    isFiltered: (level, clan) ->
      (@model.get('level') is level or level is null) and (@model.get('clan') is clan or clan is null)

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
      $bakutos = @$('tr.bakutos')
      $heros   = @$('tr.heros')
      $ozekis  = @$('tr.ozekis')

      $("div.popover.player-#{player}").remove()

      col.each (goban) ->
        gobanView = new ArmyGobanCardView
          model: goban
        targetLine = switch goban.get('level')
          when "bakuto" then $bakutos
          when "hero"   then $heros
          when "ozeki"  then $ozekis
        targetLine.find('td:empty').first().html(gobanView.render().el)

      # Opacify empty cells
      @$('.details td:empty').css(opacity: 0.5)

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

    updateFilters: ->
      @filteredClan  = @$('div.commands select[name="clan-filter"] option:selected').val()
      @filteredLevel = @$('div.commands select[name="level-filter"] option:selected').val()
      @filteredClan  = null if @filteredClan is ""
      @filteredLevel = null if @filteredLevel is ""

    filter: ->
      @updateFilters()
      @renderFilter()

    filterClear: ->
      @$('div.commands select').val("")
      @filteredLevel = @filteredClan = null
      @renderFilter()

    renderFilter: ->
      $listElements = @$('ul.list li.card')
      $listElements.hide()
      _.each @gobanViews, (gobanView) =>
        gobanView.$el.show() if gobanView.isFiltered(@filteredLevel, @filteredClan)

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

      @renderFilter() if @filteredClan? or @filteredLevel?

      this

