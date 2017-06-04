import 'timeago'

import {
  render
} from 'react-dom'

import {
  createElement
} from 'react'

import * as components from 'components/index'

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('script[data-component').forEach((el) => {
    let component = components[el.dataset.component]
    let props = JSON.parse(el.innerHTML)
    let newNode = document.createElement('div')

    el.parentNode.replaceChild(newNode, el)

    render(createElement(component, props), newNode)

    console.log(newNode, component, props)
  })
})

jQuery(document).ready(function() {
  $('[data-time-ago]').timeago()
})
