from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import os

app = Flask(__name__)
CORS(app)  # 允许跨域访问

# 数据库文件路径（确保数据库存储在项目目录下）
DATABASE_PATH = os.path.join(os.path.dirname(__file__), 'records.db')


# 初始化数据库
def init_db():
    print(f"Database file path: {DATABASE_PATH}")
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            isReviewed BOOLEAN NOT NULL,
            isConfirmed BOOLEAN NOT NULL,
            disputes TEXT,
            responses TEXT
        )
    ''')
    conn.commit()
    conn.close()


# 上传记录接口
@app.route('/records', methods=['POST', 'GET'])
def records():
    if request.method == 'POST':
        try:
            # 获取请求数据
            data = request.json
            print("Raw request data:", request.data)  # 打印原始请求数据
            print("Parsed JSON:", data)  # 打印解析后的 JSON 数据

            # 检查数据是否为空
            if not data:
                return jsonify({"message": "No data provided"}), 400

            # 如果是单条记录（字典），转换为列表
            if isinstance(data, dict):
                data = [data]

            # 确保数据为列表
            if not isinstance(data, list):
                return jsonify({"message": "Invalid data format: Expected a list"}), 400

            # 插入记录到数据库
            with sqlite3.connect(DATABASE_PATH, timeout=10) as conn:
                cursor = conn.cursor()
                for record in data:
                    print("Processing record:", record)  # 打印每条记录
                    cursor.execute('''
                        INSERT INTO records (item, amount, date, isReviewed, isConfirmed, disputes, responses)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    ''', (
                        record['item'],
                        record['amount'],
                        record['date'],
                        record['isReviewed'],
                        record['isConfirmed'],
                        ",".join(record.get('disputes', [])),
                        ",".join(record.get('responses', []))
                    ))
                conn.commit()

            return jsonify({"message": "Records uploaded successfully", "records_count": len(data)}), 200

        except sqlite3.OperationalError as e:
            print(f"Database OperationalError: {str(e)}")
            return jsonify({"message": f"Database error: {str(e)}"}), 500

        except Exception as e:
            print(f"Error occurred: {str(e)}")
            return jsonify({"message": f"Server error: {str(e)}"}), 500

    elif request.method == 'GET':
        try:
            with sqlite3.connect(DATABASE_PATH, timeout=10) as conn:
                cursor = conn.cursor()
                cursor.execute('SELECT * FROM records')
                rows = cursor.fetchall()

                # 格式化记录为 JSON
                records = []
                for row in rows:
                    records.append({
                        "id": row[0],
                        "item": row[1],
                        "amount": row[2],
                        "date": row[3],
                        "isReviewed": bool(row[4]),
                        "isConfirmed": bool(row[5]),
                        "disputes": row[6].split(",") if row[6] else [],
                        "responses": row[7].split(",") if row[7] else []
                    })

                return jsonify(records), 200

        except sqlite3.OperationalError as e:
            print(f"Database OperationalError: {str(e)}")
            return jsonify({"message": f"Database error: {str(e)}"}), 500

        except Exception as e:
            print(f"Error occurred: {str(e)}")
            return jsonify({"message": f"Server error: {str(e)}"}), 500


# 启动服务
if __name__ == '__main__':
    init_db()  # 初始化数据库
    app.run(host='192.168.127.1', port=8080)
