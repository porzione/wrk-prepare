#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'uri'
require 'erb'

class Prepare
  def initialize
    optparse
    @uri = URI.parse @o.url
    @tpl_lua = ERB.new(File.read('lua.erb'), nil, '-')
  end

  def go
    puts @tpl_lua.result_with_hash(
      port:   @uri.port,
      host:   @uri.host,
      scheme: @uri.scheme,
      path:   @uri.path,
      query:  @uri.query,
      ip:     @o.ip,
      data:   @o.data,
      log:    @o.log
    )
  end

  private

  def optparse
    @o = Struct.new(:url, :ip, :log, :data).new
    OptionParser.new do |opts|
      opts.on('-u URL',  'url')       { |u| @o.url  = u }
      opts.on('-i IP',   'resolve')   { |i| @o.ip   = i }
      opts.on('-l log',  'logfile')   { |l| @o.log  = l }
      opts.on('-d data', 'post data') { |d| @o.data = d }
      @opts = opts
    end.parse!
    abort 'give me url with -u' unless @o.url
  end
end

Prepare.new.go
