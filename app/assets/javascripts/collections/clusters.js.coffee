tsuga.Collections.Clusters = Backbone.Collection.extend
  model: tsuga.Models.Cluster
  url: '/clusters'
  
  totalWeight: ->
    this.map((cluster) -> (cluster.get('weight'))).reduce(((a,b) -> (a+b)), 0)