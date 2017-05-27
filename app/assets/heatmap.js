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

import 'd3-selection-multi'

export async function heatmap(el) {
  let height = 400
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
  let width = $el.node().offsetWidth - margin.left - margin.right - offset.left

  console.log(width)

  let response = await fetch(el.dataset.source),
    json = await response.json(),
    data = json['values']

  let bucketWidth = width / json.x.length
  let bucketHeight = height / json.y.length

  let scaleX = scaleTime()
    .range([0, width])
    .domain(json.x.range.map((x) => Date.parse(x)))
  let scaleY = scaleLinear()
    .range([height, 0])
    .domain(json.y.range.map((x) => x / 1000))
  let scaleZ = scaleLog()
    .range(['#CFE9FF', '#0275D8'])
    .domain([1, max(data, (x) => x.v)])


  let svg = $el.append('svg')
      .attr('width', $el.node().offsetWidth)
      .attr('height', height + offset.bottom)
    .append('g')
      .attr('transform', `translate(${margin.left + offset.left}, ${margin.top})`)

  let axisX = axisBottom(scaleX)
    .tickFormat(timeFormat('%I:%M:%S'))
    .ticks(timeMinute.every(10))
  let axisY = axisLeft(scaleY)
    .tickFormat((x) => `${x} ms`)
    .ticks(3)

  svg.append('g')
    .attr('transform', `translate(0,${height + 1})`)
    .call((g) => {
      g.call(axisX)
      g.selectAll('.domain').remove()
      g.selectAll('.tick text').style('text-anchor', 'middle')
    })

  svg.append('g')
    .attr('transform', 'translate(0, 0)')
    .call((g) => {
      g.call(axisY)
      g.selectAll('.domain').remove()
      g.selectAll('.tick line').remove()
    })

  let heatmap = svg
    .append('g')
    .classed('hm-data', true)

  let group = heatmap.append('g')
  let lastY = 0;

  for(let {x, y, v} of data) {
    if(y != lastY) {
      group = heatmap.append('g')
      group.classed(`hm-row-${y}`, true)
      lastY = y
    }

    group
      .append('rect')
      .attrs({
        x: Math.round(0 + x * bucketWidth),
        y: height - bucketHeight - y * bucketHeight,
        width: Math.round(bucketWidth),
        height: bucketHeight,
        fill: scaleZ(v),
        title: v
      })
  }

  let hm_back = heatmap
    .append('rect')
    .attr('width', width)
    .attr('height', height)
    .attr('fill', 'transparent')

  hm_back.on('click', (x) => console.log(x))
}
