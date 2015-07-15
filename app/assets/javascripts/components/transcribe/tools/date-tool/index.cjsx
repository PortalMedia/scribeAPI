# @cjsx React.DOM
React      = require 'react'
Draggable  = require '../../../../lib/draggable'
DoneButton = require './done-button'
PrevButton = require './prev-button'
ReactRouter = require 'react-router' # eventually replace with {Navigation} = require 'react-router' -- STI

DateTool = React.createClass
  displayName: 'DateTool'

  mixins: [ReactRouter] # NOTE: deprecated React-Router 13.3 uses Navigation minxin --STI

  handleInitStart: (e) ->
    @setState preventDrag: false
    if e.target.nodeName is "INPUT" or e.target.nodeName is "TEXTAREA"
      @setState preventDrag: true

    @setState
      xClick: e.pageX - $('.transcribe-tool').offset().left
      yClick: e.pageY - $('.transcribe-tool').offset().top

  handleInitDrag: (e, delta) ->
    return if @state.preventDrag # not too happy about this one

    dx = e.pageX - @state.xClick - window.scrollX
    dy = e.pageY - @state.yClick # + window.scrollY

    @setState
      dx: dx
      dy: dy #, =>
      dragged: true

  getInitialState: ->
    # compute component location
    {x,y} = @getPosition @props.subject.data
    dx: x
    dy: y
    viewerSize: @props.viewerSize

  getPosition: (data) ->
    switch data.toolName
      when 'rectangleTool'
        x = data.x
        y = parseFloat(data.y) + parseFloat(data.height)
      when 'textRowTool'
        x = data.x
        y = data.yLower
      else # default for pointTool
        x = data.x
        y = data.y
    return {x,y}

  getDefaultProps: ->
    annotation: {}
    task: null
    subject: null
    standalone: true
    key: 'value'
    focus: true

  componentWillReceiveProps: ->
    # @refs.input0.getDOMNode().focus() if @props.focus
    {x,y} = @getPosition @props.subject.data
    @setState
      dx: x
      dy: y, => @forceUpdate() # updates component position on new subject

  componentWillMount: ->
    # currently does nothing

  componentWillUnmount: ->
    console.log 'TEXT-TOOL::componentWillUnmount(), @props = ', @props
    if @props.task.tool_config.suggest == 'common'
      el = $(@refs.input0.getDOMNode())
      el.autocomplete 'destroy'

  componentDidMount: ->
    @updatePosition()
    # @refs.input0.getDOMNode().focus() if @props.focus

    if @props.task.tool_config.suggest == 'common'
      el = $(@refs.input0.getDOMNode())
      el.autocomplete
        source: (request, response) =>
          $.ajax
            url: "/classifications/terms/#{@props.workflow.id}/#{@props.key}"
            dataType: "json"
            data:
              q: request.term
            success: ( data ) =>
              response( data )
        minLength: 3

  # Expects size hash with:
  #   w: [viewer width]
  #   h: [viewer height]
  #   scale:
  #     horizontal: [horiz scaling of image to fit within above vals]
  #     vertical:   [vert scaling of image..]
  onViewerResize: (size) ->
    @setState
      viewerSize: size
    @updatePosition()

  updatePosition: ->
    if @state.viewerSize? && ! @state.dragged
      @setState
        dx: @props.subject.data.x * @state.viewerSize.scale.horizontal
        dy: (@props.subject.data.y + @props.subject.data.height) * @state.viewerSize.scale.vertical

  # NOTE: doesn't get called unless @props.standalone is true
  commitAnnotation: ->
    console.log 'TEXT-TOOL::commitAnnotation()'
    @props.onComplete @props.annotation

  returnToMarking: ->
    @commitAnnotation()
    console.log 'Transitioning...'
    console.log 'SUBJECT SET ID:      ', @props.subject.subject_set_id
    console.log 'SELECTED SUBJECT ID: ', @props.subject.id
    console.log 'SUBJECT: ', @props.subject
    # window.location.replace "http://localhost:3000/#/mark?subject_set_id=#{@props.subject.subject_set_id}&selected_subject_id=#{@props.subject.parent_subject_id.$oid}"
    @replaceWith("/mark?subject_set_id=#{@props.subject.subject_set_id}&selected_subject_id=#{@props.subject.parent_subject_id.$oid}" )

  handleChange: (e) ->
    console.log 'TEXT-TOOL::handleChange(), @state.annotation = ', @props.annotation
    console.log 'E.TARGET.VALUE: ', e.target.value
    @props.annotation[@props.key] = e.target.value

    # if applicable, send composite tool updated annotation
    @props.onChange(@props.annotation)?

    @forceUpdate()

  handleKeyPress: (e) ->
    if [13].indexOf(e.keyCode) >= 0 # ENTER
      @commitAnnotation()
      e.preventDefault()

  render: ->
    # get component position
    style =
      left: "#{@state.dx*@props.scale.horizontal}px"
      top: "#{@state.dy*@props.scale.vertical}px"

    val = @props.annotation[@props.key] ? ''

    unless @props.standalone
      label = @props.label ? ''
    else
      label = @props.task.instruction

    # create component input field(s)
    tool_content =
      <div className="input-field active">
        <label>{label}</label>
        <input ref="input0" type="date" data-task_key={@props.task.key} onKeyDown={@handleKeyPress} onChange={@handleChange} value={val} />
      </div>


    if @props.standalone # 'standalone' true if component handles own mouse events
      tool_content =
        <Draggable
          onStart={@handleInitStart}
          onDrag={@handleInitDrag}
          onEnd={@handleInitRelease}
          ref="inputWrapper0"
          x={@state.dx*@props.scale.horizontal}
          y={@state.dy*@props.scale.vertical}>

          <div className="transcribe-tool" style={style}>
            <div className="left">
              {tool_content}
            </div>
            <div className="right">

              {
                if window.location.hash is '#/transcribe' # regular transcribe, i.e. no mark transition
                  <DoneButton onClick={@commitAnnotation} />
                else
                  <span>
                    <label>Return to marking: </label>
                    {console.log 'PROPS: ', @props}
                    <button className='button done' onClick={@returnToMarking}>
                      {'Finish'}
                    </button>
                  </span>
              }

            </div>
          </div>

        </Draggable>
    else return tool_content # render input fields without Draggable

module.exports = DateTool