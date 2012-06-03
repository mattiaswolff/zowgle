class Device extends Backbone.Model

class Controller extends Backbone.Model 

class Devices extends Backbone.Collection
    model: Device

class DeviceView extends Backbone.View

    tagName: 'li'

    modelBinder: undefined

    initialize: ->
        
        _.bindAll @
        
        @model.bind 'change', @render
        @modelBinder = new Backbone.ModelBinder();
    
    render: ->
        
        $(@el).attr('id', "#{@model.id}").addClass('span3 device').html("<h3 name='id'></h3>
            <p>Like you, we love building awesome products on the web.</p>
            <p>This is a test: <span name='id'></span>
            <div id='switch' class='.btn-group ' data-toggle='buttons-radio'>
                <button class='btn' value='on' name='state'>On</button>
                <button class='btn' value='off' name='state'>Off</button>
            <input name='id' /></div>")
        
        @modelBinder.bind @model, @el
        @modelBinder.bind @model, @el
        
        $(@el).children('button').removeClass('active')
        if ("#{@model.get('controllers')[0].value}" == "on")
            $(@el).find('button[value="on"]').addClass('active')
        else
            $(@el).find('button[value="off"]').addClass('active')

        @

    updateControl: (e) ->
        @model.set 
            id: $(@el).attr('id')
            controllers: [
                {name: "state"
                value: $(e.target).val()}
            ]
                
        # @model.save "option" "test"

    events: 'click .device button': 'updateControl'


class DevicesView extends Backbone.View

    el: $ '.thumbnails'

    initialize: ->
        _.bindAll @
        
        @devices = new Devices
        @devices.bind 'add', @appendDevice
        
        @counter = 0
        @render()

    render: ->
        $(@el).append '<li id="addNewDevice" class="span3"><h3>Add new device</h3>
        <p>Fill in your device Id to add a new divice to this page.</p>
        <input type="text" />
        <button class="btn">Add device</button></li>'

    addDevice: ->
        device = new Device
        controller = new Controller
        controller.set
            name: "state"
            value: "on"
        deviceId = $('#addNewDevice input').val()
        device.set 
            id: deviceId
            controllers: [controller]
                
        device.save "option"

        @appendDevice device

    appendDevice: (device) ->
        device_view = new DeviceView model: device
        $(@el).append device_view.render().el

    events: 'click #addNewDevice button': 'addDevice'
    
Backbone.sync = (method, model, options) -> 
    switch method
        when "create" then resp = "test 1"
        when "read" then resp = "test 2"
        when "update" then resp = "test 3"
        when "delete" then resp = "test 4"
    console.log "Method: " + method
    console.log "Model: " + JSON.stringify model.attributes
    sendState model.attributes
    if resp
        options.success resp
    else
        options.error "Record not found"

devices_view = new DevicesView