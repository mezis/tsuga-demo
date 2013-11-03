tsuga.Routers.Map = Backbone.Router.extend

  routes: {
    ':zoom/lat::lat,lng::lng/*flags': '_panMapAction',
    '*path':                          '_panMapDefaultAction'
  }

  initialize: ->
    @flags        = new tsuga.Models.Flags()
    @flagsView    = new tsuga.Views.Flags({ model: @flags })
    @map          = new tsuga.Models.Map()
    @view         = new tsuga.Views.Map({ model: @map })
    @clusters     = new tsuga.Collections.Clusters()
    @clustersView = new tsuga.Views.Clusters
      parent:   @view
      clusters: @clusters
      flags:    @flags
    @points       = new tsuga.Collections.Points()
    @pointsView   = new tsuga.Views.Points
      parent:   @view
      models:   @points
      flags:    @flags

    this.listenTo @map,      'change:position', this._updateNavigation
    this.listenTo @map,      'change:position', this._updateClusters
    this.listenTo @flags,    'change',          this._updateNavigation

    this.listenToOnce @view, 'idle:viewport', =>
      console.log '*** first update'
      this._updateNavigation()
      this._updateClusters()
    this.listenTo @flags,    'change:points',   this._updatePoints

    @view.render()
    console.log 'tsuga.Routers.Map#initialize done'


  _panMapDefaultAction: ->
    console.log 'tsuga.Routers.Map#_panMapDefaultAction'
    @map.set 'position', @map.defaults().position


  _panMapAction: (zoom, lat, lng, flags) ->
    console.log 'tsuga.Routers.Map#_panMapAction'
    @flags.parse(flags)
    @map.set 'position',
      zoom: parseInt(zoom)
      lat:  parseFloat(lat)
      lng:  parseFloat(lng)


  _updateNavigation: ->
    console.log 'tsuga.Routers.Map#_updateNavigation'
    position = @map.get('position')
    lat = sprintf('%.4f', position.lat)
    lng = sprintf('%.4f', position.lng)
    flags = @flags.serialize()
    this.navigate "#{position.zoom}/lat:#{lat},lng:#{lng}/#{flags}",
      trigger: false


  _updateClusters: ->
    console.log 'tsuga.Routers.Map#_updateClusters'
    @clusters.fetch
      data: this._getRect()
      success: => (this._updatePoints())


  _updatePoints: (collection, response, options) ->
    console.log 'tsuga.Routers.Map#_updatePoints'
    if @flags.get('points') && @clusters.totalWeight() < 2000
      @points.fetch
        data: this._getRect()
        success: =>
          @points.trigger('update')
    else
      @points.reset()


  _getRect: ->
    position = @map.get('position')
    viewport = @map.get('viewport')
    result =
      z:   position.zoom
      n:   viewport.n
      s:   viewport.s
      e:   viewport.e
      w:   viewport.w


