import {
  select
} from 'd3-selection'

import {
  scaleTime,
  scaleLinear,
  scaleLog
} from 'd3-scale'

import {
  axisBottom,
  axisLeft
} from 'd3-axis'

import {
  timeMinute
} from 'd3-time'

import {
  timeFormat
} from 'd3-time-format'

import {
  color
} from 'd3-color'

import {
  max
} from 'd3-array'

import {
  drag
} from 'd3-drag'

import 'd3-selection-multi'

export async function heatmap(el) {
  let height = 395
  let margin = {
    left: 1,
    top: 1,
    right: 1
  }

  let offset = {
    left: 60,
    bottom: 20
  }

  let $el = select(el)
  let width = $el.node().offsetWidth - margin.left - margin.right - offset.left - 1

  let url = new URL(el.dataset.source)
  url.searchParams.append('tbs', Math.floor(width / 8) + 1)

  let response = await fetch(url),
    json = await response.json(),
    data = json['values']

  let bucketWidth = width / json['time']['size']
  let bucketHeight = height / json['latency']['size']

  let scaleX = scaleTime()
    .range([0, width])
    .domain(json['time']['range'].map((x) => Date.parse(x)))
  let scaleY = scaleLinear()
    .range([height, 0])
    .domain(json['latency']['range'].map((x) => x / 1000000))
  let scaleZ = scaleLog()
    .range(['#CFE9FF', '#0275D8'])
    .domain([1, max(data, (x) => x.v)])


  let svg = $el.append('svg')
      .attr('width', $el.node().offsetWidth)
      .attr('height', height + offset.bottom)
    .append('g')
      .attr('transform', `translate(${margin.left + offset.left}, ${margin.top})`)

  let axisX = axisBottom(scaleX)
    .tickFormat(timeFormat('%H:%M'))
    .ticks(timeMinute.every(10))
  let axisY = axisLeft(scaleY)
    .tickFormat((x) => `${x} ms`)
    .ticks(3)

  svg.append('g')
    .attr('transform', `translate(0,${height})`)
    .call(axisX)

  svg.append('g')
    .attr('transform', 'translate(0, 0)')
    .call(axisY)

  let heatmap = svg
    .append('g')
    .classed('hm-data', true)

  let group = undefined
  let lastY = 0

  for(let {x, y, v} of data) {
    if(!group || y != lastY) {
      group = heatmap.append('g')
      group.classed(`hm-row-${y}`, true)
      lastY = y
    }

    group
      .append('rect')
      .attrs({
        x: Math.round(1 + x * bucketWidth),
        y: height - bucketHeight - y * bucketHeight,
        width: Math.round(bucketWidth),
        height: bucketHeight,
        fill: scaleZ(v),
        title: v,
      })
  }

  let hm_back = heatmap
    .append('rect')
    .attr('width', width)
    .attr('height', height)
    .attr('fill', 'transparent')

  function dragstart(e) {
    console.log('start', e)
  }

  function dragging(e) {
    console.log('drag', e)
  }

  function dragstop(e) {
    console.log('end', e)
  }

  hm_back.call(drag()
    .on('start', dragstart)
    .on('drag', dragging)
    .on('end', dragstop));
}
