# not a proper backbone view, as there is no backing DOM node
tsuga.Views.Points = Backbone.Model.extend
  initialize: (options)->
    @models    = options.models   # tsuga.Collections.Points
    @parent    = options.parent   # tsuga.Views.Map
    @flags     = options.flags    # tsuga.Models.Flags
    @views     = {}               # of tsuga.Views.Point

    this.listenTo @models, 'add',    this._addPoint
    this.listenTo @models, 'remove', this._removePoint
    this.listenTo @models, 'reset',  this._removeAll
    this.listenTo @models, 'update', this._updateAll


  render: ->
    null


  _addPoint: (model, collection) ->
    view = new tsuga.Views.Point
      model:    model
      parent:   @parent
      flags:    @flags
    view.render()
    @views[model.id] = view


  _removePoint: (model, collection) ->
    view = @views[model.id]
    return unless view
    view.remove()
    delete @views[model.id]


  _removeAll: (collection, options) ->
    console.log 'tsuga.Views.Points#_removeAll'
    view.remove() for id, view of @views
    @views = {}


  _updateAll: ->
    view.update() for id, view of @views
