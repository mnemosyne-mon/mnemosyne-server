import * as Preact from 'preact'

export createElement = (element, props, children...) ->
  if props? && (Array.isArray(props) || typeof props != 'object' || props.props?)
    children.unshift props
    props = {}

  Preact.h element, props, ...children

export class Component extends Preact.Component
  constructor: ->
    super()
