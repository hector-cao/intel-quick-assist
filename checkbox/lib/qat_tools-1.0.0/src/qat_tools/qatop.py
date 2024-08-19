#!/usr/bin/env python3

# This tool record and display QAT telemetry data
# https://www.kernel.org/doc/Documentation/ABI/testing/debugfs-driver-qat_telemetry

import argparse
from enum import Enum
import pathlib
import re
import subprocess
import time
import urwid as u
from urwid import LineBox
import json
import itertools

from qat_tools.qatlib import *

VERSION = '1.0.0'

class MyListBox(u.ListBox):

  def keypress(self, size, key):
    if key in ('tab',):
      self.focus_position = (self.focus_position + 1) % len(self.body.contents)
      if self.focus_position == 0:
        return key
    else:
      return key

  def selectable(self):
    return len(self.body.contents) > 0

class CustomProgressBar(u.ProgressBar):
  def __init__(self, fn, counter_type, *args, **kwargs):
    super().__init__(*args, **kwargs)
    self.fn = fn
    self.counter_type = counter_type
    self.max_val = 0
    self.sample_count = 1
    self.total = 0

  def get_text(self):
    if self.current < 0:
      return "Not available"
    avg_val = self.total / self.sample_count
    if self.counter_type == CounterType.UTILIZATION:  
      return f'{self.current:.1f}% (max: {self.max_val:.1f} - avg: {avg_val:.1f})'
    else:
      return f'{self.current} (max: {self.max_val} - avg: {avg_val})'

  def update_display(self):
    val =  self.fn()
    if val > self.max_val:
      self.max_val = val
    if (val > 0):
      self.sample_count = self.sample_count + 1
      self.total = self.total + val
    self.set_completion(val)

class UIApp(object):

  def handle_key(self, key):
    if key in ('q',):
      raise u.ExitMainLoop()
    if key in ('tab',):
      next_focus = (self.columns.focus_position + 1) % len(self.columns.contents)
      self.columns.set_focus(next_focus)

  def create_progress_bar(self,
                          dev,
                          counter_type: CounterType,
                          counter_engine: CounterEngine):
    def get_utilization_val():
      return dev.debugfs.get('telemetry').get('device_data').avg(counter_type, counter_engine)
    counter_name = f'{counter_type.value}_{counter_engine.value}'
    # filtering
    if not QatDevManager.filter_counter(counter_name):
      return None
    pb_title = '{}/{}'.format(dev.pci_id, counter_name)
    pb = CustomProgressBar(get_utilization_val, counter_type,
                           '',
                           'loaded')
    col = u.Columns([('weight', 0.2,
              u.Text(pb_title)), LineBox(pb)])
    self.progress_bars.append(pb)
    return col

  def __init__(self, qat_manager: QatDevManager):

    self.qat_manager = qat_manager

    self.progress_bars = []
    cols = []
    for dev in qat_manager.qat_devs:
      for util_cat in CounterEngine:
        col = self.create_progress_bar(dev, CounterType.UTILIZATION, util_cat)
        if col:
          cols.append(col)
        col = self.create_progress_bar(dev, CounterType.EXECUTION, util_cat)
        if col:
          cols.append(col)

    self.header = u.Text('qatop')
    self.footer = u.Text('Enter q to exit.')

    frame = u.Frame(u.Filler(
      u.GridFlow(cols, cell_width=130, h_sep=0, v_sep=0, align='left')),
            header=self.header,
            footer=self.footer)

    palette = [("loaded", "black", "light cyan")]
    loop = u.MainLoop(frame, palette, unhandled_input=self.handle_key)

    loop.set_alarm_in(1, self.refresh)
    loop.run()

  def refresh(self, loop=None, data=None):
    self.qat_manager.collect_telemetry()
    for pb in self.progress_bars:
       pb.update_display()
    loop.set_alarm_in(1, self.refresh)

# Check arguments and call requested function
def qatop(opts, p):
  global VERSION

  QatDevManager.counters = opts.counters

  qat_manager = QatDevManager(opts.devices)

  if opts.record:
    while True:
      qat_manager.collect_telemetry()
      qat_manager.print_telemetry()
      time.sleep(1)
  else:
    app = UIApp(qat_manager)

counters = [ counter[0] + '_' + counter[1] for counter in
             itertools.product(CounterType.list(), CounterEngine.list()) ]

def main():
  parser = argparse.ArgumentParser(description=f'QAT telemetry display and record tool - v{VERSION}')
  parser.add_argument('--record', '-r', action='store_true', default=False, help='Record telemetry data')
  parser.add_argument('-d', '--devices', nargs='+', default=None, help='List of devices to display (if not provided, display all devices)')
  parser.add_argument('-c', '--counters', nargs='*',
                      choices=counters,
                      help='List of counters to display (default: %(default)s)')
  results = parser.parse_args()
  qatop(results, parser)

