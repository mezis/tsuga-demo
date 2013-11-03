# not a proper backbone view, as there is no backing DOM node
tsuga.Views.Point = Backbone.Model.extend

  initialize: (options)->
    @model    = options.model   # tsuga.Models.Cluster
    @parent   = options.parent  # tsuga.Views.Map
    @map      = @parent.map     # google.maps.map
    @circle   = null

  _prepare: ->
    # console.log 'tsuga.Views.Point#render'
    if !@circle
      options =
        strokeOpacity:  0.0
        fillColor:      '#000000'
        fillOpacity:    0.5
        center:         new google.maps.LatLng(@model.get('lat'), @model.get('lng'))
        radius:         this._getRadius()
      @circle = new google.maps.Circle(options)


  render: ->
    this._prepare()
    @circle.setMap(@map)


  remove: ->
    # console.log 'tsuga.Views.Cluster#remove'
    this.stopListening()
    @circle.setMap(null)
    @circle = null


  _getRadius: ->
    0.25 * @parent.defaultRadius

  update: ->
    radius = this._getRadius()
    return if radius == @circle.getRadius()
    @circle.setRadius(radius)
