
tsuga.Models.Flags = Backbone.Model.extend
  defaults: ->
    lines:  false
    points: false
    labels: true

  parse: (string) ->
    # console.log "tsuga.Models.Flags#parse '#{string}'"
    matches = this._flagsRegexp.exec(string)
    changes = {}
    for pair in string.split(',')
      [_all, key, value] = this._flagsRegexp.exec(pair)
      continue unless key && value
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

  _flagsRegexp: /^([^:,]+):([^:,]+)$/


