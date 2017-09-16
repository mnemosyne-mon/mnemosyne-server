import * as Preact from 'preact'

VNode = Preact.h('a', null).constructor

export createElement = (element, props, children...) ->
  if props? && (typeof props != 'object' || props instanceof VNode)
    children.unshift props
    props = {}

  Preact.h element, props, ...children

export class Component extends Preact.Component
  constructor: ->
    super()
