from http.server import BaseHTTPRequestHandler, HTTPServer
import json

hostName = "localhost"
serverPort = 64507

# TODO(kedz): Pick up server config from centralized location.
# TODO(kedz): figure out a way to sync expected results with Lua test cases.
# TODO(kedz): Doublecheck what a good error code to use is.


class MockedOllamaAPI(BaseHTTPRequestHandler):
    def do_POST(self):
        data_string = self.rfile.read(int(self.headers['Content-Length']))
        data = json.loads(data_string)
        print(data)
        match data["prompt"]:
            case "Result with 3 responses":
                self.handle_Result_with_3_responses(data)
            case "Result with newlines":
                self.handle_Result_with_newlines(data)
            case _:
                self.send_response(400)
                self.end_headers()

    def handle_Result_with_3_responses(self, data):
        if "stream" not in data or not isinstance(data["stream"], bool):
            self.send_response(400)
            self.end_headers()
            return

        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        if data["stream"]:
            self.wfile.write(json.dumps({"response": "resp1"}).encode("utf8"))
            self.wfile.write("\n".encode("utf8"))
            self.wfile.write(json.dumps({"response": "resp2"}).encode("utf8"))
            self.wfile.write("\n".encode("utf8"))
            self.wfile.write(json.dumps({"response": "resp3"}).encode("utf8"))
            self.wfile.write("\n".encode("utf8"))
        else:
            self.wfile.write(json.dumps({"response": "resp1resp2resp3"}).encode("utf8"))
            self.wfile.write("\n".encode("utf8"))

    def handle_Result_with_newlines(self, data):
        if "stream" not in data or not isinstance(data["stream"], bool):
            self.send_response(400)
            self.end_headers()
            return

        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        if data["stream"]:
            self.wfile.write(json.dumps({"response": "foo\nbar"}).encode("utf8"))
            self.wfile.write("\n".encode("utf8"))
            self.wfile.write(json.dumps({"response": "\nbaz"}).encode("utf8"))
            self.wfile.write("\n".encode("utf8"))
            self.wfile.write(json.dumps({"response": "biz\n"}).encode("utf8"))
            self.wfile.write("\n".encode("utf8"))
        else:
            self.wfile.write(json.dumps({"response": "foo\nbar\nbazbiz\n"}).encode("utf8"))
            self.wfile.write("\n".encode("utf8"))



if __name__ == "__main__":        
    server = HTTPServer((hostName, serverPort), MockedOllamaAPI)
    print("Server started http://%s:%s" % (hostName, serverPort))

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass

    server.server_close()
    print("Server stopped.")
