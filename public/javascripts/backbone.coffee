socket = io.connect()
socket.on "connect", -> 
    console.log "connected"

# Models
class Device extends Backbone.Model
    url: '/device'
    
    initialize: ->
        _.bindAll @
        console.log "Device model created..."
        @set
            controllers: new Controllers

        @get('controllers').bind 'change', @saveModel
    
    saveModel: ->
        console.log "save Device model..."
        @.save()


class Controller extends Backbone.Model
    
    initialize: ->
        @bind 'change', @test
    
    test: ->
        console.log "test"

# Collections
class Controllers extends Backbone.Collection
    model: Controller
    
    initialize: ->
        @bind 'change', @test
    
    test: ->
        console.log "test2"

class Devices extends Backbone.Collection
    model: Device
    url: '/devices'

# Views
class ControllerView extends Backbone.View
    tagName: 'li'

    initialize: ->
        console.log "Init Controller View"
        _.bindAll @ 

    render: ->
        $(@el).html("#{@model.get('name')}: <div class='btn-group' data-toggle='buttons-radio'>
            <button class='btn' value='On'>On</button>
            <button class='btn' value='Off'>Off</button>
            </div>")
        @

    updateControl: (e) ->
        @model.set 
            value: e.currentTarget.value

    events: 'click button': 'updateControl'

class ControllersView extends Backbone.View
    tagName: 'ul'
    className: 'controllers'

    initialize: ->
        console.log "Init ControllersView"
        _.bindAll @
    
    render: ->
        self = @        
        @model.each (model) -> 
            controller_view = new ControllerView  model: model
            $(self.el).append controller_view.render().el
        @

    addController: ->
        controller_view = new ControllerView model: Controller
        # $(@el).append controller_view.render().el

class DeviceView extends Backbone.View
    tagName: 'li'

    initialize: ->
        console.log "Init Device View"
        _.bindAll @
        @model.bind 'change', @subRender

    render: ->
        console.log "render Device View"
        console.log "el: " + @el
        $(@el).attr('id', "#{@model.id}").addClass('span3 device').html("<h3 name='id'>" + @model.get('name') + "</h3>
            <p>Like you, we love building awesome products on the web.</p>")
        
        controllers_view = new ControllersView model: @model.get('controllers')
        $(@el).append controllers_view.render().el

        @                
        # @model.save "option" "test"

class DevicesView extends Backbone.View

    el: $ '.thumbnails'

    initialize: ->
        console.log "Init Devices View"
        _.bindAll @
        
        @devices = new Devices
        @devices.bind 'add', @appendDevice
        @addAll()
        @render()

    render: ->
        $(@el).append '<li id="addNewDevice" class="span3"><h3>Add new device</h3>
        <p>Fill in your device Id to add a new divice to this page.</p>
        <input type="text" name="id" placeholder="Add the Id of the device..." />
        <input type="text" name="name" placeholder="Add a name.." />
        <button class="btn">Add device</button></li>'

    addDevice: ->
        console.log "Add Device"
        device = new Device
        controller = new Controller
        controller1 = new Controller
        controller.set
            name: "state1"
            value: "on"
        controller1.set
            name: "state2"
            value: "on"
        device.set 
            id: $('#addNewDevice input[name="id"]').val()
            name: $('#addNewDevice input[name="name"]').val()
        device.get('controllers').add([controller, controller1])
        device.save()
        @devices.add(device)

    appendDevice: (device) ->
        console.log "Append Device"
        device_view = new DeviceView model: device
        $(@el).append device_view.render().el

    addAll: ->
        @devices.fetch()

    events: 'click #addNewDevice button': 'addDevice'

# Sync
Backbone.sync = (method, model, options) ->
    getUrl = (object) ->
        return object.url

    namespace = getUrl(model).split('/')[1]
    
    params = _.extend(req: namespace + ':' + method, data: JSON.stringify(model))
    # if ( !params.data && model ) {
    #     params.data = model.toJSON() || {};
    # }

    # If your socket.io connection exists on a different var, change here:
    # io = model.socket || window.socket || Backbone.socket || socket;

    socket.emit namespace + ':' + method, params.data, (err, data) ->
        console.log ('syncing...')
        if (err)
            options.error(err)
        else
            options.success(data)

devices_view = new DevicesView