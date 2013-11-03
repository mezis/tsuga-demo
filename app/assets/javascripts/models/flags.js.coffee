_flagsRegexp = /^(?:([^:,]+):([^:,]+))(?:,([^:,]+):([^:,]+))*$/

tsuga.Models.Flags = Backbone.Model.extend
  defaults: ->
    lines:  false
    points: false
    labels: true

  parse: (string) ->
    # console.log "tsuga.Models.Flags#parse '#{string}'"
    matches = _flagsRegexp.exec(string)
    changes = {}
    return unless matches?
    while matches.length > 1
      value = matches.pop()
      key   = matches.pop()
      parsedValue = this._parseValue(value)
      changes[key] = parsedValue
      # console.log "  #{key} -> #{value} -> #{parsedValue}"
    this.set(changes)

  # TODO: this is cacheable
  serialize: ->
    pairs = _.map this.keys, (key) =>
      value = this._dumpValue(this.get(key))
      "#{key}:#{value}"
    pairs.join()

  keys: ['lines', 'points', 'labels']

  _dumpValue: (value) ->
    switch typeof(value)
      when 'boolean' then (if value then '✔' else '✘')
      when 'number'  then value.toString()
      when 'string'  then value
      else throw new TypeError()

  _parseValue: (string) ->
    result = switch
      when /^[Nn✘]$/.test(string)           then false
      when /^[Yy✔]$/.test(string)           then true
      when /^[0-9]+$/.test(string)          then parseInt(string)
      when /^[0-9]*\.[0-9]+$/.test(string)  then parseFloat(string)
      else string
    # console.log "tsuga.Models.Flags#_parseValue '#{string}' -> #{result}"
    return result
