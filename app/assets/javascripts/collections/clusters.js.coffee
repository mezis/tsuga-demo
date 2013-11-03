tsuga.Collections.Clusters = Backbone.Collection.extend
  model: tsuga.Models.Cluster
  url: '/clusters'

  initialize: ->
    this.listenTo this, 'update', this._updateWeights
  
  totalWeight: ->
    this.map((cluster) -> (cluster.get('weight'))).reduce(((a,b) -> (a+b)), 0)

  _updateWeights: ->
    minWeight = this.min((c) -> (c.get('weight'))).get('weight')
    maxWeight = this.max((c) -> (c.get('weight'))).get('weight')

    this.each (cluster) ->
      relWeight = 1.0 * (cluster.get('weight') - minWeight) / (maxWeight - minWeight)
      cluster.set('relWeight', relWeight)
