#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'uri'
require 'erb'

class Prepare
  def initialize
    @o = Struct.new(:v, :url, :ip, :log, :data).new
    OptionParser.new do |opts|
      opts.on('-v',      'verbose')   { @o.v        = true }
      opts.on('-u URL',  'url')       { |u| @o.url  = u }
      opts.on('-i IP',   'resolve')   { |i| @o.ip   = i }
      opts.on('-l log',  'logfile')   { |l| @o.log  = l }
      opts.on('-d data', 'post data') { |d| @o.data = d }
      @opts = opts
    end.parse!
    abort 'url?' unless @o.url
    @uri = URI.parse @o.url
    puts "==> #{@uri.scheme}://#{@uri.host}:#{@uri.port}" \
         "#{@uri.path}?#{@uri.query}"

    tpl = File.read('lua.erb')
    @tpl_lua = ERB.new(tpl, nil, '-')
  end

  def go
    lua = @tpl_lua.result_with_hash(
      port:   @uri.port,
      host:   @uri.host,
      scheme: @uri.scheme,
      path:   @uri.path,
      ip:     @o.ip,
      data:   @o.data,
      log:    @o.log
    )
    puts lua
  end

  private

end

Prepare.new.go
