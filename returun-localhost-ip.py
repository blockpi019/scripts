from flask import Flask

app = Flask(__name__)

# Define a generic route that returns the same result regardless of the path
@app.route('/<path:path>')
def handle_path(path):
    return '127.0.0.1'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
