require 'digest'
require '../scripts/binary'

ARGS = Hash[ARGV.flat_map { |s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) }]

keys = ['name', 'password', 'group', 'email']
keys.each { |k| raise 'argumentos invalidos' unless ARGS.key?(k) }

writer = BinaryWriter.new
writer.write :string, ARGS['name']
writer.write :string, Digest::SHA256.base64digest(ARGS['password'])
writer.write :string, ARGS['group']
writer.write :string, ARGS['email']
writer.write :byte, 0
writer.save "../data/accounts/#{ARGS['name']}.dat"