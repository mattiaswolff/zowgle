class Device extends Backbone.Model
    defaults:
        part1: 'Hello'
        part2: 'Backbone' 

class Devices extends Backbone.Collection
    model: Device

class DeviceView extends Backbone.View

    tagName: 'li'

    initialize: ->
        _.bindAll @

    render: ->
        $(@el).html "<span>#{@model.get 'part1'} Nisse! #{@model.get 'part2'}!</span>"

        @

class DevicesView extends Backbone.View

    el: $ '.thumbnails'

    initialize: ->
        _.bindAll @
        
        @devices = new Devices
        @devices.bind 'add', @appendDevice
        
        @counter = 0
        @render()

    render: ->
        $(@el).append '<li>Hello, Backbone! <button>Add View</button></li>'

    addDevice: ->
        device = new Device
        device.set part1: "test"
        device.set part2: "part2"

        @devices.add device

    appendDevice: (device) ->
        device_view = new DeviceView model: device
        $(@el).append device_view.render().el

    events: 'click button': 'addDevice'

devices_view = new DevicesView