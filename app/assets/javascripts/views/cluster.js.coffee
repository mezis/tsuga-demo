# not a proper backbone view, as there is no backing DOM node
tsuga.Views.Cluster = Backbone.Model.extend

  initialize: (options)->
    @cluster  = options.cluster # tsuga.Models.Cluster
    @flags    = options.flags   # tsuga.Models.Flags
    @parent   = options.parent  # tsuga.Views.Map
    @map      = @parent.map     # google.maps.map

    this.listenTo @flags,   'change:labels',     this._onChangeFlags
    this.listenTo @flags,   'change:lines',      this._onChangeFlags
    this.listenTo @cluster, 'change:relWeight',  this._updateColor

    @circle   = null
    @line     = null
    @text     = null

  _prepare: ->
    # console.log 'tsuga.Views.Cluster#render'
    cluster   = @cluster.attributes
    center    = new google.maps.LatLng(cluster.lat, cluster.lng)

    if !@circle
      options =
        strokeColor:    'gray'
        strokeOpacity:  0.8
        strokeWeight:   2
        fillColor:      'gray'
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
        strokeColor:    'red',
        strokeOpacity:  0.2
        strokeWeight:   2

    if !@text && @flags.get('labels') && cluster.weight > 1
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


  remove: ->
    # console.log 'tsuga.Views.Cluster#remove'
    this.stopListening()
    @circle.setMap(null)
    @line.setMap(null)  if @line
    @text.setMap(null)  if @text
    @circle = @line = @text = null


  _onChangeFlags: () ->
    unless @flags.get('lines')
      @line.setMap(null) if @line
      @line = null
    unless @flags.get('labels')
      @text.setMap(null) if @text
      @text = null
    this.render()


  _updateColor: () ->
    hue = (60 - @cluster.get('relWeight') * 60).toFixed()
    color = "hsl(#{hue},100%,50%)"
    @circle.setOptions
      fillColor:   color
      strokeColor: color


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

