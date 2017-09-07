import * as React from 'react'

RComponent = React.Component

dumpCN = (cx) ->
  if Array.isArray(cx)
    cx
      .map dumpCN
      .join ' '
  else if cx? && typeof cx == 'object'
    Object.entries(cx)
      .filter ([k, v]) -> v
      .map ([k, _]) -> k
      .join ' '
  else
    cx

export createElement = (element, props, children...) ->
  if props?
    if React.isValidElement(props) || typeof props != 'object'
      children.unshift props
      props = {}

    props.className = dumpCN(props.className)

  React.createElement element, props, children...

export class Component extends RComponent
  constructor: ->
    super()
