tsuga.Models.Cluster = Backbone.Model.extend
  defaults:
    id:        null
    lat:       null
    lng:       null
    weight:    null
    dlat:      null
    dlng:      null
    parent:
      lat:     null
      lng:     null
    relWeight: null # set client-side, based on the collection
