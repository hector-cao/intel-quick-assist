#!/usr/bin/env python3

from qat_tools.qatlib import *

import argparse
from prettytable import PrettyTable

VERSION = '1.0.0'

def list_dev(args, qat_manager):
  qat_manager.list_devices(args.short)

def status_dev(args, qat_manager):
  if args.vfio:
    qat_manager.print_vfio()
  else:
    qat_manager.print_cfg()

# Check arguments and call requested function
def qatctl(opts, p):
  global VERSION
  qat_manager = QatDevManager(opts.devices)

  if opts.set_state:
    print(f'Set device state : {opts.set_state}')
    qat_manager.set_state(opts.set_state)
    return

  if opts.get_state:
    qat_manager.get_state()
    return

  if opts.set_service:
    print(f'Set device service : {opts.set_service}')
    qat_manager.set_service(opts.set_service)
    print(f'Please restart qat service to update the config')
    return

  opts.func(opts, qat_manager)

# * sym;asym: the device is configured for running crypto
# 		  services
# * asym;sym: identical to sym;asym
# * dc: the device is configured for running compression services
# * dcc: identical to dc but enables the dc chaining feature,
#   hash then compression. If this is not required chose dc
# * sym: the device is configured for running symmetric crypto
#   services
# * asym: the device is configured for running asymmetric crypto
#   services
# * asym;dc: the device is configured for running asymmetric
#   crypto services and compression services
# * dc;asym: identical to asym;dc
# * sym;dc: the device is configured for running symmetric crypto
#   services and compression services
# * dc;sym: identical to sym;dc
cfg_services = [
  'sym;asym', 'asym;sym',
  'dc',
  'dcc',
  'sym',
  'asym',
  'asym,dc',
  'dc;asym',
  'sym;dc',
  'dc;sym'
]

def main():
  parser = argparse.ArgumentParser(description=f'QAT control utility - v{VERSION}')
  parser.add_argument('-d', '--devices',
                      nargs='+', default=None,
                      help='select devices for the command (space separated)')
  list_group = parser.add_argument_group('list group')
  subparser = parser.add_subparsers()
  parser_list_dev = subparser.add_parser('list')
  parser_list_dev.add_argument('--short', '-s',
                          action='store_true', default=False,
                          help='list devices (PF)')
  parser_list_dev.set_defaults(func=list_dev) 
  parser.add_argument('--set-state',
                      type=str, default=None, choices=['up', 'down'],
                      help='set device state')
  parser.add_argument('--set-service',
                      type=str, default=None, choices=cfg_services,
                      help='set device service')
  parser.add_argument('--get-state',
                      action='store_true', default=False,
                      help='get device state')
  status_group = parser.add_argument_group('status group')
  parser_status = subparser.add_parser('status')
  parser_status.add_argument('--vfio',
                             action='store_true', default=False,
                             help='list VFIO devices')
  parser_status.set_defaults(func=status_dev)
  results = parser.parse_args()
  qatctl(results, parser)
