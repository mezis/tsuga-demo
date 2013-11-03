tsuga.Views.Flags = Backbone.View.extend

  el: ->
    $('#map-flags')

  events: ->
    _.tap {}, (result) =>
      _.each this.model.keys, (key) ->
        result["click .js-#{key}"] = -> (this._onToggle(key))

  # events:
  #   'click .js-lines':  -> (this._onToggle('lines'))

  initialize: ->
    this.listenTo this.model, 'change', this.render
    this.render()

  render: ->
    # console.log "tsuga.Views.Flags#render"
    _.each this.model.keys, (key) =>
      this.$("input.js-#{key}").prop('checked', this.model.get(key))

  _onToggle: (field) ->
    # console.log "tsuga.Views.Flags#_onToggle"
    this.model.set(field, !this.model.get(field))
