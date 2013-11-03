# not a proper backbone view, as there is no backing DOM node
tsuga.Views.Cluster = Backbone.Model.extend

  initialize: (options)->
    @cluster  = options.cluster # tsuga.Models.Cluster
    @flags    = options.flags   # tsuga.Models.Flags
    @parent   = options.parent  # tsuga.Views.Map
    @map      = @parent.map     # google.maps.map

    this.listenTo @flags, 'change:lines', this._onChangeFlags

    @circle   = null
    @line     = null
    @text     = null

  _prepare: ->
    # console.log 'tsuga.Views.Cluster#render'
    cluster   = @cluster.attributes
    center    = new google.maps.LatLng(cluster.lat, cluster.lng)
    fillColor = if (cluster.weight == 1) then '#ff00ff' else '#ff0000'

    if !@circle
      options =
        strokeOpacity:  0.0
        fillColor:      fillColor
        fillOpacity:    0.2
        center:         center
        radius:         this._getRadius(center, cluster)
      @circle = new google.maps.Circle(options)
      google.maps.event.addListener @circle, 'click', => (this._onClick())

    if !@line && @flags.get('lines') && cluster.parent.lat
      parent = new google.maps.LatLng(cluster.parent.lat, cluster.parent.lng)
      @line = new google.maps.Polyline
        path:           [center, parent]
        geodesic:       true
        strokeColor:    fillColor,
        strokeOpacity:  0.2
        strokeWeight:   2

    if !@text && cluster.weight > 1
      textOptions =
        content:        cluster.weight,
        boxClass:       'cluster-info'
        disableAutoPan: true,
        pixelOffset:    new google.maps.Size(-45, -9),
        position:       center,
        closeBoxURL:    '',
        isHidden:       false,
        enableEventPropagation: true
      @text = new InfoBox(textOptions)


  render: ->
    this._prepare()
    @circle.setMap(@map)
    @line.setMap(@map)  if @line
    @text.open(@map)    if @text


  unrender: ->
    # console.log 'tsuga.Views.Cluster#unrender'
    @circle.setMap(null)
    @line.setMap(null)  if @line
    @text.setMap(null)  if @text


  _onChangeFlags: () ->
    if @flags.get('lines')
      this.render()
    else
      @line.setMap(null) if @line
      @line = null


  _onClick: () ->
    # console.log("click on cluster")
    @map.setCenter(@circle.getCenter())
    @map.setZoom(@map.getZoom() + 1)


  _getRadius: (center, cluster) ->
    if cluster.weight == 1
      return @parent.defaultRadius
      
    point = new google.maps.LatLng(cluster.lat + cluster.dlat, cluster.lng + cluster.dlng)
    radius = google.maps.geometry.spherical.computeDistanceBetween(center, point)
    return Math.max(radius, @parent.defaultRadius)

