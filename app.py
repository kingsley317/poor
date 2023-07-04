import os
import pandas as pd
from flask import Flask, render_template


app = Flask(__name__)

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/dm')
def data_modeling():
    return render_template('dm.html')

@app.route('/fe')
def findings_evaluation():
    return render_template('fe.html')

@app.route('/c')
def conclusion():
    return render_template('c.html')

@app.route('/ai')
def ai_modeling():
    return render_template('ai.html')

@app.route('/da')
def data_analysis():
    target = os.path.join(app.static_folder, 'data.xlsx')
    df = pd.read_excel(target)
    table = df.to_html(index=False, classes='table table-striped')
    return render_template('da.html', data=table)

if __name__ == '__main__':
    app.run(debug=True)