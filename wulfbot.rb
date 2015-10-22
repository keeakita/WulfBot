#!/bin/env ruby

require 'telegram/bot'

token = JSON.parse(File.read('./secrets.json'))['token']
