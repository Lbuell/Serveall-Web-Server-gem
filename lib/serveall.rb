require "serveall/version"
require 'socket'
require 'uri'

ARGV.each do |a|

  if a.to_i > 999 && a.to_i < 100000
    SERVER_PORT = a.to_i
  end

  if File.directory?(File.join("./", a))
    WEB_ROOT = File.join("./", a)
  end

end
# Files will be served from this directory
WEB_ROOT = "./public" unless defined?(WEB_ROOT)

SERVER_PORT = 1337 unless defined?(SERVER_PORT)
# Map extensions to their content type
CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}

# Treat as binary data if content type cannot be found
DEFAULT_CONTENT_TYPE = 'application/octet-stream'

# This helper function parses the extension of the
# requested file and then looks up its content type.

def content_type(path)
  ext = File.extname(path).split(".").last
  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end

# This helper function parses the Request-Line and
# generates a path to a file on the server.
def requested_file(request_line)
  request_uri = request_line.split(" ")[1]
  path = URI.unescape(URI(request_uri).path)

  clean = []
  parts = path.split("/")

  parts.each do |part|
    next if part.empty? || part == "."
    part == '..' ? clean.pop : clean << part
  end
  File.join(WEB_ROOT, *clean)
end

# Except where noted below, the general approach of
# handling requests and generating responses is
# similar to that of the "Hello World" example
# shown earlier.

server = TCPServer.new('localhost', SERVER_PORT)

loop do
    socket = server.accept
    request_line = socket.gets

    STDERR.puts request_line

    path = requested_file(request_line)

    path = File.join(path, 'index.html') if File.directory?(path)

    # Make sure the file exists and is not a directory
    # before attempting to open it.
    if File.exist?(path) && !File.directory?(path)
      File.open(path, "rb") do |file|
        socket.print "HTTP/1.1 200 OK\r\n" +
                     "Content-Type: #{content_type(file)}\r\n" +
                     "Content-Length: #{file.size}\r\n" +
                     "Connection: close\r\n"

        socket.print "\r\n"

        # write the contents of the file to the socket
        IO.copy_stream(file, socket)
      end
    elsif
      File.open("./") do |file|
      socket.print "HTTP/1.1 200 OK\r\n" +
                    "Content-Type: text/html\r\n" +
                    "Content-Length: #{file.size}\r\n" +
                    "Connection: close\r\n"
      socket.print "\r\n"
        # write the contents of the file to the socket
      end
    else
      message = "File not found\n"
      File.open("public/404.html") do |file|
      socket.print "HTTP/1.1 404 Not Found\r\n" +
                    "Content-Type: text/html\r\n" +
                    "Content-Length: #{file.size}\r\n" +
                    "Connection: close\r\n"
      socket.print "\r\n"
      IO.copy_stream(file, socket)
    end
    socket.close
    end
end
