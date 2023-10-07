from flask import Flask

app = Flask(__name__)

# 定义通用的路由，无论路径如何都返回相同的结果
@app.route('/<path:path>')
def handle_path(path):
    return '127.0.0.1'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
